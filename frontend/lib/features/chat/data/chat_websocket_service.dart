import 'dart:async';
import 'dart:convert';

import 'package:frontend/features/chat/domain/chat_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

enum ChatSocketConnectionState { disconnected, connecting, connected }

class ChatSocketEvent {
  const ChatSocketEvent({
    required this.type,
    this.message,
    this.userId,
    this.status,
    this.lastSeen,
    this.error,
  });

  final String type;
  final ChatMessage? message;
  final String? userId;
  final String? status;
  final DateTime? lastSeen;
  final String? error;
}

class ChatWebSocketService {
  final _eventsController = StreamController<ChatSocketEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  Stream<ChatSocketEvent> get events => _eventsController.stream;

  void connect({
    required Uri uri,
    required String currentUserId,
    required VoidCallback onDisconnected,
  }) {
    disconnect();
    final channel = WebSocketChannel.connect(uri);
    var didReportDisconnect = false;

    void reportDisconnected([Object? error]) {
      if (_channel != channel || didReportDisconnect) {
        return;
      }
      didReportDisconnect = true;
      if (error != null && !_eventsController.isClosed) {
        _eventsController.add(
          ChatSocketEvent(type: 'error', error: error.toString()),
        );
      }
      onDisconnected();
    }

    _channel = channel;
    unawaited(channel.ready.catchError(reportDisconnected));
    _subscription = channel.stream.listen(
      (event) => _handleEvent(event, currentUserId),
      onError: reportDisconnected,
      onDone: reportDisconnected,
      cancelOnError: true,
    );
  }

  void sendMessage({required String content, required String receiverId}) {
    _send({
      'type': 'chat_message',
      'content': content,
      'receiver_id': receiverId,
    });
  }

  void markAsRead() {
    _send({'type': 'mark_read'});
  }

  void sendTyping(bool isTyping) {
    _send({'type': 'typing', 'is_typing': isTyping});
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventsController.close();
  }

  void _send(Map<String, dynamic> payload) {
    _channel?.sink.add(jsonEncode(payload));
  }

  void _handleEvent(dynamic event, String currentUserId) {
    final decoded = jsonDecode(event as String);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    final type = decoded['type'] as String? ?? '';
    if (type == 'chat_message') {
      _eventsController.add(
        ChatSocketEvent(
          type: type,
          message: ChatMessage.fromJson(decoded, currentUserId: currentUserId),
        ),
      );
      return;
    }

    _eventsController.add(
      ChatSocketEvent(
        type: type,
        userId: decoded['user_id'] as String?,
        status: decoded['status'] as String?,
        lastSeen: _parseDate(decoded['last_seen']),
        error: decoded['message'] as String?,
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}

typedef VoidCallback = void Function();

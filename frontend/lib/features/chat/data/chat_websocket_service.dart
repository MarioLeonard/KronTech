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
    this.error,
  });

  final String type;
  final ChatMessage? message;
  final String? userId;
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
    _channel = WebSocketChannel.connect(uri);
    _subscription = _channel!.stream.listen(
      (event) => _handleEvent(event, currentUserId),
      onError: (Object error) {
        _eventsController.add(
          ChatSocketEvent(type: 'error', error: error.toString()),
        );
        onDisconnected();
      },
      onDone: onDisconnected,
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
        error: decoded['message'] as String?,
      ),
    );
  }
}

typedef VoidCallback = void Function();

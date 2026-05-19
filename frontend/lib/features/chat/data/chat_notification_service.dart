import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class ChatNotificationEvent {
  const ChatNotificationEvent({
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    this.senderAvatarUrl,
    required this.content,
    required this.timestamp,
  });

  final String conversationId;
  final String senderId;
  final String senderName;
  final String? senderAvatarUrl;
  final String content;
  final DateTime timestamp;

  factory ChatNotificationEvent.fromJson(Map<String, dynamic> json) {
    final timestamp = json['timestamp'];
    return ChatNotificationEvent(
      conversationId: json['conversation_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName:
          json['sender_name'] as String? ??
          json['sender_id'] as String? ??
          'Someone',
      senderAvatarUrl:
          json['sender_avatar_url'] as String? ?? json['avatar_url'] as String?,
      content: json['content'] as String? ?? '',
      timestamp: timestamp is String
          ? DateTime.tryParse(timestamp)?.toLocal() ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class ChatNotificationService {
  final _eventsController = StreamController<ChatNotificationEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  Stream<ChatNotificationEvent> get events => _eventsController.stream;

  void connect({required Uri uri, required void Function() onDisconnected}) {
    disconnect();
    final channel = WebSocketChannel.connect(uri);
    var didReportDisconnect = false;

    void reportDisconnected([Object? _]) {
      if (_channel != channel || didReportDisconnect) {
        return;
      }
      didReportDisconnect = true;
      onDisconnected();
    }

    _channel = channel;
    unawaited(channel.ready.catchError(reportDisconnected));
    _subscription = channel.stream.listen(
      _handleEvent,
      onError: reportDisconnected,
      onDone: reportDisconnected,
      cancelOnError: true,
    );
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

  void _handleEvent(dynamic event) {
    final decoded = jsonDecode(event as String);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    if (decoded['type'] != 'chat_notification') {
      return;
    }

    final notification = ChatNotificationEvent.fromJson(decoded);
    if (notification.conversationId.isEmpty) {
      return;
    }
    _eventsController.add(notification);
  }
}

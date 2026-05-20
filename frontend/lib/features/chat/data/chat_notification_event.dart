part of 'chat_notification_service.dart';

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

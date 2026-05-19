/// Represents a single message in a chat conversation
class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isCurrentUser;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    required this.isCurrentUser,
    this.status = MessageStatus.delivered,
  });

  factory ChatMessage.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final senderId = json['sender_id'] as String? ?? '';
    final timestampValue = json['timestamp'];
    final isRead = json['is_read'] as bool? ?? false;

    return ChatMessage(
      id:
          (json['id'] ??
                  json['message_id'] ??
                  DateTime.now().microsecondsSinceEpoch)
              .toString(),
      senderId: senderId,
      senderName: senderId == currentUserId ? 'You' : senderId,
      content: json['content'] as String? ?? '',
      timestamp: timestampValue is String
          ? DateTime.tryParse(timestampValue)?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      isCurrentUser: senderId == currentUserId,
      status: isRead ? MessageStatus.read : MessageStatus.delivered,
    );
  }

  /// Create a copy with modified fields
  ChatMessage copyWith({
    String? id,
    String? senderId,
    String? senderName,
    String? content,
    DateTime? timestamp,
    bool? isCurrentUser,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isCurrentUser: isCurrentUser ?? this.isCurrentUser,
      status: status ?? this.status,
    );
  }

  /// Format timestamp as time string (e.g., "14:30" or "Yesterday")
  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${timestamp.day} ${months[timestamp.month - 1]}';
    }
  }
}

/// Message delivery status
enum MessageStatus {
  sending('Sending...'),
  delivered('Delivered'),
  read('Read');

  final String label;
  const MessageStatus(this.label);
}

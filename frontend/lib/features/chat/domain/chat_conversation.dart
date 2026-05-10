import 'chat_message.dart';
import 'chat_user.dart';

/// Represents a chat conversation between the current user and another user
class ChatConversation {
  final String id;
  final ChatUser participant;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;
  final int unreadCount;

  const ChatConversation({
    required this.id,
    required this.participant,
    required this.messages,
    required this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory ChatConversation.fromJson(
    Map<String, dynamic> json, {
    required String currentUserId,
  }) {
    final otherUserJson = json['other_user'];
    final otherUserId = json['other_user_id'] as String? ?? '';
    final lastMessage = json['last_message'] as String?;
    final lastMessageTimestamp = _parseDate(json['last_message_timestamp']);
    final previewMessage = lastMessage == null || lastMessage.isEmpty
        ? <ChatMessage>[]
        : [
            ChatMessage(
              id: '${json['conversation_id']}-last',
              senderId:
                  json['last_message_sender_id'] as String? ?? otherUserId,
              senderName: otherUserId,
              content: lastMessage,
              timestamp: lastMessageTimestamp,
              isCurrentUser:
                  (json['last_message_sender_id'] as String?) == currentUserId,
            ),
          ];

    return ChatConversation(
      id: json['conversation_id'] as String? ?? '',
      participant: otherUserJson is Map<String, dynamic>
          ? ChatUser.fromJson(otherUserJson)
          : ChatUser(id: otherUserId, name: otherUserId),
      messages: previewMessage,
      lastMessageTime: lastMessageTimestamp,
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal() ?? DateTime.now();
    }
    return DateTime.now();
  }

  /// Get the last message in the conversation
  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  /// Get the preview text for the conversation (last message or empty)
  String get messagePreview {
    if (messages.isEmpty) return 'No messages yet';
    final last = lastMessage;
    final prefix = last!.isCurrentUser ? 'You: ' : '';
    return '$prefix${last.content}';
  }

  /// Create a copy with modified fields
  ChatConversation copyWith({
    String? id,
    ChatUser? participant,
    List<ChatMessage>? messages,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      participant: participant ?? this.participant,
      messages: messages ?? this.messages,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  /// Hardcoded sample conversations for development
  static final List<ChatConversation> sampleConversations = [
    ChatConversation(
      id: 'conv-1',
      participant: ChatUser.sampleUsers[0],
      messages: [
        ChatMessage(
          id: 'msg-1',
          senderId: 'user-1',
          senderName: 'Sarah Johnson',
          content: 'Hey! How was your trip to the mountains?',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isCurrentUser: false,
        ),
        ChatMessage(
          id: 'msg-2',
          senderId: 'current-user',
          senderName: 'You',
          content: 'It was amazing! The views were incredible.',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 1, minutes: 50),
          ),
          isCurrentUser: true,
        ),
        ChatMessage(
          id: 'msg-3',
          senderId: 'user-1',
          senderName: 'Sarah Johnson',
          content:
              'That sounds wonderful! We should plan another trip together.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
          isCurrentUser: false,
        ),
        ChatMessage(
          id: 'msg-4',
          senderId: 'current-user',
          senderName: 'You',
          content: 'Definitely! I\'m free next month.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
          isCurrentUser: true,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 15)),
      unreadCount: 0,
    ),
    ChatConversation(
      id: 'conv-2',
      participant: ChatUser.sampleUsers[1],
      messages: [
        ChatMessage(
          id: 'msg-5',
          senderId: 'user-2',
          senderName: 'Michael Chen',
          content: 'Did you check the new restaurant downtown?',
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          isCurrentUser: false,
        ),
        ChatMessage(
          id: 'msg-6',
          senderId: 'current-user',
          senderName: 'You',
          content: 'Not yet, is it good?',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 3, minutes: 55),
          ),
          isCurrentUser: true,
        ),
        ChatMessage(
          id: 'msg-7',
          senderId: 'user-2',
          senderName: 'Michael Chen',
          content: 'Yes! Their pasta is incredible. Let\'s go this weekend.',
          timestamp: DateTime.now().subtract(
            const Duration(hours: 3, minutes: 30),
          ),
          isCurrentUser: false,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(
        const Duration(hours: 3, minutes: 30),
      ),
      unreadCount: 1,
    ),
    ChatConversation(
      id: 'conv-3',
      participant: ChatUser.sampleUsers[2],
      messages: [
        ChatMessage(
          id: 'msg-8',
          senderId: 'current-user',
          senderName: 'You',
          content: 'Hi Emma! How are you doing?',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isCurrentUser: true,
        ),
        ChatMessage(
          id: 'msg-9',
          senderId: 'user-3',
          senderName: 'Emma Rodriguez',
          content: 'Great! Just got back from vacation.',
          timestamp: DateTime.now().subtract(const Duration(hours: 22)),
          isCurrentUser: false,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 22)),
      unreadCount: 0,
    ),
    ChatConversation(
      id: 'conv-4',
      participant: ChatUser.sampleUsers[3],
      messages: [
        ChatMessage(
          id: 'msg-10',
          senderId: 'user-4',
          senderName: 'James Wilson',
          content: 'Thanks for the recommendation!',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          isCurrentUser: false,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(days: 2)),
      unreadCount: 0,
    ),
    ChatConversation(
      id: 'conv-5',
      participant: ChatUser.sampleUsers[4],
      messages: [
        ChatMessage(
          id: 'msg-11',
          senderId: 'user-5',
          senderName: 'Lisa Anderson',
          content: 'Are you coming to the event next week?',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          isCurrentUser: false,
        ),
      ],
      lastMessageTime: DateTime.now().subtract(const Duration(days: 3)),
      unreadCount: 0,
    ),
  ];
}

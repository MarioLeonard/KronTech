/// Represents a user in a chat conversation
class ChatUser {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? status;
  final DateTime? lastSeen;

  const ChatUser({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.status,
    this.lastSeen,
  });

  /// Check if user is online
  bool get isOnline => status?.toLowerCase() == 'online';

  /// Hardcoded sample chat users for development
  static final List<ChatUser> sampleUsers = [
    const ChatUser(
      id: 'user-1',
      name: 'Sarah Johnson',
      avatarUrl: null,
      status: 'online',
      lastSeen: null,
    ),
    const ChatUser(
      id: 'user-2',
      name: 'Michael Chen',
      avatarUrl: null,
      status: 'online',
      lastSeen: null,
    ),
    const ChatUser(
      id: 'user-3',
      name: 'Emma Rodriguez',
      avatarUrl: null,
      status: 'away',
      lastSeen: null,
    ),
    const ChatUser(
      id: 'user-4',
      name: 'James Wilson',
      avatarUrl: null,
      status: 'offline',
      lastSeen: null,
    ),
    const ChatUser(
      id: 'user-5',
      name: 'Lisa Anderson',
      avatarUrl: null,
      status: 'online',
      lastSeen: null,
    ),
  ];
}

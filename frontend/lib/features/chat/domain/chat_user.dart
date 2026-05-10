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

  String get presenceLabel {
    if (isOnline) {
      return 'Connected';
    }
    if (lastSeen == null) {
      return 'Offline';
    }

    final now = DateTime.now();
    final difference = now.difference(lastSeen!);
    if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes < 1 ? 1 : difference.inMinutes;
      return 'Last online ${minutes}m ago';
    }
    if (difference.inHours < 24) {
      return 'Last online ${difference.inHours}h ago';
    }

    final day = lastSeen!.day.toString().padLeft(2, '0');
    final month = lastSeen!.month.toString().padLeft(2, '0');
    final year = lastSeen!.year.toString();
    return 'Last online $day.$month.$year';
  }

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? '';
    return ChatUser(
      id: id,
      name:
          json['name'] as String? ??
          json['display_name'] as String? ??
          json['email'] as String? ??
          id,
      avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      status: json['status'] as String?,
      lastSeen: _parseDate(json['last_seen']),
    );
  }

  ChatUser copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? status,
    DateTime? lastSeen,
  }) {
    return ChatUser(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }

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

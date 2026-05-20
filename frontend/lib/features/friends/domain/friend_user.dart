part 'friend_search_result.dart';

enum FriendRelationshipStatus {
  friend,
  requestSent,
  requestReceived,
  available;

  factory FriendRelationshipStatus.fromJson(String? value) {
    return switch (value) {
      'friend' => FriendRelationshipStatus.friend,
      'request_sent' => FriendRelationshipStatus.requestSent,
      'request_received' => FriendRelationshipStatus.requestReceived,
      _ => FriendRelationshipStatus.available,
    };
  }

  String get label {
    return switch (this) {
      FriendRelationshipStatus.friend => 'Prieten',
      FriendRelationshipStatus.requestSent => 'Cerere trimisa',
      FriendRelationshipStatus.requestReceived => 'Cerere primita',
      FriendRelationshipStatus.available => 'Disponibil',
    };
  }
}

class FriendUser {
  const FriendUser({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.friendshipId,
    this.conversationId,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? friendshipId;
  final String? conversationId;
  final DateTime? createdAt;

  factory FriendUser.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? json['uid'] as String? ?? '';
    return FriendUser(
      id: id,
      name:
          json['name'] as String? ??
          json['display_name'] as String? ??
          json['email'] as String? ??
          id,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String? ?? json['photo_url'] as String?,
      friendshipId: json['friendship_id'] as String?,
      conversationId: json['conversation_id'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value)?.toLocal();
    }
    return null;
  }
}

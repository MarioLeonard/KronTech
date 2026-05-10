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
    this.createdAt,
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final String? friendshipId;
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

class FriendSearchResult {
  const FriendSearchResult({
    required this.user,
    required this.relationshipStatus,
  });

  final FriendUser user;
  final FriendRelationshipStatus relationshipStatus;

  factory FriendSearchResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    return FriendSearchResult(
      user: userJson is Map<String, dynamic>
          ? FriendUser.fromJson(userJson)
          : const FriendUser(id: '', name: ''),
      relationshipStatus: FriendRelationshipStatus.fromJson(
        json['relationship_status'] as String?,
      ),
    );
  }

  FriendSearchResult copyWith({
    FriendUser? user,
    FriendRelationshipStatus? relationshipStatus,
  }) {
    return FriendSearchResult(
      user: user ?? this.user,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
    );
  }
}

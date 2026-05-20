part of 'friend_user.dart';

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

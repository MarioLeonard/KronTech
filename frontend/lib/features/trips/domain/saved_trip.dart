import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';

class SavedTrip {
  const SavedTrip({
    required this.id,
    required this.title,
    required this.summary,
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.itinerary,
    this.ownerUid,
    this.sharedWith = const [],
    this.friends = const [],
  });

  final String id;
  final String title;
  final String summary;
  final List<String> cities;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final GeneratedTrip? itinerary;
  final String? ownerUid;
  final List<String> sharedWith;
  final List<FriendUser> friends;

  factory SavedTrip.fromJson(Map<String, dynamic> json) {
    final itineraryJson = json['itinerary'];

    return SavedTrip(
      id: _readString(json, 'id', ''),
      title: _readString(json, 'title', 'Saved trip'),
      summary: _readString(json, 'summary', ''),
      cities: _readStringList(json['cities']),
      startDate: _readString(json, 'startDate', ''),
      endDate: _readString(json, 'endDate', ''),
      status: _readString(json, 'status', 'planned'),
      createdAt: _readString(json, 'createdAt', ''),
      ownerUid: _readOptionalString(json, 'ownerUid'),
      sharedWith: _readStringList(json['sharedWith']),
      friends: _readFriends(json['friends']),
      itinerary: itineraryJson is Map
          ? GeneratedTrip.fromJson(Map<String, dynamic>.from(itineraryJson))
          : null,
    );
  }

  SavedTrip copyWith({
    GeneratedTrip? itinerary,
    List<FriendUser>? friends,
    List<String>? sharedWith,
  }) {
    return SavedTrip(
      id: id,
      title: title,
      summary: summary,
      cities: cities,
      startDate: startDate,
      endDate: endDate,
      status: status,
      createdAt: createdAt,
      itinerary: itinerary ?? this.itinerary,
      ownerUid: ownerUid,
      sharedWith: sharedWith ?? this.sharedWith,
      friends: friends ?? this.friends,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'summary': summary,
      'cities': cities,
      'startDate': startDate,
      'endDate': endDate,
      'status': status,
      'createdAt': createdAt,
      if (ownerUid != null) 'ownerUid': ownerUid,
      'sharedWith': sharedWith,
      'friends': friends.map(_friendToJson).toList(),
      if (itinerary != null) 'itinerary': itinerary!.toJson(),
    };
  }
}

String _readString(Map<String, dynamic> json, String key, String fallback) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}

String? _readOptionalString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return null;
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<FriendUser> _readFriends(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => FriendUser.fromJson(Map<String, dynamic>.from(item)))
      .where((friend) => friend.id.isNotEmpty)
      .toList();
}

Map<String, dynamic> _friendToJson(FriendUser friend) {
  return {
    'id': friend.id,
    'uid': friend.id,
    'name': friend.name,
    if (friend.email != null) 'email': friend.email,
    if (friend.avatarUrl != null) 'avatar_url': friend.avatarUrl,
    if (friend.friendshipId != null) 'friendship_id': friend.friendshipId,
    if (friend.conversationId != null) 'conversation_id': friend.conversationId,
    if (friend.createdAt != null)
      'created_at': friend.createdAt!.toIso8601String(),
  };
}

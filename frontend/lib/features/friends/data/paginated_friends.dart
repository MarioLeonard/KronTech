part of 'friends_api_service.dart';

class PaginatedFriends {
  const PaginatedFriends({
    required this.friends,
    required this.page,
    required this.hasNext,
  });

  final List<FriendUser> friends;
  final int page;
  final bool hasNext;
}

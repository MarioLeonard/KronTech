part of 'friends_api_service.dart';

class FriendsApiException implements Exception {
  const FriendsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

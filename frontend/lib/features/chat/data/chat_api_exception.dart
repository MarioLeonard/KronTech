part of 'chat_api_service.dart';

class ChatApiException implements Exception {
  const ChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/chat/domain/chat_conversation.dart';
import 'package:frontend/features/chat/domain/chat_message.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  ChatApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? _readBackendBaseUrl());

  final http.Client _client;
  final Uri _baseUri;

  Future<List<ChatConversation>> fetchConversations({
    required String idToken,
    required String currentUserId,
  }) async {
    final response = await _client.get(
      _resolve('/api/chat/conversations/'),
      headers: _headers(idToken),
    );
    final body = _decode(response);
    _throwIfFailed(response, body);

    final data = body['data'];
    final conversations = data is Map<String, dynamic>
        ? data['conversations']
        : null;
    if (conversations is! List) {
      return <ChatConversation>[];
    }

    return conversations
        .whereType<Map<String, dynamic>>()
        .map(
          (json) =>
              ChatConversation.fromJson(json, currentUserId: currentUserId),
        )
        .where((conversation) => conversation.id.isNotEmpty)
        .toList();
  }

  Future<List<ChatMessage>> fetchMessages({
    required String idToken,
    required String currentUserId,
    required String conversationId,
  }) async {
    final response = await _client.get(
      _resolve('/api/chat/conversations/$conversationId/messages/'),
      headers: _headers(idToken),
    );
    final body = _decode(response);
    _throwIfFailed(response, body);

    final data = body['data'];
    final messages = data is Map<String, dynamic> ? data['messages'] : null;
    if (messages is! List) {
      return <ChatMessage>[];
    }

    return messages
        .whereType<Map<String, dynamic>>()
        .map((json) => ChatMessage.fromJson(json, currentUserId: currentUserId))
        .toList();
  }

  Future<void> markAsRead({
    required String idToken,
    required String conversationId,
  }) async {
    final response = await _client.post(
      _resolve('/api/chat/conversations/$conversationId/mark-read/'),
      headers: _headers(idToken),
    );
    final body = _decode(response);
    _throwIfFailed(response, body);
  }

  Uri websocketUri({required String conversationId, required String idToken}) {
    final scheme = _baseUri.scheme == 'https' ? 'wss' : 'ws';
    return _baseUri.replace(
      scheme: scheme,
      path: '/ws/chat/$conversationId/',
      queryParameters: {'token': idToken},
    );
  }

  Map<String, String> _headers(String idToken) {
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }

  Uri _resolve(String path) {
    return _baseUri.replace(path: path, queryParameters: const {});
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(response.body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  void _throwIfFailed(http.Response response, Map<String, dynamic> body) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    final message = body['message'] as String? ?? 'Chat request failed.';
    throw ChatApiException(message);
  }

  static String _readBackendBaseUrl() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return baseUrl;
    }
    return 'http://localhost:8000';
  }
}

class ChatApiException implements Exception {
  const ChatApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

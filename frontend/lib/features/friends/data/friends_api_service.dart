import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/friends/domain/friend_request.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';
import 'package:http/http.dart' as http;

class FriendsApiException implements Exception {
  const FriendsApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

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

class FriendsApiService {
  FriendsApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? _readBackendBaseUrl());

  final http.Client _client;
  final Uri _baseUri;

  Future<PaginatedFriends> fetchFriends({
    required String idToken,
    required int page,
    required int limit,
  }) async {
    final response = await _client
        .get(
          _resolve('/api/friends/', {'page': '$page', 'limit': '$limit'}),
          headers: _headers(idToken),
        )
        .timeout(const Duration(seconds: 30));
    final body = _decodeResponse(response.body);
    _throwIfFailed(response, body);

    final data = _readData(body);
    final friends = data['friends'];
    return PaginatedFriends(
      friends: friends is List
          ? friends
                .whereType<Map>()
                .map(
                  (item) =>
                      FriendUser.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((user) => user.id.isNotEmpty)
                .toList()
          : const [],
      page: data['page'] as int? ?? page,
      hasNext: data['has_next'] as bool? ?? false,
    );
  }

  Future<List<FriendSearchResult>> searchUsers({
    required String idToken,
    required String query,
  }) async {
    final response = await _client
        .get(
          _resolve('/api/friends/search/', {'q': query}),
          headers: _headers(idToken),
        )
        .timeout(const Duration(seconds: 30));
    final body = _decodeResponse(response.body);
    _throwIfFailed(response, body);

    final results = _readData(body)['results'];
    if (results is! List) {
      return const [];
    }
    return results
        .whereType<Map>()
        .map(
          (item) =>
              FriendSearchResult.fromJson(Map<String, dynamic>.from(item)),
        )
        .where((result) => result.user.id.isNotEmpty)
        .toList();
  }

  Future<List<FriendRequest>> fetchRequests({required String idToken}) async {
    final response = await _client
        .get(_resolve('/api/friends/requests/'), headers: _headers(idToken))
        .timeout(const Duration(seconds: 30));
    final body = _decodeResponse(response.body);
    _throwIfFailed(response, body);

    final requests = _readData(body)['requests'];
    if (requests is! List) {
      return const [];
    }
    return requests
        .whereType<Map>()
        .map((item) => FriendRequest.fromJson(Map<String, dynamic>.from(item)))
        .where((request) => request.id.isNotEmpty)
        .toList();
  }

  Future<void> sendRequest({
    required String idToken,
    required String receiverId,
  }) async {
    final response = await _client
        .post(
          _resolve('/api/friends/requests/'),
          headers: _headers(idToken),
          body: jsonEncode({'receiver_id': receiverId}),
        )
        .timeout(const Duration(seconds: 30));
    _throwIfFailed(response, _decodeResponse(response.body));
  }

  Future<void> acceptRequest({
    required String idToken,
    required String requestId,
  }) async {
    final response = await _client
        .post(
          _resolve('/api/friends/requests/$requestId/accept/'),
          headers: _headers(idToken),
        )
        .timeout(const Duration(seconds: 30));
    _throwIfFailed(response, _decodeResponse(response.body));
  }

  Future<void> declineRequest({
    required String idToken,
    required String requestId,
  }) async {
    final response = await _client
        .post(
          _resolve('/api/friends/requests/$requestId/decline/'),
          headers: _headers(idToken),
        )
        .timeout(const Duration(seconds: 30));
    _throwIfFailed(response, _decodeResponse(response.body));
  }

  Future<void> removeFriend({
    required String idToken,
    required String friendId,
  }) async {
    final response = await _client
        .delete(_resolve('/api/friends/$friendId/'), headers: _headers(idToken))
        .timeout(const Duration(seconds: 30));
    _throwIfFailed(response, _decodeResponse(response.body));
  }

  Uri _resolve(String path, [Map<String, String>? queryParameters]) {
    return _baseUri.replace(path: path, queryParameters: queryParameters);
  }

  Map<String, String> _headers(String idToken) {
    return {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    };
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }
    final decoded = jsonDecode(body);
    return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
  }

  Map<String, dynamic> _readData(Map<String, dynamic> body) {
    final data = body['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  void _throwIfFailed(http.Response response, Map<String, dynamic> body) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final message =
        body['message'] as String? ?? 'The operation could not be completed.';
    throw FriendsApiException(message);
  }

  static String _readBackendBaseUrl() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      if (kDebugMode) {
        debugPrint('BACKEND_BASE_URL missing; using http://localhost:8000.');
      }
      return 'http://localhost:8000';
    }
    return baseUrl;
  }
}

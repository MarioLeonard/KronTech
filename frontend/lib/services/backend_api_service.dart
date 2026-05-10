import 'dart:convert';

import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/models/user_profile.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BackendApiService {
  BackendApiService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? _readBackendBaseUrl());

  final http.Client _client;
  final Uri _baseUri;

  Future<UserProfile> syncAuthenticatedUser(String idToken) async {
    final response = await _client.post(
      _resolve('/api/signup/'),
      headers: {'Authorization': 'Bearer $idToken'},
    );

    final responseBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        code: 'backend_sync_failed',
        message: _readErrorMessage(responseBody),
      );
    }

    final profile = responseBody['profile'];
    if (profile is! Map<String, dynamic>) {
      throw const AuthException(
        code: 'invalid_backend_profile',
        message: 'The backend did not return a valid profile.',
      );
    }

    return UserProfile.fromJson(profile);
  }

  Future<UserProfile> completeOnboarding({
    required String idToken,
    required UserModel user,
  }) async {
    final response = await _client.post(
      _resolve('/api/onboarding/complete/'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(user.toMap()),
    );

    final responseBody = _decodeResponse(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthException(
        code: 'onboarding_sync_failed',
        message: _readErrorMessage(responseBody),
      );
    }

    final profile = responseBody['profile'];
    if (profile is! Map<String, dynamic>) {
      throw const AuthException(
        code: 'invalid_backend_profile',
        message: 'The backend did not return a valid profile.',
      );
    }

    return UserProfile.fromJson(profile);
  }

  Uri _resolve(String path) {
    return _baseUri.replace(path: path);
  }

  Map<String, dynamic> _decodeResponse(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    return <String, dynamic>{};
  }

  String _readErrorMessage(Map<String, dynamic> body) {
    final message = body['message'] ?? body['error'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return 'Could not sync the account with the backend.';
  }

  static String _readBackendBaseUrl() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl != null && baseUrl.isNotEmpty) {
      return baseUrl;
    }

    // Provide a sensible default based on the environment
    return 'http://localhost:8000';
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:http/http.dart' as http;

class SavedTripsException implements Exception {
  const SavedTripsException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackendSavedTripsService {
  BackendSavedTripsService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? _readBackendBaseUrl());

  final http.Client _client;
  final Uri _baseUri;

  Future<List<SavedTrip>> fetchTrips(String idToken) async {
    try {
      final response = await _client
          .get(
            _resolve('/api/trips/'),
            headers: {'Authorization': 'Bearer $idToken'},
          )
          .timeout(const Duration(seconds: 30));

      _log(
        'Fetch trips response. status=${response.statusCode}, body=${_truncate(response.body)}',
      );

      final body = _decodeResponse(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SavedTripsException(_readErrorMessage(body));
      }

      final trips = body['trips'];
      if (trips is! List) {
        return const [];
      }

      return trips
          .whereType<Map>()
          .map((trip) => SavedTrip.fromJson(Map<String, dynamic>.from(trip)))
          .where((trip) => trip.id.isNotEmpty)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } on TimeoutException {
      throw const SavedTripsException(
        'Incarcarea tripurilor a durat prea mult.',
      );
    } on SavedTripsException {
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected fetch trips error: $error\n$stackTrace');
      throw const SavedTripsException('Nu am putut incarca tripurile salvate.');
    }
  }

  Future<void> deleteTrip({
    required String idToken,
    required String tripId,
  }) async {
    try {
      final response = await _client
          .delete(
            _resolve('/api/trips/$tripId/'),
            headers: {'Authorization': 'Bearer $idToken'},
          )
          .timeout(const Duration(seconds: 30));

      _log(
        'Delete trip response. status=${response.statusCode}, body=${_truncate(response.body)}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw SavedTripsException(
          _readErrorMessage(_decodeResponse(response.body)),
        );
      }
    } on TimeoutException {
      throw const SavedTripsException('Stergerea a durat prea mult.');
    } on SavedTripsException {
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected delete trip error: $error\n$stackTrace');
      throw const SavedTripsException('Nu am putut sterge tripul.');
    }
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
    return 'Operatia nu a putut fi finalizata.';
  }

  String _truncate(String value, {int maxLength = 3000}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}... [truncated ${value.length - maxLength} chars]';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[BackendSavedTripsService] $message');
    }
  }

  static String _readBackendBaseUrl() {
    final baseUrl = dotenv.env['BACKEND_BASE_URL'];
    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError('BACKEND_BASE_URL is missing from frontend/.env.');
    }
    return baseUrl;
  }
}

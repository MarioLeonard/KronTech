import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/trips/domain/saved_trip.dart';
import 'package:frontend/utils/hive_service.dart';
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

  Future<List<SavedTrip>> fetchTrips({
    required String idToken,
    required String userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final cachedTrips = _readCachedTripsOrNull(userId);
      if (cachedTrips != null) {
        _log('Loaded ${cachedTrips.length} trips from Hive cache.');
        return cachedTrips;
      }
    }

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

      final tripsJson = body['trips'];
      if (tripsJson is! List) {
        return const [];
      }

      await _writeCachedTrips(userId: userId, tripsJson: tripsJson);
      return _parseTrips(tripsJson);
    } on TimeoutException {
      throw const SavedTripsException('Loading trips took too long.');
    } on SavedTripsException {
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected fetch trips error: $error\n$stackTrace');
      throw const SavedTripsException('We could not load saved trips.');
    }
  }

  Future<void> deleteTrip({
    required String idToken,
    required String userId,
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
      await _removeCachedTrip(userId: userId, tripId: tripId);
    } on TimeoutException {
      throw const SavedTripsException('Deleting took too long.');
    } on SavedTripsException {
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected delete trip error: $error\n$stackTrace');
      throw const SavedTripsException('We could not delete the trip.');
    }
  }

  List<SavedTrip> readCachedTrips(String userId) {
    return _readCachedTripsOrNull(userId) ?? const [];
  }

  List<SavedTrip>? _readCachedTripsOrNull(String userId) {
    final cacheEntry = _readCacheEntry(userId);
    final tripsJson = cacheEntry['trips'];
    if (tripsJson is! List) {
      return null;
    }
    return _parseTrips(tripsJson);
  }

  List<SavedTrip> _parseTrips(List<dynamic> tripsJson) {
    return tripsJson
        .whereType<Map>()
        .map((trip) => SavedTrip.fromJson(Map<String, dynamic>.from(trip)))
        .where((trip) => trip.id.isNotEmpty)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Map<String, dynamic> _readCacheEntry(String userId) {
    final cached = HiveService.getSavedTripsBox().get(_cacheKey(userId));
    if (cached is Map) {
      return Map<String, dynamic>.from(cached);
    }
    return <String, dynamic>{};
  }

  Future<void> _writeCachedTrips({
    required String userId,
    required List<dynamic> tripsJson,
  }) async {
    await HiveService.getSavedTripsBox().put(_cacheKey(userId), {
      'updatedAt': DateTime.now().toIso8601String(),
      'trips': tripsJson
          .whereType<Map>()
          .map((trip) => Map<String, dynamic>.from(trip))
          .toList(),
    });
  }

  Future<void> _removeCachedTrip({
    required String userId,
    required String tripId,
  }) async {
    final cacheEntry = _readCacheEntry(userId);
    final tripsJson = cacheEntry['trips'];
    if (tripsJson is! List) {
      return;
    }

    final nextTrips = tripsJson
        .whereType<Map>()
        .map((trip) => Map<String, dynamic>.from(trip))
        .where((trip) => trip['id'] != tripId)
        .toList();
    await _writeCachedTrips(userId: userId, tripsJson: nextTrips);
  }

  String _cacheKey(String userId) {
    return 'saved_trips_$userId';
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
    return 'The operation could not be completed.';
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

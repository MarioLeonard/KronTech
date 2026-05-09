import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:http/http.dart' as http;

class TripGenerationException implements Exception {
  const TripGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class BackendTripGenerationService {
  BackendTripGenerationService({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUri = Uri.parse(baseUrl ?? _readBackendBaseUrl());

  final http.Client _client;
  final Uri _baseUri;

  Future<GeneratedTrip> generateTrip({
    required TripCreationRequest request,
    required String idToken,
  }) async {
    final uri = _resolve('/api/trips/generate/');

    try {
      _log(
        'Starting backend trip generation request. '
        'endpoint=$uri, cities=${request.cities.join(', ')}, '
        'start=${request.toJson()['startDate']}, end=${request.toJson()['endDate']}',
      );

      final response = await _client
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $idToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 70));

      _log(
        'Backend trip generation response. '
        'status=${response.statusCode}, body=${_truncate(response.body)}',
      );

      final responseBody = _decodeResponse(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw TripGenerationException(_readErrorMessage(responseBody));
      }

      final tripJson = responseBody['trip'];
      if (tripJson is! Map<String, dynamic>) {
        throw const TripGenerationException(
          'Backend-ul nu a returnat un itinerariu valid.',
        );
      }

      final trip = GeneratedTrip.fromJson(tripJson);
      if (!trip.hasUsefulContent) {
        throw const TripGenerationException(
          'Raspunsul primit nu contine un itinerariu util. Incearca din nou.',
        );
      }

      return trip;
    } on TimeoutException {
      throw const TripGenerationException(
        'Generarea a durat prea mult. Incearca din nou.',
      );
    } on FormatException catch (error) {
      _log('Backend trip JSON parsing failed: $error');
      throw const TripGenerationException(
        'Backend-ul nu a returnat JSON valid.',
      );
    } on TripGenerationException catch (error) {
      _log('TripGenerationException: ${error.message}');
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected backend trip error: $error\n$stackTrace');
      throw const TripGenerationException(
        'Nu am putut genera excursia acum. Verifica conexiunea si incearca din nou.',
      );
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

    return 'Backend-ul nu a putut genera excursia.';
  }

  String _truncate(String value, {int maxLength = 4000}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}... [truncated ${value.length - maxLength} chars]';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[BackendTripGenerationService] $message');
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

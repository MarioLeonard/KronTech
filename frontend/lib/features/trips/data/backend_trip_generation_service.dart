import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:http/http.dart' as http;
part 'trip_generation_exception.dart';

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
          'The backend did not return a valid itinerary.',
        );
      }

      final trip = GeneratedTrip.fromJson(tripJson);
      if (!trip.hasUsefulContent) {
        throw const TripGenerationException(
          'The response did not contain a useful itinerary. Please try again.',
        );
      }

      return trip;
    } on TimeoutException {
      throw const TripGenerationException(
        'Generation took too long. Please try again.',
      );
    } on FormatException catch (error) {
      _log('Backend trip JSON parsing failed: $error');
      throw const TripGenerationException(
        'The backend did not return valid JSON.',
      );
    } on TripGenerationException catch (error) {
      _log('TripGenerationException: ${error.message}');
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected backend trip error: $error\n$stackTrace');
      throw const TripGenerationException(
        'We could not generate the trip right now. Check your connection and try again.',
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

    return 'The backend could not generate the trip.';
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

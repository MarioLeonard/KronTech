import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/domain/trip_creation_request.dart';
import 'package:http/http.dart' as http;

class GeminiTripException implements Exception {
  const GeminiTripException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiTripService {
  GeminiTripService({http.Client? client}) : _client = client ?? http.Client();

  static const _defaultModel = 'gemini-2.5-flash';
  static const _endpointHost = 'generativelanguage.googleapis.com';

  final http.Client _client;

  Future<GeneratedTrip> generateTrip(TripCreationRequest request) async {
    final apiKey = dotenv.env['GEMINI_API_KEY']?.trim();
    if (apiKey == null || apiKey.isEmpty) {
      throw const GeminiTripException(
        'Configuratia Gemini lipseste. Verifica GEMINI_API_KEY.',
      );
    }

    final model = dotenv.env['GEMINI_MODEL']?.trim().isNotEmpty == true
        ? dotenv.env['GEMINI_MODEL']!.trim()
        : _defaultModel;
    final uri = Uri.https(
      _endpointHost,
      '/v1beta/models/$model:generateContent',
      {'key': apiKey},
    );
    final requestBody = _buildRequestBody(request);

    try {
      _log(
        'Starting Gemini request. '
        'model=$model, endpoint=${uri.removeFragment().replace(query: '')}, '
        'apiKey=${_maskApiKey(apiKey)}, cities=${request.cities.join(', ')}, '
        'start=${request.toJson()['startDate']}, end=${request.toJson()['endDate']}',
      );

      final response = await _client
          .post(
            uri,
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 60));

      _log(
        'Gemini response received. '
        'status=${response.statusCode}, body=${_truncate(response.body)}',
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final apiMessage = _readFriendlyErrorMessage(
          response.statusCode,
          response.body,
        );
        throw GeminiTripException(
          'Gemini a returnat o eroare (${response.statusCode})'
          '${apiMessage == null ? '' : ': $apiMessage'}',
        );
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const GeminiTripException(
          'Raspunsul Gemini nu a avut formatul asteptat.',
        );
      }

      final generatedText = _extractGeneratedText(decoded);
      _log('Gemini generated text: ${_truncate(generatedText)}');
      final jsonText = _stripCodeFence(generatedText);
      final itineraryJson = jsonDecode(jsonText);
      if (itineraryJson is! Map<String, dynamic>) {
        throw const GeminiTripException(
          'Raspunsul primit nu a avut formatul asteptat.',
        );
      }

      final trip = GeneratedTrip.fromJson(itineraryJson);
      if (!trip.hasUsefulContent) {
        throw const GeminiTripException(
          'Raspunsul primit nu contine un itinerariu util. Incearca din nou.',
        );
      }

      return trip;
    } on TimeoutException {
      _log('Gemini request timed out after 60 seconds.');
      throw const GeminiTripException(
        'Generarea a durat prea mult. Verifica conexiunea si incearca din nou.',
      );
    } on FormatException catch (error) {
      _log('Gemini JSON parsing failed: $error');
      throw const GeminiTripException(
        'Raspunsul primit nu a avut formatul JSON asteptat. Incearca din nou.',
      );
    } on GeminiTripException catch (error) {
      _log('GeminiTripException: ${error.message}');
      rethrow;
    } catch (error, stackTrace) {
      _log('Unexpected Gemini error: $error\n$stackTrace');
      throw const GeminiTripException(
        'Nu am putut genera excursia acum. Verifica conexiunea si incearca din nou.',
      );
    }
  }

  Map<String, dynamic> _buildRequestBody(TripCreationRequest request) {
    return {
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': _buildPrompt(request)},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'responseMimeType': 'application/json',
      },
    };
  }

  String _extractGeneratedText(Map<String, dynamic> response) {
    final candidates = response['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GeminiTripException('Gemini nu a returnat continut.');
    }

    final first = candidates.first;
    if (first is! Map) {
      throw const GeminiTripException('Gemini a returnat continut invalid.');
    }

    final content = first['content'];
    if (content is! Map) {
      throw const GeminiTripException('Gemini a returnat continut invalid.');
    }

    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) {
      throw const GeminiTripException('Gemini nu a returnat text.');
    }

    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['text'] is String) {
        buffer.write(part['text']);
      }
    }

    final text = buffer.toString().trim();
    if (text.isEmpty) {
      throw const GeminiTripException('Gemini nu a returnat text.');
    }
    return text;
  }

  String _stripCodeFence(String value) {
    var text = value.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return text.trim();
  }

  String? _readFriendlyErrorMessage(int statusCode, String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is Map) {
          final status = error['status'];
          final message = error['message'];
          final retryDelay = _readRetryDelay(error['details']);

          if (statusCode == 429 || status == 'RESOURCE_EXHAUSTED') {
            return 'quota Gemini este depasita sau indisponibila pentru modelul configurat. '
                'Verifica planul, billing-ul si limitele proiectului in Google AI Studio.'
                '${retryDelay == null ? '' : ' Reincearca dupa $retryDelay.'}';
          }

          if (message is String && message.trim().isNotEmpty) {
            return message.trim();
          }
        }
      }
    } catch (_) {
      return null;
    }
    return null;
  }

  String? _readRetryDelay(Object? details) {
    if (details is! List) {
      return null;
    }

    for (final item in details) {
      if (item is Map && item['retryDelay'] is String) {
        return item['retryDelay'] as String;
      }
    }
    return null;
  }

  String _maskApiKey(String apiKey) {
    if (apiKey.length <= 8) {
      return '***';
    }
    return '${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}';
  }

  String _truncate(String value, {int maxLength = 4000}) {
    if (value.length <= maxLength) {
      return value;
    }
    return '${value.substring(0, maxLength)}... [truncated ${value.length - maxLength} chars]';
  }

  void _log(String message) {
    if (kDebugMode) {
      debugPrint('[GeminiTripService] $message');
    }
  }

  String _buildPrompt(TripCreationRequest request) {
    final requestJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(request.toJson());

    return '''
You are a travel planning assistant. Generate a practical, day-by-day trip itinerary.

Return ONLY valid JSON. Do not include markdown, comments, explanations, or text outside the JSON object.

User request JSON:
$requestJson

Important requirements:
- Organize the itinerary by day.
- Include recommended activities with approximate time ranges.
- Include approximate cost for each activity and each day.
- Include approximate distances in kilometers between objectives.
- Include approximate travel duration between locations.
- Include recommended accommodation options.
- For Booking or Airbnb, if you do not have a real API integration or live availability, mark them clearly as search suggestions and provide search URLs, not claims of availability.
- Include restaurants or places to eat.
- Costs, distances, and durations are estimates and must be marked as approximate.
- Prefer realistic pacing. Do not overload days.
- Avoid inventing exact live prices or availability.
- If information is uncertain, include it in assumptions or warnings.
- Use Romanian for all human-readable strings.

JSON schema:
{
  "title": "string",
  "summary": "string",
  "cities": ["string"],
  "startDate": "YYYY-MM-DD",
  "endDate": "YYYY-MM-DD",
  "currency": "string",
  "costSummary": {
    "estimatedTotal": 0,
    "estimatedActivitiesTotal": 0,
    "estimatedFoodTotal": 0,
    "estimatedAccommodationTotal": 0,
    "note": "string"
  },
  "distanceSummary": {
    "estimatedTotalKm": 0,
    "estimatedTotalTransitDuration": "string",
    "note": "string"
  },
  "days": [
    {
      "dayNumber": 1,
      "date": "YYYY-MM-DD",
      "title": "string",
      "city": "string",
      "summary": "string",
      "estimatedCost": 0,
      "estimatedDistanceKm": 0,
      "estimatedTransitDuration": "string",
      "activities": [
        {
          "timeRange": "string",
          "title": "string",
          "location": "string",
          "description": "string",
          "estimatedCost": 0,
          "costNote": "string",
          "distanceFromPreviousKm": 0,
          "travelTimeFromPrevious": "string",
          "transportMode": "walking/public_transport/taxi/car/train/other",
          "tags": ["string"]
        }
      ],
      "mealSuggestions": ["string"]
    }
  ],
  "accommodations": [
    {
      "name": "string",
      "city": "string",
      "area": "string",
      "type": "hotel/apartment/hostel/guesthouse/other",
      "estimatedNightlyCost": 0,
      "source": "Booking/Airbnb/Search suggestion/Other",
      "bookingSearchUrl": "string",
      "airbnbSearchUrl": "string",
      "isSearchSuggestion": true,
      "note": "string"
    }
  ],
  "restaurants": [
    {
      "name": "string",
      "city": "string",
      "area": "string",
      "cuisine": "string",
      "recommendedFor": "breakfast/lunch/dinner/snack",
      "estimatedMealCost": 0,
      "note": "string"
    }
  ],
  "assumptions": ["string"],
  "warnings": ["string"]
}

Validation rules:
- Return at least one day.
- Return at least two activities per day unless the trip duration makes that impossible.
- Use numeric values for costs and distances.
- Keep URLs as search URLs when live availability cannot be verified.
''';
  }
}

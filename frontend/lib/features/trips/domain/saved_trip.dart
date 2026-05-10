import 'package:frontend/features/trips/domain/generated_trip.dart';

class SavedTrip {
  const SavedTrip({
    required this.id,
    required this.title,
    required this.summary,
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.createdAt,
    required this.itinerary,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> cities;
  final String startDate;
  final String endDate;
  final String status;
  final String createdAt;
  final GeneratedTrip? itinerary;

  factory SavedTrip.fromJson(Map<String, dynamic> json) {
    final itineraryJson = json['itinerary'];

    return SavedTrip(
      id: _readString(json, 'id', ''),
      title: _readString(json, 'title', 'Excursie salvata'),
      summary: _readString(json, 'summary', ''),
      cities: _readStringList(json['cities']),
      startDate: _readString(json, 'startDate', ''),
      endDate: _readString(json, 'endDate', ''),
      status: _readString(json, 'status', 'planned'),
      createdAt: _readString(json, 'createdAt', ''),
      itinerary: itineraryJson is Map
          ? GeneratedTrip.fromJson(Map<String, dynamic>.from(itineraryJson))
          : null,
    );
  }
}

String _readString(Map<String, dynamic> json, String key, String fallback) {
  final value = json[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}

List<String> _readStringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

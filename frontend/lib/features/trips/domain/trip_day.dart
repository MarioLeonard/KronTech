import 'package:frontend/features/trips/domain/trip_activity.dart';

class TripDay {
  const TripDay({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.city,
    required this.summary,
    required this.estimatedCost,
    required this.estimatedDistanceKm,
    required this.estimatedTransitDuration,
    required this.activities,
    required this.mealSuggestions,
  });

  final int dayNumber;
  final String date;
  final String title;
  final String city;
  final String summary;
  final num estimatedCost;
  final num estimatedDistanceKm;
  final String estimatedTransitDuration;
  final List<TripActivity> activities;
  final List<String> mealSuggestions;

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      dayNumber: _readInt(json, 'dayNumber'),
      date: _readString(json, 'date', 'Data nespecificata'),
      title: _readString(json, 'title', 'Trip day'),
      city: _readString(json, 'city', 'City unspecified'),
      summary: _readString(json, 'summary', 'Summary unavailable.'),
      estimatedCost: _readNum(json, 'estimatedCost'),
      estimatedDistanceKm: _readNum(json, 'estimatedDistanceKm'),
      estimatedTransitDuration: _readString(
        json,
        'estimatedTransitDuration',
        'Duration unavailable',
      ),
      activities: _readActivities(json['activities']),
      mealSuggestions: _readStringList(json['mealSuggestions']),
    );
  }

  TripDay copyWith({List<TripActivity>? activities}) {
    return TripDay(
      dayNumber: dayNumber,
      date: date,
      title: title,
      city: city,
      summary: summary,
      estimatedCost: estimatedCost,
      estimatedDistanceKm: estimatedDistanceKm,
      estimatedTransitDuration: estimatedTransitDuration,
      activities: activities ?? this.activities,
      mealSuggestions: mealSuggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'date': date,
      'title': title,
      'city': city,
      'summary': summary,
      'estimatedCost': estimatedCost,
      'estimatedDistanceKm': estimatedDistanceKm,
      'estimatedTransitDuration': estimatedTransitDuration,
      'activities': activities.map((activity) => activity.toJson()).toList(),
      'mealSuggestions': mealSuggestions,
    };
  }
}

List<TripActivity> _readActivities(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => TripActivity.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

int _readInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

num _readNum(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is num) {
    return value;
  }
  if (value is String) {
    return num.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
  return 0;
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

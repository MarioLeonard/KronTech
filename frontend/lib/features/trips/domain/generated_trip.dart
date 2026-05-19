import 'package:frontend/features/trips/domain/dining_option.dart';
import 'package:frontend/features/trips/domain/stay_option.dart';
import 'package:frontend/features/trips/domain/trip_day.dart';
import 'package:frontend/features/trips/domain/trip_summary.dart';

class GeneratedTrip {
  const GeneratedTrip({
    required this.title,
    required this.summary,
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.currency,
    required this.destinationImageUrl,
    required this.costSummary,
    required this.distanceSummary,
    required this.days,
    required this.accommodations,
    required this.restaurants,
    required this.assumptions,
    required this.warnings,
  });

  final String title;
  final String summary;
  final List<String> cities;
  final String startDate;
  final String endDate;
  final String currency;
  final String destinationImageUrl;
  final TripCostSummary costSummary;
  final TripDistanceSummary distanceSummary;
  final List<TripDay> days;
  final List<StayOption> accommodations;
  final List<DiningOption> restaurants;
  final List<String> assumptions;
  final List<String> warnings;

  factory GeneratedTrip.fromJson(Map<String, dynamic> json) {
    return GeneratedTrip(
      title: _readString(json, 'title', 'Excursie generata'),
      summary: _readString(json, 'summary', 'Itinerariu generat cu AI.'),
      cities: _readStringList(json['cities']),
      startDate: _readString(json, 'startDate', ''),
      endDate: _readString(json, 'endDate', ''),
      currency: _readString(json, 'currency', 'EUR'),
      destinationImageUrl: _readString(json, 'destinationImageUrl', ''),
      costSummary: TripCostSummary.fromJson(_readMap(json['costSummary'])),
      distanceSummary: TripDistanceSummary.fromJson(
        _readMap(json['distanceSummary']),
      ),
      days: _readDays(json['days']),
      accommodations: _readStays(json['accommodations']),
      restaurants: _readDining(json['restaurants']),
      assumptions: _readStringList(json['assumptions']),
      warnings: _readStringList(json['warnings']),
    );
  }

  bool get hasUsefulContent {
    return days.isNotEmpty && days.any((day) => day.activities.isNotEmpty);
  }
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}

List<TripDay> _readDays(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => TripDay.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<StayOption> _readStays(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => StayOption.fromJson(Map<String, dynamic>.from(item)))
      .toList();
}

List<DiningOption> _readDining(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value
      .whereType<Map>()
      .map((item) => DiningOption.fromJson(Map<String, dynamic>.from(item)))
      .toList();
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

part of 'trip_summary.dart';

class TripDistanceSummary {
  const TripDistanceSummary({
    required this.estimatedTotalKm,
    required this.estimatedTotalTransitDuration,
    required this.note,
  });

  final num estimatedTotalKm;
  final String estimatedTotalTransitDuration;
  final String note;

  factory TripDistanceSummary.fromJson(Map<String, dynamic>? json) {
    return TripDistanceSummary(
      estimatedTotalKm: _readNum(json, 'estimatedTotalKm'),
      estimatedTotalTransitDuration: _readString(
        json,
        'estimatedTotalTransitDuration',
        'Duration unavailable',
      ),
      note: _readString(json, 'note', 'Distantele sunt aproximative.'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedTotalKm': estimatedTotalKm,
      'estimatedTotalTransitDuration': estimatedTotalTransitDuration,
      'note': note,
    };
  }
}

num _readNum(Map<String, dynamic>? json, String key) {
  final value = json?[key];
  if (value is num) {
    return value;
  }
  if (value is String) {
    return num.tryParse(value.replaceAll(',', '.')) ?? 0;
  }
  return 0;
}

String _readString(Map<String, dynamic>? json, String key, String fallback) {
  final value = json?[key];
  if (value is String && value.trim().isNotEmpty) {
    return value.trim();
  }
  return fallback;
}

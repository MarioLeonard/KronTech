class TripCostSummary {
  const TripCostSummary({
    required this.estimatedTotal,
    required this.estimatedActivitiesTotal,
    required this.estimatedFoodTotal,
    required this.estimatedAccommodationTotal,
    required this.note,
  });

  final num estimatedTotal;
  final num estimatedActivitiesTotal;
  final num estimatedFoodTotal;
  final num estimatedAccommodationTotal;
  final String note;

  factory TripCostSummary.fromJson(Map<String, dynamic>? json) {
    return TripCostSummary(
      estimatedTotal: _readNum(json, 'estimatedTotal'),
      estimatedActivitiesTotal: _readNum(json, 'estimatedActivitiesTotal'),
      estimatedFoodTotal: _readNum(json, 'estimatedFoodTotal'),
      estimatedAccommodationTotal: _readNum(
        json,
        'estimatedAccommodationTotal',
      ),
      note: _readString(json, 'note', 'Costurile sunt estimative.'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedTotal': estimatedTotal,
      'estimatedActivitiesTotal': estimatedActivitiesTotal,
      'estimatedFoodTotal': estimatedFoodTotal,
      'estimatedAccommodationTotal': estimatedAccommodationTotal,
      'note': note,
    };
  }
}

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

part 'trip_distance_summary.dart';

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

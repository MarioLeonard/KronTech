import 'package:frontend/features/trips/domain/trip_interest.dart';

class TripCreationRequest {
  const TripCreationRequest({
    required this.cities,
    required this.startDate,
    required this.endDate,
    required this.interests,
    this.locale = 'ro-RO',
    this.currency = 'EUR',
    this.distanceUnit = 'km',
  });

  final List<String> cities;
  final DateTime startDate;
  final DateTime endDate;
  final List<TripInterest> interests;
  final String locale;
  final String currency;
  final String distanceUnit;

  Map<String, dynamic> toJson() {
    return {
      'cities': cities,
      'startDate': _formatDate(startDate),
      'endDate': _formatDate(endDate),
      'interests': interests.map((interest) => interest.value).toList(),
      'locale': locale,
      'currency': currency,
      'distanceUnit': distanceUnit,
    };
  }

  static String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

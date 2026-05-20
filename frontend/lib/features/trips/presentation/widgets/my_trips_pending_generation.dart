part of '../screens/my_trips_screen.dart';

class _PendingTripGeneration {
  _PendingTripGeneration({
    required this.id,
    required this.destination,
    required this.dateLabel,
    required this.subtitle,
  });

  factory _PendingTripGeneration.fromRequest(TripCreationRequest request) {
    final destination = request.cities
        .map((city) => city.trim())
        .where((city) => city.isNotEmpty)
        .join(', ');
    final safeDestination = destination.isEmpty ? 'New trip' : destination;
    final dayCount =
        request.endDate.difference(request.startDate).inDays.abs() + 1;

    return _PendingTripGeneration(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      destination: safeDestination,
      dateLabel: _formatPendingTripRange(request.startDate, request.endDate),
      subtitle:
          'Itinerary of $dayCount ${dayCount == 1 ? 'day' : 'days'} in $safeDestination',
    );
  }

  final String id;
  final String destination;
  final String dateLabel;
  final String subtitle;
}

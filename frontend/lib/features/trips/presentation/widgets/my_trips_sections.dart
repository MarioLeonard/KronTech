part of '../screens/my_trips_screen.dart';

class _TripsSections extends StatelessWidget {
  const _TripsSections({
    required this.trips,
    required this.pendingGenerations,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final List<SavedTrip> trips;
  final List<_PendingTripGeneration> pendingGenerations;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final upcoming = trips.where((trip) => !trip.isPast).toList();
    final past = trips.where((trip) => trip.isPast).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TripsSection(
          title: 'Upcoming trips',
          trips: upcoming,
          pendingGenerations: pendingGenerations,
          onOpenTrip: onOpenTrip,
          activeHeroTripTag: activeHeroTripTag,
        ),
        const SizedBox(height: 28),
        _TripsSection(
          title: 'Past trips',
          trips: past,
          pendingGenerations: const [],
          onOpenTrip: onOpenTrip,
          activeHeroTripTag: activeHeroTripTag,
        ),
      ],
    );
  }
}

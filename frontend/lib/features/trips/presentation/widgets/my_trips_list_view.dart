part of '../screens/my_trips_screen.dart';

class _TripsListView extends StatelessWidget {
  const _TripsListView({
    required this.provider,
    required this.pendingGenerations,
    required this.onAddTrip,
    required this.onRetry,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final SavedTripsProvider provider;
  final List<_PendingTripGeneration> pendingGenerations;
  final VoidCallback onAddTrip;
  final VoidCallback onRetry;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final hasTripsOrPending =
        provider.trips.isNotEmpty || pendingGenerations.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _TripsHero(onAddTrip: onAddTrip),
              const SizedBox(height: 28),
              switch (provider.status) {
                SavedTripsStatus.idle || SavedTripsStatus.loading =>
                  hasTripsOrPending
                      ? _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        )
                      : const _TripsLoadingCard(),
                SavedTripsStatus.error =>
                  hasTripsOrPending
                      ? _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        )
                      : _TripsErrorCard(
                          message:
                              provider.errorMessage ??
                              'Could not load saved trips.',
                          onRetry: onRetry,
                        ),
                SavedTripsStatus.success =>
                  !hasTripsOrPending
                      ? _TripsEmptyCard(onAddTrip: onAddTrip)
                      : _TripsSections(
                          trips: provider.trips,
                          pendingGenerations: pendingGenerations,
                          onOpenTrip: onOpenTrip,
                          activeHeroTripTag: activeHeroTripTag,
                        ),
              },
            ],
          ),
        ),
      ),
    );
  }
}

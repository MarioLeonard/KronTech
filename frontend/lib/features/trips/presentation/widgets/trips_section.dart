part of '../screens/my_trips_screen.dart';

class _TripsSection extends StatelessWidget {
  const _TripsSection({
    required this.title,
    required this.trips,
    required this.pendingGenerations,
    required this.onOpenTrip,
    required this.activeHeroTripTag,
  });

  final String title;
  final List<SavedTrip> trips;
  final List<_PendingTripGeneration> pendingGenerations;
  final ValueChanged<SavedTrip> onOpenTrip;
  final String? activeHeroTripTag;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itemCount = trips.length + pendingGenerations.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 10),
            _CountPill(count: itemCount),
          ],
        ),
        const SizedBox(height: 12),
        if (itemCount == 0)
          _SectionEmptyState(title: title)
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1080
                  ? 4
                  : constraints.maxWidth >= 760
                  ? 3
                  : constraints.maxWidth >= 520
                  ? 2
                  : 1;

              return GridView.builder(
                itemCount: itemCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  mainAxisExtent: columns == 1 ? 226 : 268,
                ),
                itemBuilder: (context, index) {
                  if (index < pendingGenerations.length) {
                    return _GeneratingTripCard(
                      pending: pendingGenerations[index],
                    );
                  }
                  final trip = trips[index - pendingGenerations.length];
                  return _SavedTripCard(
                    trip: trip,
                    onOpen: onOpenTrip,
                    isHeroInFlight: activeHeroTripTag == _tripHeroTag(trip),
                  );
                },
              );
            },
          ),
      ],
    );
  }
}

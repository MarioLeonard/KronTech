part of '../screens/my_trips_screen.dart';

class _SavedTripCard extends StatelessWidget {
  const _SavedTripCard({
    required this.trip,
    required this.onOpen,
    required this.isHeroInFlight,
  });

  final SavedTrip trip;
  final ValueChanged<SavedTrip> onOpen;
  final bool isHeroInFlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<SavedTripsProvider>();
    final isDeleting = provider.deletingTripId == trip.id;
    final destination = trip.destinationLabel;
    final description = trip.compactDescription;
    final dateLabel = trip.formattedDateRange;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Material(
        color: Colors.white.withValues(alpha: 0.08),
        child: InkWell(
          onTap: () => onOpen(trip),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: _tripHeroTag(trip),
                        flightShuttleBuilder:
                            (
                              flightContext,
                              animation,
                              flightDirection,
                              fromHeroContext,
                              toHeroContext,
                            ) {
                              return _RoundedHeroFlight(
                                animation: animation,
                                child: _TripPreviewImage(
                                  url:
                                      trip.itinerary?.destinationImageUrl ?? '',
                                ),
                              );
                            },
                        child: _TripPreviewImage(
                          url: trip.itinerary?.destinationImageUrl ?? '',
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isHeroInFlight ? 0 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(0x22063970),
                                Color(0x11063970),
                                Color(0xCC063970),
                              ],
                            ),
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isHeroInFlight ? 0 : 1,
                        duration: const Duration(milliseconds: 120),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Positioned(
                              left: 16,
                              right: 54,
                              bottom: 14,
                              child: Text(
                                destination,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF063970,
                                  ).withValues(alpha: 0.58),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.16),
                                  ),
                                ),
                                child: IconButton(
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Delete trip',
                                  onPressed: isDeleting
                                      ? null
                                      : () => _confirmDelete(context),
                                  icon: isDeleting
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          const Color(0xFF0E5A90).withValues(alpha: 0.18),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.66),
                            height: 1.35,
                          ),
                        ),
                        const Spacer(),
                        _buildChip(context, dateLabel),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF063970),
          title: const Text(
            'Delete trip?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Trip "${trip.title}" will be deleted from your list.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white60),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final idToken = context.read<AuthProvider>().user?.idToken;
    if (idToken == null || idToken.isEmpty) {
      return;
    }

    await context.read<SavedTripsProvider>().deleteTrip(
      idToken: idToken,
      tripId: trip.id,
    );
  }
}

String _tripHeroTag(SavedTrip trip) {
  return 'trip-image-${trip.id.isEmpty ? trip.title : trip.id}';
}

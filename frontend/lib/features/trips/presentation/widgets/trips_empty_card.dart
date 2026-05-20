part of '../screens/my_trips_screen.dart';

class _TripsEmptyCard extends StatelessWidget {
  const _TripsEmptyCard({required this.onAddTrip});

  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12.0,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.travel_explore_rounded,
                color: theme.colorScheme.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No saved trips',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first journey and we will automatically save it here.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.6),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onAddTrip,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Trip'),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

part of '../screens/my_trips_screen.dart';

class _TripsHero extends StatelessWidget {
  const _TripsHero({required this.onAddTrip});

  final VoidCallback onAddTrip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final copy = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'MY TRIPS',
              style: theme.textTheme.labelLarge?.copyWith(
                letterSpacing: 4,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your generated journeys, neatly saved.',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Text(
                'Create a new itinerary, revisit saved plans, and open every day-by-day route from one organized place.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              height: 4,
              width: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
        final actions = Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
          children: [
            FilledButton(
              onPressed: onAddTrip,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.tertiary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Add Trip',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [copy, const SizedBox(height: 22), actions],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: copy),
            const SizedBox(width: 24),
            actions,
          ],
        );
      },
    );
  }
}

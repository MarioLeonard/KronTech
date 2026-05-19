import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';

class TripEmptyState extends StatelessWidget {
  const TripEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GlassContainer(
      color: Colors.white,
      opacity: 0.07,
      blur: 16,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.26),
                ),
              ),
              child: Icon(
                Icons.map_rounded,
                color: theme.colorScheme.primary,
                size: 27,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your itinerary preview will appear here',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.12,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Once you generate, you will get the full trip: day-by-day schedule, places to visit, accommodation ideas, restaurants, and estimates.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.66),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _PreviewChip(icon: Icons.place_rounded, label: 'Places'),
                _PreviewChip(
                  icon: Icons.edit_calendar_rounded,
                  label: 'Schedule',
                ),
                _PreviewChip(icon: Icons.hotel_rounded, label: 'Stays'),
                _PreviewChip(
                  icon: Icons.restaurant_rounded,
                  label: 'Restaurants',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewChip extends StatelessWidget {
  const _PreviewChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

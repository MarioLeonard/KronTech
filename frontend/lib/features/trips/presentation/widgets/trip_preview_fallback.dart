part of '../screens/my_trips_screen.dart';

class _TripPreviewFallback extends StatelessWidget {
  const _TripPreviewFallback({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withValues(alpha: 0.34),
            colorScheme.tertiary.withValues(alpha: 0.24),
            const Color(0xFF063970),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.travel_explore_rounded,
          color: Colors.white,
          size: 54,
        ),
      ),
    );
  }
}

part of '../screens/trip_details_screen.dart';

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.42),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.26),
            const Color(0xFF063970),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.travel_explore_rounded,
          color: Colors.white,
          size: 70,
        ),
      ),
    );
  }
}

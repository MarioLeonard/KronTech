part of '../screens/trip_details_screen.dart';

class _TripSheetCard extends StatelessWidget {
  const _TripSheetCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.075),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}

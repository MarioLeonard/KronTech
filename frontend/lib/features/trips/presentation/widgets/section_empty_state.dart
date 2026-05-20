part of '../screens/my_trips_screen.dart';

class _SectionEmptyState extends StatelessWidget {
  const _SectionEmptyState({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        title == 'Upcoming trips'
            ? 'No upcoming trips yet.'
            : 'Past trips will appear here.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.62),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

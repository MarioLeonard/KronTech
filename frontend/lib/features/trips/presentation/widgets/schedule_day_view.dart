part of '../screens/trip_details_screen.dart';

class _ScheduleDayView extends StatelessWidget {
  const _ScheduleDayView({
    super.key,
    required this.day,
    required this.currency,
    required this.controller,
  });

  final TripDay day;
  final String currency;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.36),
                ),
              ),
              child: Text(
                day.dayNumber == 0 ? '?' : day.dayNumber.toString(),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.08,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${day.date} · ${day.city}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _ScheduleStat(
              icon: Icons.payments_rounded,
              label: 'Cost',
              value: '${_number(day.estimatedCost)} $currency',
              color: const Color(0xFF7DD3FC),
            ),
            _ScheduleStat(
              icon: Icons.route_rounded,
              label: 'Distance',
              value: '${_number(day.estimatedDistanceKm)} km',
              color: const Color(0xFFA7F3D0),
            ),
            _ScheduleStat(
              icon: Icons.schedule_rounded,
              label: 'Transit',
              value: day.estimatedTransitDuration,
              color: const Color(0xFFFDE68A),
            ),
          ],
        ),
        if (day.summary.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            day.summary,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.74),
              height: 1.55,
            ),
          ),
        ],
        if (day.activities.isNotEmpty) ...[
          const SizedBox(height: 24),
          _ScheduleTimeline(day: day, currency: currency),
        ],
      ],
    );
  }
}

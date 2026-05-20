part of '../screens/trip_details_screen.dart';

class _ScheduleTimelineItem extends StatelessWidget {
  const _ScheduleTimelineItem({
    required this.activity,
    required this.currency,
    required this.color,
    required this.isLast,
  });

  final TripActivity activity;
  final String currency;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.34),
                        blurRadius: 14,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: color.withValues(alpha: 0.22),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _SmallPill(
                        label: activity.timeRange,
                        color: color.withValues(alpha: 0.18),
                      ),
                      _TinyMetric(
                        icon: Icons.payments_rounded,
                        label: _money(activity.estimatedCost, currency),
                      ),
                      if (activity.travelTimeFromPrevious.isNotEmpty)
                        _TinyMetric(
                          icon: Icons.schedule_rounded,
                          label: activity.travelTimeFromPrevious,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activity.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    activity.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                      height: 1.48,
                    ),
                  ),
                  if (activity.transportMode.isNotEmpty) ...[
                    const SizedBox(height: 9),
                    Text(
                      activity.transportMode.replaceAll('_', ' '),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.46),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/trip_day.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_activity_card.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';

class TripDayCard extends StatelessWidget {
  const TripDayCard({required this.day, required this.currency, super.key});

  final TripDay day;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.tertiary,
                  child: Text(
                    day.dayNumber == 0 ? '?' : day.dayNumber.toString(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${day.date} · ${day.city}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.58),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              day.summary,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TripMetricChip(
                  icon: Icons.payments_rounded,
                  label: 'Cost zi',
                  value: _money(day.estimatedCost, currency),
                ),
                TripMetricChip(
                  icon: Icons.route_rounded,
                  label: 'Distance',
                  value: '${_number(day.estimatedDistanceKm)} km',
                ),
                TripMetricChip(
                  icon: Icons.schedule_rounded,
                  label: 'Transit',
                  value: day.estimatedTransitDuration,
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...day.activities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: TripActivityCard(activity: activity, currency: currency),
              ),
            ),
            if (day.mealSuggestions.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Sugestii masa',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              ...day.mealSuggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '• $suggestion',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _money(num value, String currency) {
  if (value == 0) {
    return 'indisponibil';
  }
  return '${_number(value)} $currency';
}

String _number(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

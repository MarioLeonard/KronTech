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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondary,
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
                      Text(day.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('${day.date} · ${day.city}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(day.summary, style: theme.textTheme.bodyMedium),
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
                  label: 'Distanta',
                  value: '${_number(day.estimatedDistanceKm)} km',
                ),
                TripMetricChip(
                  icon: Icons.schedule_rounded,
                  label: 'Deplasari',
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
              Text('Sugestii masa', style: theme.textTheme.titleSmall),
              const SizedBox(height: 6),
              ...day.mealSuggestions.map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text('• $suggestion'),
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

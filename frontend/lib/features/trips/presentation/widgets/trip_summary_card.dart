import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({required this.trip, super.key});

  final GeneratedTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(trip.title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(trip.summary, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TripMetricChip(
                  icon: Icons.payments_rounded,
                  label: 'Total',
                  value: _money(trip.costSummary.estimatedTotal, trip.currency),
                ),
                TripMetricChip(
                  icon: Icons.local_activity_rounded,
                  label: 'Activitati',
                  value: _money(
                    trip.costSummary.estimatedActivitiesTotal,
                    trip.currency,
                  ),
                ),
                TripMetricChip(
                  icon: Icons.restaurant_rounded,
                  label: 'Mancare',
                  value: _money(
                    trip.costSummary.estimatedFoodTotal,
                    trip.currency,
                  ),
                ),
                TripMetricChip(
                  icon: Icons.hotel_rounded,
                  label: 'Cazare',
                  value: _money(
                    trip.costSummary.estimatedAccommodationTotal,
                    trip.currency,
                  ),
                ),
                TripMetricChip(
                  icon: Icons.route_rounded,
                  label: 'Distanta',
                  value: '${_number(trip.distanceSummary.estimatedTotalKm)} km',
                ),
                TripMetricChip(
                  icon: Icons.schedule_rounded,
                  label: 'Deplasari',
                  value: trip.distanceSummary.estimatedTotalTransitDuration,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              '${trip.costSummary.note} ${trip.distanceSummary.note}',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

String _money(num value, String currency) {
  if (value == 0) {
    return 'estimare indisponibila';
  }
  return '${_number(value)} $currency';
}

String _number(num value) {
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

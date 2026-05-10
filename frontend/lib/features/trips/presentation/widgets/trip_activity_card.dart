import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/trip_activity.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';

class TripActivityCard extends StatelessWidget {
  const TripActivityCard({
    required this.activity,
    required this.currency,
    super.key,
  });

  final TripActivity activity;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Chip(
                avatar: const Icon(Icons.schedule_rounded, size: 16),
                label: Text(activity.timeRange),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(activity.title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(
                      activity.location,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(activity.description, style: theme.textTheme.bodyMedium),
          if (activity.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: activity.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TripMetricChip(
                icon: Icons.payments_rounded,
                label: 'Cost',
                value: _money(activity.estimatedCost, currency),
              ),
              TripMetricChip(
                icon: Icons.route_rounded,
                label: 'Distanta',
                value: '${_number(activity.distanceFromPreviousKm)} km',
              ),
              TripMetricChip(
                icon: Icons.directions_walk_rounded,
                label: 'Durata',
                value: activity.travelTimeFromPrevious,
              ),
              TripMetricChip(
                icon: Icons.commute_rounded,
                label: 'Transport',
                value: activity.transportMode,
              ),
            ],
          ),
          if (activity.costNote.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(activity.costNote, style: theme.textTheme.bodySmall),
          ],
        ],
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

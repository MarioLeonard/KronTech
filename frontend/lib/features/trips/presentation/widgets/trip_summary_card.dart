import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_metric_chip.dart';

part 'destination_image.dart';
part 'image_fallback.dart';

class TripSummaryCard extends StatelessWidget {
  const TripSummaryCard({required this.trip, super.key});

  final GeneratedTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 7,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _DestinationImage(url: trip.destinationImageUrl),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF063970).withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 22,
                    right: 22,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trip.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trip.summary,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.78),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TripMetricChip(
                        icon: Icons.payments_rounded,
                        label: 'Total',
                        value: _money(
                          trip.costSummary.estimatedTotal,
                          trip.currency,
                        ),
                      ),
                      TripMetricChip(
                        icon: Icons.local_activity_rounded,
                        label: 'Activities',
                        value: _money(
                          trip.costSummary.estimatedActivitiesTotal,
                          trip.currency,
                        ),
                      ),
                      TripMetricChip(
                        icon: Icons.restaurant_rounded,
                        label: 'Food',
                        value: _money(
                          trip.costSummary.estimatedFoodTotal,
                          trip.currency,
                        ),
                      ),
                      TripMetricChip(
                        icon: Icons.hotel_rounded,
                        label: 'Accommodation',
                        value: _money(
                          trip.costSummary.estimatedAccommodationTotal,
                          trip.currency,
                        ),
                      ),
                      TripMetricChip(
                        icon: Icons.route_rounded,
                        label: 'Distance',
                        value:
                            '${_number(trip.distanceSummary.estimatedTotalKm)} km',
                      ),
                      TripMetricChip(
                        icon: Icons.schedule_rounded,
                        label: 'Transit',
                        value:
                            trip.distanceSummary.estimatedTotalTransitDuration,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${trip.costSummary.note} ${trip.distanceSummary.note}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

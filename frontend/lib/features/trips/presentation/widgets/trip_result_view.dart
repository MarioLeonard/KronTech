import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/generated_trip.dart';
import 'package:frontend/features/trips/presentation/widgets/accommodation_card.dart';
import 'package:frontend/features/trips/presentation/widgets/restaurant_card.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_day_card.dart';
import 'package:frontend/features/trips/presentation/widgets/trip_summary_card.dart';

class TripResultView extends StatelessWidget {
  const TripResultView({required this.trip, super.key});

  final GeneratedTrip trip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TripSummaryCard(trip: trip),
        const SizedBox(height: 16),
        Text('Plan pe zile', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        ...trip.days.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TripDayCard(day: day, currency: trip.currency),
          ),
        ),
        if (trip.accommodations.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Optiuni de cazare', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...trip.accommodations.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AccommodationCard(option: option, currency: trip.currency),
            ),
          ),
        ],
        if (trip.restaurants.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('Restaurante si mese', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          ...trip.restaurants.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RestaurantCard(option: option, currency: trip.currency),
            ),
          ),
        ],
        if (trip.assumptions.isNotEmpty || trip.warnings.isNotEmpty) ...[
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Note si limitari',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...trip.assumptions.map((item) => Text('• $item')),
                  ...trip.warnings.map((item) => Text('• $item')),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

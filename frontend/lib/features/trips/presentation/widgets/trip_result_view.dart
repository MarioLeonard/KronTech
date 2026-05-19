import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
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
        const SizedBox(height: 22),
        _SectionTitle(
          icon: Icons.calendar_month_rounded,
          title: 'Plan pe zile',
        ),
        const SizedBox(height: 12),
        ...trip.days.map(
          (day) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: TripDayCard(day: day, currency: trip.currency),
          ),
        ),
        if (trip.accommodations.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle(
            icon: Icons.hotel_rounded,
            title: 'Accommodation options',
          ),
          const SizedBox(height: 12),
          ...trip.accommodations.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AccommodationCard(option: option, currency: trip.currency),
            ),
          ),
        ],
        if (trip.restaurants.isNotEmpty) ...[
          const SizedBox(height: 14),
          _SectionTitle(
            icon: Icons.restaurant_rounded,
            title: 'Restaurants and meals',
          ),
          const SizedBox(height: 12),
          ...trip.restaurants.map(
            (option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RestaurantCard(option: option, currency: trip.currency),
            ),
          ),
        ],
        if (trip.assumptions.isNotEmpty || trip.warnings.isNotEmpty) ...[
          const SizedBox(height: 14),
          GlassContainer(
            color: Colors.white,
            opacity: 0.06,
            blur: 12,
            borderRadius: 20,
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            child: Padding(
              padding: const EdgeInsets.all(18),
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
                        'Notes and limitations',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...trip.assumptions.map((item) => _NoteLine(text: item)),
                  ...trip.warnings.map((item) => _NoteLine(text: item)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        const SizedBox(width: 10),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '• $text',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
      ),
    );
  }
}

part of '../screens/trip_details_screen.dart';

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.trip, required this.itinerary});

  final SavedTrip trip;
  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.dashboard_rounded,
      title: 'Overview',
      subtitle: 'Summary, budget, and quick highlights',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itinerary.summary,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.62,
            ),
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              TripMetricChip(
                icon: Icons.payments_rounded,
                label: 'Estimated total',
                value:
                    '${_number(itinerary.costSummary.estimatedTotal)} ${itinerary.currency}',
              ),
              TripMetricChip(
                icon: Icons.route_rounded,
                label: 'Distance',
                value:
                    '${_number(itinerary.distanceSummary.estimatedTotalKm)} km',
              ),
              TripMetricChip(
                icon: Icons.schedule_rounded,
                label: 'Tranzit',
                value: itinerary.distanceSummary.estimatedTotalTransitDuration,
              ),
              TripMetricChip(
                icon: Icons.calendar_today_rounded,
                label: 'Period',
                value: _dateRange(trip.startDate, trip.endDate),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _InfoGrid(
            children: [
              _InfoTile(
                title: 'Cities',
                value: itinerary.cities.isEmpty
                    ? 'No cities listed'
                    : itinerary.cities.join(', '),
                icon: Icons.location_city_rounded,
              ),
              _InfoTile(
                title: 'Accommodation',
                value:
                    '${_number(itinerary.costSummary.estimatedAccommodationTotal)} ${itinerary.currency}',
                icon: Icons.hotel_rounded,
              ),
              _InfoTile(
                title: 'Activities',
                value:
                    '${_number(itinerary.costSummary.estimatedActivitiesTotal)} ${itinerary.currency}',
                icon: Icons.local_activity_rounded,
              ),
              _InfoTile(
                title: 'Meals',
                value:
                    '${_number(itinerary.costSummary.estimatedFoodTotal)} ${itinerary.currency}',
                icon: Icons.restaurant_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

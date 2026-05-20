part of '../screens/trip_details_screen.dart';

class _AccommodationSection extends StatelessWidget {
  const _AccommodationSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.hotel_rounded,
      title: 'Accommodation',
      subtitle: 'Recommended options and nightly estimates',
      child: itinerary.accommodations.isEmpty
          ? const _EmptySection(
              message: 'There are no saved accommodation options.',
            )
          : _ResponsiveCardList(
              maxColumns: 3,
              minCardWidth: 300,
              children: [
                for (final option in itinerary.accommodations)
                  AccommodationCard(
                    option: option,
                    currency: itinerary.currency,
                  ),
              ],
            ),
    );
  }
}

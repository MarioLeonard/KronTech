part of '../screens/trip_details_screen.dart';

class _RestaurantsSection extends StatelessWidget {
  const _RestaurantsSection({required this.itinerary});

  final GeneratedTrip itinerary;

  @override
  Widget build(BuildContext context) {
    return _DetailPanel(
      icon: Icons.restaurant_rounded,
      title: 'Restaurants',
      subtitle: 'Meal suggestions, areas, and estimates',
      child: itinerary.restaurants.isEmpty
          ? const _EmptySection(message: 'There are no saved restaurants.')
          : _ResponsiveCardList(
              children: [
                for (final option in itinerary.restaurants)
                  RestaurantCard(option: option, currency: itinerary.currency),
              ],
            ),
    );
  }
}

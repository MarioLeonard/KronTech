part of '../screens/trip_details_screen.dart';

class _PlacesSection extends StatelessWidget {
  const _PlacesSection({
    required this.itinerary,
    required this.onVisitedChanged,
  });

  final GeneratedTrip itinerary;
  final void Function(_PlaceItem place, bool isVisited) onVisitedChanged;

  @override
  Widget build(BuildContext context) {
    final places = [
      for (final day in itinerary.days)
        for (var index = 0; index < day.activities.length; index++)
          _PlaceItem(
            title: day.activities[index].title,
            location: day.activities[index].location,
            description: day.activities[index].description,
            dayNumber: day.dayNumber,
            activityIndex: index,
            isVisited: day.activities[index].isVisited,
          ),
    ];

    return _DetailPanel(
      icon: Icons.place_rounded,
      title: 'Places to visit',
      subtitle: 'Tourist objectives saved for this trip',
      child: places.isEmpty
          ? const _EmptySection(message: 'There are no saved places.')
          : _ResponsiveCardList(
              maxColumns: 1,
              children: [
                for (var index = 0; index < places.length; index++)
                  _StaggeredSectionItem(
                    index: index,
                    child: _PlaceCard(
                      place: places[index],
                      onVisitedChanged: (isVisited) {
                        onVisitedChanged(places[index], isVisited);
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}

part of '../screens/trip_details_screen.dart';

class _ScheduleTimeline extends StatelessWidget {
  const _ScheduleTimeline({required this.day, required this.currency});

  final TripDay day;
  final String currency;

  static const _colors = [
    Color(0xFF7DD3FC),
    Color(0xFFA7F3D0),
    Color(0xFFFDE68A),
    Color(0xFFF0ABFC),
    Color(0xFFFCA5A5),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < day.activities.length; index++)
          _ScheduleTimelineItem(
            activity: day.activities[index],
            currency: currency,
            color: _colors[index % _colors.length],
            isLast: index == day.activities.length - 1,
          ),
      ],
    );
  }
}

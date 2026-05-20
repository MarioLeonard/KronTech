part of '../screens/trip_details_screen.dart';

class _EditableScheduleSection extends StatefulWidget {
  const _EditableScheduleSection({
    required this.itinerary,
    required this.controllers,
  });

  final GeneratedTrip itinerary;
  final Map<int, TextEditingController> controllers;

  @override
  State<_EditableScheduleSection> createState() =>
      _EditableScheduleSectionState();
}

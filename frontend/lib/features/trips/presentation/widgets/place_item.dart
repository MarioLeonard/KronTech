part of '../screens/trip_details_screen.dart';

class _PlaceItem {
  const _PlaceItem({
    required this.title,
    required this.location,
    required this.description,
    required this.dayNumber,
    required this.activityIndex,
    required this.isVisited,
  });

  final String title;
  final String location;
  final String description;
  final int dayNumber;
  final int activityIndex;
  final bool isVisited;
}

String _editablePlanFor(TripDay day) {
  final buffer = StringBuffer()
    ..writeln(day.title)
    ..writeln('${day.date} · ${day.city}')
    ..writeln()
    ..writeln(day.summary);

  for (final activity in day.activities) {
    buffer
      ..writeln()
      ..writeln('${activity.timeRange} - ${activity.title}')
      ..writeln(activity.location)
      ..writeln(activity.description);
  }

  if (day.mealSuggestions.isNotEmpty) {
    buffer
      ..writeln()
      ..writeln('Meal ideas: ${day.mealSuggestions.join(', ')}');
  }

  return buffer.toString().trim();
}

String _destinationLabel(SavedTrip trip) {
  if (trip.cities.isNotEmpty) {
    return trip.cities.first;
  }
  final itineraryCities = trip.itinerary?.cities ?? const [];
  if (itineraryCities.isNotEmpty) {
    return itineraryCities.first;
  }
  return trip.title;
}

String _dateRange(String startDate, String endDate) {
  final parsedStart = DateTime.tryParse(startDate);
  if (parsedStart == null) {
    return startDate.isEmpty ? 'Date TBC' : startDate;
  }
  final parsedEnd = DateTime.tryParse(endDate);
  if (parsedEnd == null || _isSameDay(parsedStart, parsedEnd)) {
    return _formatTripDate(parsedStart);
  }
  if (parsedStart.year == parsedEnd.year) {
    return '${parsedStart.day} ${_monthAbbreviation(parsedStart.month)}. - ${parsedEnd.day} ${_monthAbbreviation(parsedEnd.month)}. ${parsedEnd.year}';
  }
  return '${_formatTripDate(parsedStart)} - ${_formatTripDate(parsedEnd)}';
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatTripDate(DateTime date) {
  return '${date.day} ${_monthAbbreviation(date.month)}. ${date.year}';
}

String _monthAbbreviation(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  if (month < 1 || month > months.length) {
    return '';
  }
  return months[month - 1];
}

String _money(num value, String currency) {
  if (value == 0) {
    return 'indisponibil';
  }
  return '${_number(value)} $currency';
}

String _number(num value) {
  if (value == 0) {
    return 'indisponibil';
  }
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

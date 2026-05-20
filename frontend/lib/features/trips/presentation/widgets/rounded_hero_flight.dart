part of '../screens/my_trips_screen.dart';

class _RoundedHeroFlight extends StatelessWidget {
  const _RoundedHeroFlight({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final radius = Tween<double>(
          begin: 18,
          end: 28,
        ).transform(Curves.easeInOutCubic.transform(animation.value));

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
      child: child,
    );
  }
}

extension _SavedTripDisplay on SavedTrip {
  bool get isPast {
    final parsedEndDate = DateTime.tryParse(endDate);
    if (parsedEndDate == null) {
      return false;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return parsedEndDate.isBefore(todayDate);
  }

  String get destinationLabel {
    if (cities.isNotEmpty) {
      return cities.first;
    }
    final itineraryCities = itinerary?.cities ?? const [];
    if (itineraryCities.isNotEmpty) {
      return itineraryCities.first;
    }
    return title;
  }

  String get compactDescription {
    final dayCount = itinerary?.days.length ?? 0;
    final destination = destinationLabel;
    if (dayCount > 0) {
      return 'Itinerary of $dayCount ${dayCount == 1 ? 'day' : 'days'} in $destination';
    }
    if (summary.isNotEmpty) {
      return summary;
    }
    return 'Saved itinerary in $destination';
  }

  String get formattedDateRange {
    final parsedDate = DateTime.tryParse(startDate);
    if (parsedDate == null) {
      return startDate.isEmpty ? 'Date TBC' : startDate;
    }
    final parsedEndDate = DateTime.tryParse(endDate);
    if (parsedEndDate == null || _isSameDay(parsedDate, parsedEndDate)) {
      return _formatTripDate(parsedDate);
    }
    if (parsedDate.year == parsedEndDate.year) {
      return '${parsedDate.day} ${_monthAbbreviation(parsedDate.month)} - ${parsedEndDate.day} ${_monthAbbreviation(parsedEndDate.month)} ${parsedEndDate.year}';
    }
    return '${_formatTripDate(parsedDate)} - ${_formatTripDate(parsedEndDate)}';
  }
}

bool _isSameDay(DateTime first, DateTime second) {
  return first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;
}

String _formatTripDate(DateTime date) {
  return '${date.day} ${_monthAbbreviation(date.month)} ${date.year}';
}

String _formatPendingTripRange(DateTime startDate, DateTime endDate) {
  if (_isSameDay(startDate, endDate)) {
    return _formatTripDate(startDate);
  }
  if (startDate.year == endDate.year) {
    return '${startDate.day} ${_monthAbbreviation(startDate.month)} - ${endDate.day} ${_monthAbbreviation(endDate.month)} ${endDate.year}';
  }
  return '${_formatTripDate(startDate)} - ${_formatTripDate(endDate)}';
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

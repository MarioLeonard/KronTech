const _profileDateMonths = [
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

const _profileDateMonthNumbers = {
  'jan': 1,
  'feb': 2,
  'mar': 3,
  'apr': 4,
  'may': 5,
  'jun': 6,
  'jul': 7,
  'aug': 8,
  'sep': 9,
  'oct': 10,
  'nov': 11,
  'dec': 12,
};

String formatProfileDisplayDate(DateTime date) {
  return '${date.day.toString().padLeft(2, '0')} '
      '${_profileDateMonths[date.month - 1]} '
      '${date.year}';
}

String? formatProfileBirthDate(String? isoDate) {
  if (isoDate == null || isoDate.trim().isEmpty) {
    return null;
  }
  final date = DateTime.tryParse(isoDate);
  if (date == null) {
    return null;
  }
  return formatProfileDisplayDate(date);
}

String formatProfileBirthDateInput(String? isoDate) {
  return formatProfileBirthDate(isoDate) ?? '';
}

DateTime? parseProfileDisplayDate(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  if (parts.length != 3) {
    return null;
  }

  final day = int.tryParse(parts[0]);
  final month = _profileDateMonthNumbers[parts[1].toLowerCase()];
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) {
    return null;
  }
  return DateTime(year, month, day);
}

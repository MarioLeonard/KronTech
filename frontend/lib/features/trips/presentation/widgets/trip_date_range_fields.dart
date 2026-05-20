import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

part 'date_picker_scroll_behavior.dart';
part 'date_field.dart';

class TripDateRangeFields extends StatelessWidget {
  const TripDateRangeFields({
    required this.startDate,
    required this.endDate,
    required this.isOneDayTrip,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    required this.onOneDayTripChanged,
    required this.enabled,
    super.key,
  });

  final DateTime? startDate;
  final DateTime? endDate;
  final bool isOneDayTrip;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final ValueChanged<bool> onOneDayTripChanged;
  final bool enabled;

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required DateTime firstDate,
    required ValueChanged<DateTime> onChanged,
  }) async {
    final normalizedInitialDate = initialDate == null
        ? firstDate
        : _dateOnly(initialDate).isBefore(firstDate)
        ? firstDate
        : _dateOnly(initialDate);
    final picked = await _showCupertinoDatePicker(
      context: context,
      initialDate: normalizedInitialDate,
      minimumDate: firstDate,
      maximumDate: DateTime(firstDate.year + 5, firstDate.month, firstDate.day),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  Future<DateTime?> _showCupertinoDatePicker({
    required BuildContext context,
    required DateTime initialDate,
    required DateTime minimumDate,
    required DateTime maximumDate,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    var selectedDate = initialDate;

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xFF063970),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 46,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.34),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(selectedDate),
                        child: const Text(
                          'Done',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 176,
                      child: CupertinoTheme(
                        data: CupertinoThemeData(
                          brightness: Brightness.dark,
                          primaryColor: colorScheme.primary,
                          textTheme: CupertinoTextThemeData(
                            dateTimePickerTextStyle: theme.textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        child: ScrollConfiguration(
                          behavior: const _DatePickerScrollBehavior(),
                          child: CupertinoDatePicker(
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime: initialDate,
                            minimumDate: minimumDate,
                            maximumDate: maximumDate,
                            onDateTimeChanged: (value) {
                              selectedDate = _dateOnly(value);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = _dateOnly(DateTime.now());
    final startMinimumDate = today;
    final endMinimumDate = startDate == null ? today : _dateOnly(startDate!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: isOneDayTrip,
          onChanged: enabled
              ? (value) => onOneDayTripChanged(value ?? false)
              : null,
          contentPadding: EdgeInsets.zero,
          dense: true,
          visualDensity: VisualDensity.compact,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text(
            'One day trip',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 460;
            final startField = _DateField(
              label: isOneDayTrip ? 'Trip date' : 'Start date',
              value: _formatDate(startDate),
              enabled: enabled,
              onTap: () => _pickDate(
                context: context,
                initialDate: startDate,
                firstDate: startMinimumDate,
                onChanged: onStartDateChanged,
              ),
            );
            final endField = AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: isOneDayTrip
                  ? const SizedBox.shrink(key: ValueKey('one-day-hidden'))
                  : _DateField(
                      key: const ValueKey('end-date-field'),
                      label: 'End date',
                      value: _formatDate(endDate),
                      enabled: enabled,
                      onTap: () => _pickDate(
                        context: context,
                        initialDate: endDate ?? startDate,
                        firstDate: endMinimumDate,
                        onChanged: onEndDateChanged,
                      ),
                    ),
            );

            if (isCompact) {
              return Column(
                children: [
                  startField,
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    child: isOneDayTrip
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: endField,
                          ),
                  ),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: startField),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: isOneDayTrip
                      ? const SizedBox.shrink()
                      : const SizedBox(width: 12),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: isOneDayTrip
                      ? const SizedBox.shrink()
                      : SizedBox(
                          width: (constraints.maxWidth - 12) / 2,
                          child: endField,
                        ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
    final day = date.day.toString().padLeft(2, '0');
    return '$day ${_monthAbbreviation(date.month)} ${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
}

part of '../screens/trip_details_screen.dart';

class _EditableScheduleSectionState extends State<_EditableScheduleSection> {
  int _selectedDayIndex = 0;

  @override
  void didUpdateWidget(covariant _EditableScheduleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_selectedDayIndex >= widget.itinerary.days.length) {
      _selectedDayIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final days = widget.itinerary.days;
    final selectedDay = days.isEmpty ? null : days[_selectedDayIndex];

    return _DetailPanel(
      icon: Icons.edit_calendar_rounded,
      title: 'Daily schedule',
      subtitle: 'Plan separated by day',
      child: days.isEmpty || selectedDay == null
          ? const _EmptySection(message: 'There is no daily schedule.')
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ScheduleDayPicker(
                  days: days,
                  selectedIndex: _selectedDayIndex,
                  onSelected: (index) {
                    setState(() => _selectedDayIndex = index);
                  },
                ),
                const SizedBox(height: 24),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 260),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (currentChild, previousChildren) {
                    return currentChild ?? const SizedBox.shrink();
                  },
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _ScheduleDayView(
                    key: ValueKey(selectedDay.dayNumber),
                    day: selectedDay,
                    currency: widget.itinerary.currency,
                    controller: widget.controllers[selectedDay.dayNumber],
                  ),
                ),
              ],
            ),
    );
  }
}

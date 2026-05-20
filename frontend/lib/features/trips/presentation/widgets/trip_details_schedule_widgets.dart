part of '../screens/trip_details_screen.dart';

class _ScheduleDayPicker extends StatelessWidget {
  const _ScheduleDayPicker({
    required this.days,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<TripDay> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final day in days)
        _ToggleItem(
          Icons.calendar_today_rounded,
          'Day ${day.dayNumber == 0 ? '?' : day.dayNumber}',
        ),
    ];

    return SizedBox(
      width: double.infinity,
      child: GlassContainer(
        color: Colors.white,
        opacity: 0.06,
        blur: 14,
        borderRadius: 20,
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 620 && items.length > 3) {
                return _ToggleGrid(
                  items: items,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                );
              }

              return _ToggleRow(
                items: items,
                selectedIndex: selectedIndex,
                onSelected: onSelected,
              );
            },
          ),
        ),
      ),
    );
  }
}

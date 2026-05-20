part of '../screens/trip_details_screen.dart';

class _SectionToggles extends StatelessWidget {
  const _SectionToggles({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    _ToggleItem(Icons.dashboard_rounded, 'Overview'),
    _ToggleItem(Icons.group_rounded, 'Friends'),
    _ToggleItem(Icons.hotel_rounded, 'Accommodation'),
    _ToggleItem(Icons.place_rounded, 'Places'),
    _ToggleItem(Icons.edit_calendar_rounded, 'Schedule'),
    _ToggleItem(Icons.restaurant_rounded, 'Restaurants'),
    _ToggleItem(Icons.notes_rounded, 'Note'),
  ];

  @override
  Widget build(BuildContext context) {
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
              if (constraints.maxWidth < 760) {
                return _ToggleGrid(
                  items: _items,
                  selectedIndex: selectedIndex,
                  onSelected: onSelected,
                );
              }

              return _ToggleRow(
                items: _items,
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

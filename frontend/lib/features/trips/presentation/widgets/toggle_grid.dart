part of '../screens/trip_details_screen.dart';

class _ToggleGrid extends StatelessWidget {
  const _ToggleGrid({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const int _columns = 2;
  static const double _gap = 8;
  static const double _height = 46;

  final List<_ToggleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final selected = selectedIndex.clamp(0, items.length - 1);
        final itemWidth =
            (constraints.maxWidth - (_gap * (_columns - 1))) / _columns;
        final rowCount = (items.length / _columns).ceil();

        return SizedBox(
          height: (rowCount * _height) + ((rowCount - 1) * _gap),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                left: (selected % _columns) * (itemWidth + _gap),
                top: (selected ~/ _columns) * (_height + _gap),
                width: itemWidth,
                height: _height,
                child: const _ToggleSelectionPill(),
              ),
              for (var index = 0; index < items.length; index++)
                Positioned(
                  left: (index % _columns) * (itemWidth + _gap),
                  top: (index ~/ _columns) * (_height + _gap),
                  width: itemWidth,
                  height: _height,
                  child: _ToggleButton(
                    item: items[index],
                    isSelected: selected == index,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

part of '../screens/trip_details_screen.dart';

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
  });

  static const double _gap = 8;
  static const double _height = 46;

  final List<_ToggleItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = items.length;
        final selected = selectedIndex.clamp(0, itemCount - 1);
        final itemWidth =
            (constraints.maxWidth - (_gap * (itemCount - 1))) / itemCount;

        return SizedBox(
          height: _height,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 360),
                curve: Curves.easeOutCubic,
                left: selected * (itemWidth + _gap),
                top: 0,
                width: itemWidth,
                height: _height,
                child: const _ToggleSelectionPill(),
              ),
              Row(
                children: [
                  for (var index = 0; index < itemCount; index++) ...[
                    SizedBox(
                      width: itemWidth,
                      height: _height,
                      child: _ToggleButton(
                        item: items[index],
                        isSelected: selected == index,
                        onTap: () => onSelected(index),
                      ),
                    ),
                    if (index != itemCount - 1) const SizedBox(width: _gap),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

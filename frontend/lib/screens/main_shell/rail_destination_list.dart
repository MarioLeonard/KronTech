part of '../main_shell.dart';

class _RailDestinationList extends StatelessWidget {
  static const double _buttonHeight = 68;
  static const double _itemGap = 8;
  static const double _itemExtent = _buttonHeight + _itemGap;

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  const _RailDestinationList({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final groupHeight = destinations.length * _itemExtent;
        final groupTop = constraints.maxHeight > groupHeight
            ? (constraints.maxHeight - groupHeight) / 2
            : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 360),
              curve: Curves.easeOutCubic,
              top: groupTop + (selectedIndex * _itemExtent),
              left: 0,
              right: 0,
              height: _buttonHeight,
              child: const _RailSelectionPill(),
            ),
            Positioned(
              top: groupTop,
              left: 0,
              right: 0,
              child: Column(
                children: destinations.asMap().entries.map((entry) {
                  final index = entry.key;
                  final destination = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == destinations.length - 1 ? 0 : _itemGap,
                    ),
                    child: _RailDestinationButton(
                      destination: destination,
                      isSelected: selectedIndex == index,
                      onPressed: () => onDestinationSelected(index),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

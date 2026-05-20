part of '../main_shell.dart';

class _GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<_ShellDestination> destinations;

  const _GlassNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: destinations.asMap().entries.map((entry) {
              final index = entry.key;
              final destination = entry.value;
              final isSelected = selectedIndex == index;

              return _BottomDestinationButton(
                destination: destination,
                isSelected: isSelected,
                onPressed: () => onDestinationSelected(index),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

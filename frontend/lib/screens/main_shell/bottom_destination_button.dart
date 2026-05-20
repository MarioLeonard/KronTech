part of '../main_shell.dart';

class _BottomDestinationButton extends StatelessWidget {
  const _BottomDestinationButton({
    required this.destination,
    required this.isSelected,
    required this.onPressed,
  });

  final _ShellDestination destination;
  final bool isSelected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface.withValues(alpha: 0.6);

    return Tooltip(
      message: destination.label,
      child: Semantics(
        button: true,
        selected: isSelected,
        label: destination.label,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: SizedBox(
              width: 52,
              height: 52,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                scale: isSelected ? 1.08 : 1,
                child: Icon(destination.icon, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

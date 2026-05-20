part of '../main_shell.dart';

class _RailDestinationButton extends StatelessWidget {
  final _ShellDestination destination;
  final bool isSelected;
  final VoidCallback onPressed;

  const _RailDestinationButton({
    required this.destination,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inactiveColor = theme.colorScheme.onSurface.withValues(alpha: 0.68);

    return Tooltip(
      message: destination.label,
      waitDuration: const Duration(milliseconds: 400),
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
              width: double.infinity,
              height: _RailDestinationList._buttonHeight,
              child: TweenAnimationBuilder<Color?>(
                tween: ColorTween(
                  begin: inactiveColor,
                  end: isSelected ? Colors.white : inactiveColor,
                ),
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                builder: (context, color, _) {
                  return AnimatedScale(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    scale: isSelected ? 1.04 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(destination.icon, color: color, size: 25),
                        const SizedBox(height: 5),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeOutCubic,
                          style:
                              theme.textTheme.labelSmall?.copyWith(
                                color: color,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ) ??
                              TextStyle(
                                color: color,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                              ),
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

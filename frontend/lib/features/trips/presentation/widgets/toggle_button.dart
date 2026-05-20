part of '../screens/trip_details_screen.dart';

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _ToggleItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: isSelected ? 1 : 0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, progress, child) {
        final iconColor = Color.lerp(
          Colors.white.withValues(alpha: 0.72),
          Colors.white,
          progress,
        )!;

        return Transform.scale(
          scale: 1 + (0.025 * progress),
          child: Tooltip(
            message: item.label,
            child: Semantics(
              button: true,
              selected: isSelected,
              label: item.label,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onTap,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10 + (2 * progress),
                      vertical: 11,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Transform.rotate(
                          angle: 0.08 * progress,
                          child: Transform.scale(
                            scale: 1 + (0.08 * progress),
                            child: Icon(item.icon, size: 18, color: iconColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(
                                alpha: 0.78 + (0.22 * progress),
                              ),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

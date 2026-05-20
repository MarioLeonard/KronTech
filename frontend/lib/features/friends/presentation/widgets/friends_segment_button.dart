part of '../screens/friends_screen.dart';

class _FriendsSegmentButton extends StatelessWidget {
  const _FriendsSegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.count = 0,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      style:
          theme.textTheme.labelLarge?.copyWith(
            color: Colors.white.withValues(alpha: selected ? 0.96 : 0.62),
            fontWeight: FontWeight.w900,
          ) ??
          TextStyle(
            color: Colors.white.withValues(alpha: selected ? 0.96 : 0.62),
            fontWeight: FontWeight.w900,
          ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? colorScheme.primary
                    : Colors.white.withValues(alpha: 0.62),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 8),
                _CountBadge(count: count),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

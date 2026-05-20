part of '../screens/trip_details_screen.dart';

class _VisitedCheckbox extends StatelessWidget {
  const _VisitedCheckbox({required this.isVisited, required this.onChanged});

  final bool isVisited;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      checked: isVisited,
      label: isVisited ? 'Mark as not visited' : 'Mark as visited',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(!isVisited),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: isVisited
                  ? theme.colorScheme.tertiary
                  : theme.colorScheme.tertiary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isVisited
                    ? Colors.white.withValues(alpha: 0.32)
                    : theme.colorScheme.tertiary.withValues(alpha: 0.28),
              ),
              boxShadow: [
                if (isVisited)
                  BoxShadow(
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.26),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isVisited
                  ? const Icon(
                      Icons.check_rounded,
                      key: ValueKey('visited'),
                      color: Colors.white,
                      size: 21,
                    )
                  : const SizedBox(key: ValueKey('not-visited')),
            ),
          ),
        ),
      ),
    );
  }
}

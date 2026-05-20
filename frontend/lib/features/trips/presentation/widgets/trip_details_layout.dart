part of '../screens/trip_details_screen.dart';

class _DetailsSectionSwitcher extends StatelessWidget {
  const _DetailsSectionSwitcher({
    required this.sectionKey,
    required this.child,
  });

  final Object sectionKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 560),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        return SizeTransition(
          axisAlignment: -1,
          sizeFactor: animation,
          child: child,
        );
      },
      child: KeyedSubtree(key: ValueKey(sectionKey), child: child),
    );
  }
}

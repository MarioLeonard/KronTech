part of '../login_screen.dart';

class _AnimatedLoginFieldSlot extends StatelessWidget {
  const _AnimatedLoginFieldSlot({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        return SizeTransition(
          axisAlignment: -1,
          sizeFactor: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: visible
          ? KeyedSubtree(
              key: const ValueKey('visible-login-field'),
              child: child,
            )
          : const SizedBox.shrink(key: ValueKey('hidden-login-field')),
    );
  }
}

part of '../main_shell.dart';

class _ShellPageSlot extends StatelessWidget {
  const _ShellPageSlot({
    required this.isVisible,
    required this.isActive,
    required this.offset,
    required this.child,
    super.key,
  });

  final bool isVisible;
  final bool isActive;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final page = TickerMode(
      enabled: isVisible,
      child: IgnorePointer(
        ignoring: !isActive,
        child: RepaintBoundary(
          child: FractionalTranslation(translation: offset, child: child),
        ),
      ),
    );

    if (isVisible) {
      return page;
    }

    return Offstage(offstage: true, child: page);
  }
}

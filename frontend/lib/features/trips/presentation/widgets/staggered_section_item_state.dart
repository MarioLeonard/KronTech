part of '../screens/trip_details_screen.dart';

class _StaggeredSectionItemState extends State<_StaggeredSectionItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    Future<void>.delayed(Duration(milliseconds: widget.index * 45), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);

        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: progress,
            child: Opacity(
              opacity: progress,
              child: Transform.translate(
                offset: Offset(0, 12 * (1 - progress)),
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

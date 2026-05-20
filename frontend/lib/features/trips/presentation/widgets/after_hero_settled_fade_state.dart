part of '../screens/trip_details_screen.dart';

class _AfterHeroSettledFadeState extends State<_AfterHeroSettledFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 140),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeAnimation = ModalRoute.of(context)?.animation;
    if (_routeAnimation == routeAnimation) {
      _syncWithRouteAnimation();
      return;
    }

    _routeAnimation?.removeListener(_syncWithRouteAnimation);
    _routeAnimation?.removeStatusListener(_syncWithRouteStatus);
    _routeAnimation = routeAnimation;
    _routeAnimation?.addListener(_syncWithRouteAnimation);
    _routeAnimation?.addStatusListener(_syncWithRouteStatus);
    _syncWithRouteAnimation();
  }

  @override
  void dispose() {
    _routeAnimation?.removeListener(_syncWithRouteAnimation);
    _routeAnimation?.removeStatusListener(_syncWithRouteStatus);
    _controller.dispose();
    super.dispose();
  }

  void _syncWithRouteStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _controller.forward();
      return;
    }

    if (status == AnimationStatus.reverse ||
        status == AnimationStatus.dismissed) {
      _controller.reverse();
    }
  }

  void _syncWithRouteAnimation() {
    final animation = _routeAnimation;
    if (animation == null) {
      _controller.forward();
      return;
    }

    if (animation.status == AnimationStatus.reverse) {
      _controller.reverse();
      return;
    }

    if (animation.value >= 0.995) {
      _controller.forward();
      return;
    }

    _controller.value = 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final offset = Offset(0, 10 * (1 - progress));

        return IgnorePointer(
          ignoring: progress < 0.95,
          child: Opacity(
            opacity: progress,
            child: Transform.translate(offset: offset, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

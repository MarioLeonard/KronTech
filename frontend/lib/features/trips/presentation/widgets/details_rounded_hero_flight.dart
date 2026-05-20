part of '../screens/trip_details_screen.dart';

class _RoundedHeroFlight extends StatelessWidget {
  const _RoundedHeroFlight({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final radius = Tween<double>(
          begin: 18,
          end: 28,
        ).transform(Curves.easeInOutCubic.transform(animation.value));

        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: child,
        );
      },
      child: child,
    );
  }
}

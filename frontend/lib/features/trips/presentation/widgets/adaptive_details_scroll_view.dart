part of '../screens/trip_details_screen.dart';

class _AdaptiveDetailsScrollView extends StatelessWidget {
  const _AdaptiveDetailsScrollView({
    required this.padding,
    required this.child,
  });

  final EdgeInsets padding;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: padding,
      child: child,
    );
  }
}

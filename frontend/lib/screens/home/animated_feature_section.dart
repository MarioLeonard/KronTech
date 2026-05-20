part of '../home_screen.dart';

class _AnimatedFeatureSection extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const _AnimatedFeatureSection({required this.isActive, required this.child});

  @override
  State<_AnimatedFeatureSection> createState() =>
      _AnimatedFeatureSectionState();
}

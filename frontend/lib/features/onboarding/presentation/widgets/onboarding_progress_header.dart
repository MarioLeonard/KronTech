import 'package:flutter/material.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: progress),
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Container(
            height: 10,
            color: Colors.white.withValues(alpha: 0.18),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value,
              child: const DecoratedBox(
                decoration: BoxDecoration(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }
}

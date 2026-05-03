import 'package:flutter/material.dart';

class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.title,
  });

  final int currentStep;
  final int totalSteps;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = (currentStep + 1) / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Step ${currentStep + 1} of $totalSteps',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary.withValues(alpha: 0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).round()}%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 10,
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            child: FractionallySizedBox(
              widthFactor: progress,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

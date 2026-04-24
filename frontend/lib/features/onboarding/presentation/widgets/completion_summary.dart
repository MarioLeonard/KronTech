import 'package:flutter/material.dart';

import '../controllers/onboarding_provider.dart';

class CompletionSummary extends StatelessWidget {
  const CompletionSummary({super.key, required this.provider});

  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = [
      (
        'Name',
        '${provider.onboardingData.profileInfo.firstName} ${provider.onboardingData.profileInfo.lastName}',
      ),
      ('Email', provider.onboardingData.profileInfo.email),
      ('Birth date', provider.summaryValue(provider.steps[4].type)),
      ('Gender', provider.onboardingData.profileInfo.gender),
      (
        'Address',
        '${provider.onboardingData.address.street}, ${provider.onboardingData.address.city}, ${provider.onboardingData.address.zipCode}, ${provider.onboardingData.address.country}',
      ),
      ('Interests', provider.summaryValue(provider.steps[10].type)),
      ('Notifications', provider.summaryValue(provider.steps[11].type)),
      ('Privacy', provider.summaryValue(provider.steps[12].type)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.9, end: 1),
            duration: const Duration(milliseconds: 900),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondary,
                    theme.colorScheme.primary,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.28),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 26),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: theme.colorScheme.surface.withValues(alpha: 0.72),
                border: Border.all(color: theme.dividerColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 110,
                    child: Text(
                      item.$1,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      item.$2,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/onboarding_step_definition.dart';
import '../controllers/onboarding_provider.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/city_location_field.dart';
import '../widgets/completion_summary.dart';
import '../widgets/country_location_field.dart';
import '../widgets/date_picker_card.dart';
import '../widgets/onboarding_navigation_bar.dart';
import '../widgets/onboarding_progress_header.dart';
import '../widgets/onboarding_shell.dart';
import '../widgets/privacy_card.dart';
import '../widgets/selection_cards.dart';

class MainOnboardingScreen extends StatelessWidget {
  const MainOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final step = provider.currentStep;

        return OnboardingShell(
          onBackPressed: provider.canGoBack
              ? () => provider.goToPreviousStep()
              : null,
          progressHeader: OnboardingProgressHeader(
            currentStep: provider.currentStepIndex,
            totalSteps: provider.steps.length,
          ),
          footer: OnboardingNavigationBar(
            primaryLabel: step.primaryLabel,
            showPrimary: provider.shouldShowPrimaryAction,
            animationKey: step.type,
            secondaryLabel: null,
            isBusy: provider.isCompleting,
            onSecondaryPressed: null,
            onPrimaryPressed: () async {
              if (step.type == OnboardingStepType.completion) {
                final user = await provider.complete();
                if (context.mounted && user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Saved locally for ${user.fullName}. Check the console for the full Hive payload.',
                      ),
                    ),
                  );
                }
                return;
              }

              await provider.goToNextStep();
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _StepHero(step: step),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 560),
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
                child: Column(
                  key: ValueKey(step.type),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _StepBody(provider: provider),
                    if (provider.inlineError != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        provider.inlineError!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepHero extends StatelessWidget {
  const _StepHero({required this.step});

  final OnboardingStepDefinition step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          step.subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  const _StepBody({required this.provider});

  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final step = provider.currentStep.type;
    final error = provider.inlineError;

    switch (step) {
      case OnboardingStepType.firstName:
        return AnimatedInputField(
          label: 'First name',
          value: provider.onboardingData.profileInfo.firstName,
          hintText: 'Type your first name',
          errorText: error,
          prefixIcon: const Icon(Icons.person_outline_rounded),
          onChanged: (value) => provider.updateFirstName(value),
        );
      case OnboardingStepType.lastName:
        return AnimatedInputField(
          label: 'Last name',
          value: provider.onboardingData.profileInfo.lastName,
          hintText: 'Type your last name',
          errorText: error,
          prefixIcon: const Icon(Icons.person_2_outlined),
          onChanged: (value) => provider.updateLastName(value),
        );
      case OnboardingStepType.email:
        return AnimatedInputField(
          label: 'Email address',
          value: provider.onboardingData.profileInfo.email,
          hintText: 'name@example.com',
          errorText: error,
          keyboardType: TextInputType.emailAddress,
          prefixIcon: const Icon(Icons.mail_outline_rounded),
          onChanged: (value) => provider.updateEmail(value),
        );
      case OnboardingStepType.dateOfBirth:
        return DatePickerCard(
          value: provider.onboardingData.profileInfo.dateOfBirth,
          onChanged: (value) => provider.updateDateOfBirth(value),
        );
      case OnboardingStepType.gender:
        return SelectionCardGroup(
          options: const ['Male', 'Female', 'Other'],
          selected: provider.onboardingData.profileInfo.gender,
          errorText: error,
          onSelected: (value) => provider.updateGender(value),
        );
      case OnboardingStepType.country:
        return CountryLocationField(
          value: provider.onboardingData.address.country,
          errorText: error,
          onChanged: (value) => provider.updateCountry(value),
          onLocationDetected: (country, city, street) {
            return provider.updateLocationAddress(
              country: country,
              city: city,
              street: street,
            );
          },
        );
      case OnboardingStepType.city:
        return CityLocationField(
          value: provider.onboardingData.address.city,
          country: provider.onboardingData.address.country,
          errorText: error,
          onChanged: (value) => provider.updateCity(value),
        );
      case OnboardingStepType.street:
        return AnimatedInputField(
          label: 'Street address',
          value: provider.onboardingData.address.street,
          hintText: 'Street name and number',
          errorText: error,
          prefixIcon: const Icon(Icons.home_outlined),
          onChanged: (value) => provider.updateStreet(value),
        );
      case OnboardingStepType.privacy:
        return PrivacyCard(
          accepted: provider.onboardingData.preferences.acceptPrivacyPolicy,
          errorText: error,
          onChanged: (value) => provider.setPrivacyAccepted(value),
        );
      case OnboardingStepType.completion:
        return CompletionSummary(provider: provider);
    }
  }
}

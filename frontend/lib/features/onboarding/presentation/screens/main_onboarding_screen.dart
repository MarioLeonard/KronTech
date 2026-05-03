import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/onboarding_step_definition.dart';
import '../controllers/onboarding_provider.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/completion_summary.dart';
import '../widgets/date_picker_card.dart';
import '../widgets/onboarding_navigation_bar.dart';
import '../widgets/onboarding_progress_header.dart';
import '../widgets/onboarding_shell.dart';
import '../widgets/privacy_card.dart';
import '../widgets/selection_cards.dart';
import '../widgets/toggle_card.dart';

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
          header: OnboardingProgressHeader(
            currentStep: provider.currentStepIndex,
            totalSteps: provider.steps.length,
            title: step.title,
          ),
          footer: OnboardingNavigationBar(
            primaryLabel: step.primaryLabel,
            showPrimary: provider.shouldShowPrimaryAction,
            secondaryLabel: step.secondaryLabel,
            isBusy: provider.isCompleting,
            onSecondaryPressed: provider.canGoBack
                ? () => provider.goToPreviousStep()
                : null,
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
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.secondary,
          ),
          child: Icon(step.icon, color: theme.colorScheme.onSecondary),
        ),
        const SizedBox(height: 18),
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
    final theme = Theme.of(context);
    final step = provider.currentStep.type;
    final error = provider.inlineError;

    switch (step) {
      case OnboardingStepType.welcome:
        return _WelcomeBody(provider: provider);
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
          label: 'Date of birth',
          value: provider.onboardingData.profileInfo.dateOfBirth,
          onChanged: (value) => provider.updateDateOfBirth(value),
        );
      case OnboardingStepType.gender:
        return SelectionCardGroup(
          label: 'Choose one option',
          options: const ['Male', 'Female', 'Other'],
          selected: provider.onboardingData.profileInfo.gender,
          errorText: error,
          onSelected: (value) => provider.updateGender(value),
        );
      case OnboardingStepType.country:
        return AnimatedInputField(
          label: 'Country',
          value: provider.onboardingData.address.country,
          hintText: 'Romania',
          errorText: error,
          prefixIcon: const Icon(Icons.public_rounded),
          onChanged: (value) => provider.updateCountry(value),
        );
      case OnboardingStepType.city:
        return AnimatedInputField(
          label: 'City',
          value: provider.onboardingData.address.city,
          hintText: 'Bucharest',
          errorText: error,
          prefixIcon: const Icon(Icons.location_city_rounded),
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
      case OnboardingStepType.zipCode:
        return AnimatedInputField(
          label: 'Postal code',
          value: provider.onboardingData.address.zipCode,
          hintText: '010011',
          errorText: error,
          keyboardType: TextInputType.number,
          prefixIcon: const Icon(Icons.markunread_mailbox_outlined),
          onChanged: (value) => provider.updateZipCode(value),
        );
      case OnboardingStepType.interests:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pick as many as you like',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            InterestChips(
              options: provider.suggestedInterests,
              selectedOptions: provider.onboardingData.preferences.interests,
              onToggle: (value) => provider.toggleInterest(value),
            ),
          ],
        );
      case OnboardingStepType.notifications:
        return ToggleCard(
          title: 'Enable notifications',
          subtitle:
              'Turn this on if you want time-sensitive updates and useful reminders.',
          value: provider.onboardingData.preferences.enableNotifications,
          onChanged: (value) => provider.setNotifications(value),
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

class _WelcomeBody extends StatelessWidget {
  const _WelcomeBody({required this.provider});

  final OnboardingProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_outlined, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Progress is autosaved locally after each change, so you can return without losing your place.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'What to expect',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'You will move through identity, address, preferences, and a final review screen with clear progress feedback at the top.',
          style: theme.textTheme.bodyLarge,
        ),
        if (provider.onboardingData.profileInfo.firstName.isNotEmpty ||
            provider.currentStepIndex > 0) ...[
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                'Existing local draft detected. You can continue from where you left off.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

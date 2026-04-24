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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHero(step: step),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 450),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final fade = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );
                  final slide = Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(fade);
                  return FadeTransition(
                    opacity: fade,
                    child: SlideTransition(position: slide, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(step.type),
                  child: _StepBody(provider: provider),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 240),
                child: provider.inlineError == null
                    ? const SizedBox(height: 0)
                    : Padding(
                        padding: const EdgeInsets.only(top: 18),
                        child: Text(
                          provider.inlineError!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
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
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.9),
                theme.colorScheme.secondary.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Icon(step.icon, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text(step.title, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 10),
        Text(step.subtitle, style: theme.textTheme.bodyLarge),
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
      case OnboardingStepType.welcome:
        return _WelcomeBody(provider: provider);
      case OnboardingStepType.firstName:
        return AnimatedInputField(
          label: 'First name',
          value: provider.onboardingData.profileInfo.firstName,
          hintText: 'Type your first name',
          errorText: step == provider.currentStep.type ? error : null,
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
              style: Theme.of(context).textTheme.titleMedium,
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
            borderRadius: BorderRadius.circular(28),
            color: theme.colorScheme.primary.withValues(alpha: 0.12),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.hive_outlined, color: theme.colorScheme.secondary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Progress is autosaved locally in Hive after each change, so you can return without losing your place.',
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: theme.colorScheme.surface.withValues(alpha: 0.72),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What to expect', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(
                'You will move through identity, address, preferences, and a final review screen with clear progress feedback at the top.',
                style: theme.textTheme.bodyLarge,
              ),
              if (provider.onboardingData.profileInfo.firstName.isNotEmpty ||
                  provider.currentStepIndex > 0) ...[
                const SizedBox(height: 14),
                Text(
                  'Existing local draft detected. You can continue from where you left off.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

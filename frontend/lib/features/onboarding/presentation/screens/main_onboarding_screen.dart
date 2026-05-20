import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../domain/onboarding_step_definition.dart';
import '../controllers/onboarding_provider.dart';
import '../widgets/animated_input_field.dart';
import '../widgets/city_location_field.dart';
import '../widgets/country_location_field.dart';
import '../widgets/date_picker_card.dart';
import '../widgets/onboarding_navigation_bar.dart';
import '../widgets/onboarding_progress_header.dart';
import '../widgets/onboarding_shell.dart';
import '../widgets/privacy_card.dart';
import '../widgets/profile_photo_picker_card.dart';
import '../widgets/selection_cards.dart';

part '../widgets/main_onboarding_step_widgets.dart';
part '../widgets/step_body.dart';

class MainOnboardingScreen extends StatelessWidget {
  const MainOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<OnboardingProvider>(
      builder: (context, provider, _) {
        final authProvider = context.read<AuthProvider>();
        final authUser = authProvider.user;

        if (provider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authEmail = authUser?.email?.trim();
        if (provider.onboardingData.profileInfo.email.isEmpty &&
            authEmail != null &&
            authEmail.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              provider.prefillEmail(authEmail);
            }
          });
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
              if (provider.isLastStep) {
                if (authUser == null) {
                  return;
                }

                final profile = await provider.complete(
                  idToken: authUser.idToken,
                );
                if (context.mounted && profile != null) {
                  authProvider.updateProfile(profile);
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

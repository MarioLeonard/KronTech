import 'package:flutter/material.dart';

enum OnboardingStepType {
  firstName,
  lastName,
  email,
  dateOfBirth,
  gender,
  country,
  city,
  street,
  privacy,
  completion,
}

class OnboardingStepDefinition {
  const OnboardingStepDefinition({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.primaryLabel,
    this.secondaryLabel,
  });

  final OnboardingStepType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String primaryLabel;
  final String? secondaryLabel;

  static const List<OnboardingStepDefinition> all = [
    OnboardingStepDefinition(
      type: OnboardingStepType.firstName,
      title: 'What should we call you?',
      subtitle: 'Your first name helps us personalize the experience.',
      icon: Icons.badge_outlined,
      primaryLabel: 'Continue',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.lastName,
      title: 'And your last name?',
      subtitle: 'This completes the identity section of your profile.',
      icon: Icons.account_circle_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.email,
      title: 'Where can we reach you?',
      subtitle: 'We will use this email for confirmations and account updates.',
      icon: Icons.alternate_email_rounded,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.dateOfBirth,
      title: 'When is your birthday?',
      subtitle: 'This helps us tailor the profile respectfully and accurately.',
      icon: Icons.cake_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.gender,
      title: 'How would you like to be identified?',
      subtitle: 'Select the option that best represents you.',
      icon: Icons.wc_rounded,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.country,
      title: 'Which country are you in?',
      subtitle: 'We use location details to make the experience more relevant.',
      icon: Icons.public_rounded,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.city,
      title: 'Which city should we remember?',
      subtitle: 'Your main city helps us complete the core address profile.',
      icon: Icons.location_city_rounded,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.street,
      title: 'What is your street address?',
      subtitle:
          'Add the street name and number as you would write it normally.',
      icon: Icons.home_work_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.privacy,
      title: 'Before we finish',
      subtitle: 'Please review and accept the privacy and terms confirmation.',
      icon: Icons.verified_user_outlined,
      primaryLabel: 'Finish',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.completion,
      title: 'Your profile is ready',
      subtitle: 'We will persist the final version locally for verification.',
      icon: Icons.check_circle_outline_rounded,
      primaryLabel: 'Finish onboarding',
      secondaryLabel: 'Back',
    ),
  ];
}

import 'package:flutter/material.dart';

enum OnboardingStepType {
  welcome,
  firstName,
  lastName,
  email,
  dateOfBirth,
  gender,
  country,
  city,
  street,
  zipCode,
  interests,
  notifications,
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
      type: OnboardingStepType.welcome,
      title: 'A calmer start to your setup',
      subtitle:
          'We will shape your profile one thoughtful step at a time and keep every detail safely on this device.',
      icon: Icons.auto_awesome_rounded,
      primaryLabel: 'Begin',
    ),
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
      title: 'Which option fits best?',
      subtitle: 'Choose the label that feels right for your profile.',
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
      type: OnboardingStepType.zipCode,
      title: 'Postal code',
      subtitle: 'One last detail to complete your saved address.',
      icon: Icons.markunread_mailbox_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.interests,
      title: 'What are you into lately?',
      subtitle: 'Pick a few interests so the app can feel more curated.',
      icon: Icons.interests_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.notifications,
      title: 'Stay in the loop?',
      subtitle: 'Choose whether important updates should reach you directly.',
      icon: Icons.notifications_active_outlined,
      primaryLabel: 'Continue',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.privacy,
      title: 'Review the privacy confirmation',
      subtitle:
          'Please confirm before we finalize your local onboarding profile.',
      icon: Icons.verified_user_outlined,
      primaryLabel: 'Review',
      secondaryLabel: 'Back',
    ),
    OnboardingStepDefinition(
      type: OnboardingStepType.completion,
      title: 'Everything looks beautifully in place',
      subtitle:
          'Your profile is ready. We will persist the final version locally and print the saved Hive data for verification.',
      icon: Icons.check_circle_outline_rounded,
      primaryLabel: 'Finish onboarding',
      secondaryLabel: 'Back',
    ),
  ];
}

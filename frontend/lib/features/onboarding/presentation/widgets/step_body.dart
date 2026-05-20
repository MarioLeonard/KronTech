part of '../screens/main_onboarding_screen.dart';

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
      case OnboardingStepType.profilePhoto:
        return ProfilePhotoPickerCard(
          value: provider.onboardingData.profileInfo.profilePhotoDataUrl,
          fallbackPhotoUrl: context
              .read<AuthProvider>()
              .user
              ?.effectivePhotoUrl,
          errorText: error,
          onChanged: (value) => provider.updateProfilePhoto(value),
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
    }
  }
}

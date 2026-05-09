class OnboardingValidators {
  static String? requiredText(
    String? value, {
    required String fieldLabel,
    int minLength = 1,
  }) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return '$fieldLabel is required.';
    }
    if (trimmed.length < minLength) {
      return '$fieldLabel should be at least $minLength characters.';
    }
    return null;
  }

  static String? email(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Email is required.';
    }

    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailPattern.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? zipCode(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Postal code is required.';
    }

    if (trimmed.length < 4) {
      return 'Postal code looks too short.';
    }
    return null;
  }

  static String? privacyAccepted(bool accepted) {
    if (!accepted) {
      return 'Please accept the privacy policy to continue.';
    }
    return null;
  }

  static String? selection(String? value, {required String fieldLabel}) {
    if ((value ?? '').trim().isEmpty) {
      return 'Please choose a $fieldLabel.';
    }
    return null;
  }
}

import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/user_model.dart';
import '../utils/hive_service.dart';

/// Provider managing the state, validation, and persistence of the onboarding flow
class OnboardingProvider extends ChangeNotifier {
  // Main data object
  OnboardingData onboardingData = OnboardingData.empty();

  // Form keys for validating each step from the main screen
  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> preferencesFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Load data from Hive when the app starts
  Future<void> loadSavedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = HiveService.getOnboardingBox();
      final savedData = box.get('onboarding_draft');

      if (savedData != null) {
        // Convert the dynamically retrieved Map back to OnboardingData
        final map = Map<String, dynamic>.from(savedData);
        onboardingData = OnboardingData.fromMap(map);
      }
    } catch (e) {
      debugPrint('Error loading Hive data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save current progress to Hive
  Future<void> saveProgress() async {
    try {
      final box = HiveService.getOnboardingBox();
      await box.put('onboarding_draft', onboardingData.toMap());
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }

  /// Clear Hive data upon successful completion
  Future<void> clearProgress() async {
    try {
      final box = HiveService.getOnboardingBox();
      await box.delete('onboarding_draft');
      onboardingData = OnboardingData.empty();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing Hive: $e');
    }
  }

  /// Validate the current step using the respective form key and model logic
  bool validateCurrentStep(int stepIndex) {
    bool isFormValid = false;
    bool isModelValid = false;

    switch (stepIndex) {
      case 0:
        isFormValid = profileFormKey.currentState?.validate() ?? false;
        isModelValid = onboardingData.profileInfo.isValid;
        break;
      case 1:
        isFormValid = addressFormKey.currentState?.validate() ?? false;
        isModelValid = onboardingData.address.isValid;
        break;
      case 2:
        isFormValid = preferencesFormKey.currentState?.validate() ?? false;
        isModelValid = onboardingData.preferences.isValid;
        break;
      default:
        return false;
    }

    return isFormValid && isModelValid;
  }

  /// Compile the final UserModel
  UserModel compileFinalUser() {
    return UserModel.fromOnboardingData(onboardingData);
  }

  // --- Profile Info Updaters ---

  void updateFirstName(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(firstName: value),
    );
    notifyListeners();
  }

  void updateLastName(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(lastName: value),
    );
    notifyListeners();
  }

  void updateEmail(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(email: value),
    );
    notifyListeners();
  }

  void updateDateOfBirth(DateTime value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(dateOfBirth: value),
    );
    notifyListeners();
  }

  void updateGender(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(gender: value),
    );
    notifyListeners();
  }

  // --- Address Updaters ---

  void updateCountry(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(country: value),
    );
    notifyListeners();
  }

  void updateCity(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(city: value),
    );
    notifyListeners();
  }

  void updateStreet(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(street: value),
    );
    notifyListeners();
  }

  void updateZipCode(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(zipCode: value),
    );
    notifyListeners();
  }

  // --- Preferences Updaters ---

  void updateInterests(String commaSeparatedValues) {
    final interestsList = commaSeparatedValues
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    onboardingData = onboardingData.copyWith(
      preferences: onboardingData.preferences.copyWith(
        interests: interestsList,
      ),
    );
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    onboardingData = onboardingData.copyWith(
      preferences: onboardingData.preferences.copyWith(
        enableNotifications: value,
      ),
    );
    notifyListeners();
  }

  void togglePrivacyPolicy(bool value) {
    onboardingData = onboardingData.copyWith(
      preferences: onboardingData.preferences.copyWith(
        acceptPrivacyPolicy: value,
      ),
    );
    notifyListeners();
  }
}

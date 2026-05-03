import 'dart:async';

import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/user_model.dart';
import '../utils/hive_service.dart';
import '../services/firebase_service.dart';

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

  // Firebase service instance
  final FirebaseService _firebaseService = FirebaseService();

  String? _firestoreSyncError;
  String? get firestoreSyncError => _firestoreSyncError;

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
      profileInfo: onboardingData.profileInfo.copyWith(
        firstName: _capitalizeFirstLetter(value),
      ),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateLastName(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(
        lastName: _capitalizeFirstLetter(value),
      ),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateEmail(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(email: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateDateOfBirth(DateTime value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(dateOfBirth: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateGender(String value) {
    onboardingData = onboardingData.copyWith(
      profileInfo: onboardingData.profileInfo.copyWith(gender: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  // --- Address Updaters ---

  void updateCountry(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(country: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateCity(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(city: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateStreet(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(street: value),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void updateZipCode(String value) {
    onboardingData = onboardingData.copyWith(
      address: onboardingData.address.copyWith(zipCode: value),
    );
    notifyListeners();
    unawaited(saveProgress());
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
    unawaited(saveProgress());
  }

  void toggleNotifications(bool value) {
    onboardingData = onboardingData.copyWith(
      preferences: onboardingData.preferences.copyWith(
        enableNotifications: value,
      ),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  void togglePrivacyPolicy(bool value) {
    onboardingData = onboardingData.copyWith(
      preferences: onboardingData.preferences.copyWith(
        acceptPrivacyPolicy: value,
      ),
    );
    notifyListeners();
    unawaited(saveProgress());
  }

  String _capitalizeFirstLetter(String value) {
    final trimmed = value.trimLeft();
    if (trimmed.isEmpty) {
      return '';
    }
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  /// Complete onboarding and sync data to Firestore
  Future<UserModel?> completeOnboardingAndSync() async {
    try {
      _isLoading = true;
      _firestoreSyncError = null;
      notifyListeners();

      // Compile final user model
      final finalUser = compileFinalUser();

      // Save to Firestore
      final success = await _firebaseService.saveUserToFirestore(finalUser);

      if (success) {
        // Clear local draft after successful sync
        await clearProgress();
        return finalUser;
      } else {
        _firestoreSyncError = 'Failed to save user data to Firestore';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _firestoreSyncError = 'Error: ${e.toString()}';
      debugPrint('Firestore sync error: $e');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get current Firebase user
  bool get isUserAuthenticated => _firebaseService.getCurrentUser() != null;

  /// Get Firebase user email
  String? get currentUserEmail => _firebaseService.getCurrentUser()?.email;
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/onboarding_data.dart';
import '../models/user_model.dart';
import '../utils/hive_service.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingData onboardingData = OnboardingData.empty();

  final GlobalKey<FormState> profileFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> preferencesFormKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  String? _firestoreSyncError;
  String? get firestoreSyncError => _firestoreSyncError;

  Future<void> loadSavedData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final box = HiveService.getOnboardingBox();
      final savedData = box.get('onboarding_draft');

      if (savedData != null) {
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

  Future<void> saveProgress() async {
    try {
      final box = HiveService.getOnboardingBox();
      await box.put('onboarding_draft', onboardingData.toMap());
    } catch (e) {
      debugPrint('Error saving to Hive: $e');
    }
  }

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

  UserModel compileFinalUser() {
    return UserModel.fromOnboardingData(onboardingData);
  }

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

  Future<UserModel?> completeOnboardingAndSync() async {
    try {
      _isLoading = true;
      _firestoreSyncError = null;
      notifyListeners();

      final finalUser = compileFinalUser();

      await clearProgress();
      return finalUser;
    } catch (e) {
      _firestoreSyncError = 'Error: ${e.toString()}';
      debugPrint('Onboarding completion error: $e');
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool get isUserAuthenticated => _firebaseAuth.currentUser != null;

  String? get currentUserEmail => _firebaseAuth.currentUser?.email;
}

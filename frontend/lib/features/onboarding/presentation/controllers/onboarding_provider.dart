import 'package:flutter/material.dart';

import '../../../../models/onboarding_data.dart';
import '../../../../models/user_model.dart';
import '../../../../models/user_profile.dart';
import '../../../../services/backend_api_service.dart';
import '../../data/onboarding_storage.dart';
import '../../domain/onboarding_step_definition.dart';
import '../../domain/onboarding_validators.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({
    OnboardingStorage? storage,
    BackendApiService? backendApiService,
  }) : _storage = storage ?? OnboardingStorage(),
       _backendApiService = backendApiService ?? BackendApiService();

  final OnboardingStorage _storage;
  final BackendApiService _backendApiService;
  final List<OnboardingStepDefinition> steps = OnboardingStepDefinition.all;

  OnboardingData _onboardingData = OnboardingData.empty();
  int _currentStepIndex = 0;
  bool _isLoading = true;
  bool _isCompleting = false;
  String? _inlineError;

  OnboardingData get onboardingData => _onboardingData;
  int get currentStepIndex => _currentStepIndex;
  bool get isLoading => _isLoading;
  bool get isCompleting => _isCompleting;
  String? get inlineError => _inlineError;
  OnboardingStepDefinition get currentStep => steps[_currentStepIndex];
  bool get canGoBack => _currentStepIndex > 0;
  bool get isLastStep => _currentStepIndex == steps.length - 1;
  double get progress => (_currentStepIndex + 1) / steps.length;
  bool get shouldShowPrimaryAction {
    switch (currentStep.type) {
      case OnboardingStepType.firstName:
        return _onboardingData.profileInfo.firstName.trim().isNotEmpty;
      case OnboardingStepType.lastName:
        return _onboardingData.profileInfo.lastName.trim().isNotEmpty;
      case OnboardingStepType.email:
        return OnboardingValidators.email(_onboardingData.profileInfo.email) ==
            null;
      case OnboardingStepType.dateOfBirth:
        return _onboardingData.profileInfo.hasSelectedDateOfBirth;
      case OnboardingStepType.gender:
        return _onboardingData.profileInfo.gender.trim().isNotEmpty;
      case OnboardingStepType.profilePhoto:
        return true;
      case OnboardingStepType.country:
        return _onboardingData.address.country.trim().isNotEmpty;
      case OnboardingStepType.city:
        return _onboardingData.address.city.trim().isNotEmpty;
      case OnboardingStepType.street:
        return _onboardingData.address.street.trim().isNotEmpty;
      case OnboardingStepType.privacy:
        return _onboardingData.preferences.acceptPrivacyPolicy;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final draft = await _storage.loadDraft();
      final flowVersion = _storage.loadFlowVersion();
      final savedStep = _storage.loadCurrentStep();
      _onboardingData = draft ?? OnboardingData.empty();
      _currentStepIndex = _normalizeSavedStep(savedStep, flowVersion);
      await _storage.saveCurrentStep(_currentStepIndex);
    } catch (error) {
      debugPrint('Failed to load onboarding state: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToNextStep() async {
    final validation = validateCurrentStep();
    if (validation != null) {
      _inlineError = validation;
      notifyListeners();
      return;
    }

    _inlineError = null;

    if (_currentStepIndex < steps.length - 1) {
      _currentStepIndex += 1;
      await _persist();
      notifyListeners();
    }
  }

  Future<void> goToPreviousStep() async {
    if (!canGoBack) {
      return;
    }
    _inlineError = null;
    _currentStepIndex -= 1;
    await _storage.saveCurrentStep(_currentStepIndex);
    notifyListeners();
  }

  Future<UserProfile?> complete({required String idToken}) async {
    final validation = validateCurrentStep();
    if (validation != null) {
      _inlineError = validation;
      notifyListeners();
      return null;
    }

    _isCompleting = true;
    _inlineError = null;
    notifyListeners();

    try {
      await _persist();
      final user = UserModel.fromOnboardingData(_onboardingData);
      final profile = await _backendApiService.completeOnboarding(
        idToken: idToken,
        user: user,
      );
      await _storage.saveCompletedUser(user);
      debugPrint('Hive onboarding payload:\n${_storage.prettyPrintAll()}');

      return profile;
    } catch (error) {
      debugPrint('Failed to finalize onboarding: $error');
      _inlineError =
          'Something went wrong while saving your profile. Please try again.';
      return null;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }

  String? validateCurrentStep() {
    switch (currentStep.type) {
      case OnboardingStepType.firstName:
        return OnboardingValidators.requiredText(
          _onboardingData.profileInfo.firstName,
          fieldLabel: 'First name',
          minLength: 2,
        );
      case OnboardingStepType.lastName:
        return OnboardingValidators.requiredText(
          _onboardingData.profileInfo.lastName,
          fieldLabel: 'Last name',
          minLength: 2,
        );
      case OnboardingStepType.email:
        return OnboardingValidators.email(_onboardingData.profileInfo.email);
      case OnboardingStepType.dateOfBirth:
        return _onboardingData.profileInfo.hasSelectedDateOfBirth
            ? null
            : 'Please select your date of birth.';
      case OnboardingStepType.gender:
        return OnboardingValidators.selection(
          _onboardingData.profileInfo.gender,
          fieldLabel: 'gender option',
        );
      case OnboardingStepType.profilePhoto:
        return null;
      case OnboardingStepType.country:
        return OnboardingValidators.requiredText(
          _onboardingData.address.country,
          fieldLabel: 'Country',
        );
      case OnboardingStepType.city:
        return OnboardingValidators.requiredText(
          _onboardingData.address.city,
          fieldLabel: 'City',
        );
      case OnboardingStepType.street:
        return OnboardingValidators.requiredText(
          _onboardingData.address.street,
          fieldLabel: 'Street address',
          minLength: 5,
        );
      case OnboardingStepType.privacy:
        return OnboardingValidators.privacyAccepted(
          _onboardingData.preferences.acceptPrivacyPolicy,
        );
    }
  }

  Future<void> updateFirstName(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(
        firstName: _capitalizeFirstLetter(value),
      ),
    ),
  );

  Future<void> updateLastName(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(
        lastName: _capitalizeFirstLetter(value),
      ),
    ),
  );

  Future<void> updateEmail(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(
        email: value.trim().toLowerCase(),
      ),
    ),
  );

  Future<void> prefillEmail(String? value) async {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty || _onboardingData.profileInfo.email.isNotEmpty) {
      return;
    }

    await updateEmail(email);
  }

  Future<void> updateDateOfBirth(DateTime value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(
        dateOfBirth: value,
        hasSelectedDateOfBirth: true,
      ),
    ),
  );

  Future<void> updateGender(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(gender: value),
    ),
  );

  Future<void> updateProfilePhoto(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(
        profilePhotoDataUrl: value.trim(),
      ),
    ),
  );

  Future<void> updateCountry(String value) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(
        country: value.trim(),
        city: '',
      ),
    ),
  );

  Future<void> updateLocationAddress({
    required String country,
    required String city,
    required String street,
  }) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(
        country: country.trim(),
        city: city.trim(),
        street: street.trim(),
      ),
    ),
  );

  Future<void> updateCity(String value) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(city: value.trim()),
    ),
  );

  Future<void> updateStreet(String value) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(street: value.trim()),
    ),
  );

  Future<void> setPrivacyAccepted(bool value) => _updateData(
    _onboardingData.copyWith(
      preferences: _onboardingData.preferences.copyWith(
        acceptPrivacyPolicy: value,
      ),
    ),
  );

  String summaryValue(OnboardingStepType type) {
    switch (type) {
      case OnboardingStepType.firstName:
        return _onboardingData.profileInfo.firstName;
      case OnboardingStepType.lastName:
        return _onboardingData.profileInfo.lastName;
      case OnboardingStepType.email:
        return _onboardingData.profileInfo.email;
      case OnboardingStepType.dateOfBirth:
        final dob = _onboardingData.profileInfo.dateOfBirth;
        return '${dob.day.toString().padLeft(2, '0')}/${dob.month.toString().padLeft(2, '0')}/${dob.year}';
      case OnboardingStepType.gender:
        return _onboardingData.profileInfo.gender;
      case OnboardingStepType.profilePhoto:
        return _onboardingData.profileInfo.profilePhotoDataUrl.isNotEmpty
            ? 'Selected'
            : 'Pending';
      case OnboardingStepType.country:
        return _onboardingData.address.country;
      case OnboardingStepType.city:
        return _onboardingData.address.city;
      case OnboardingStepType.street:
        return _onboardingData.address.street;
      case OnboardingStepType.privacy:
        return _onboardingData.preferences.acceptPrivacyPolicy
            ? 'Accepted'
            : 'Pending';
    }
  }

  Future<void> _updateData(OnboardingData value) async {
    _onboardingData = value;
    _inlineError = null;
    notifyListeners();
    await _storage.saveDraft(_onboardingData);
  }

  Future<void> _persist() async {
    await _storage.saveDraft(_onboardingData);
    await _storage.saveCurrentStep(_currentStepIndex);
  }

  String _capitalizeFirstLetter(String value) {
    final trimmed = value.trimLeft();
    if (trimmed.isEmpty) {
      return '';
    }
    return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
  }

  int _normalizeSavedStep(int savedStep, int flowVersion) {
    var migratedStep = savedStep;
    if (flowVersion < 2) {
      migratedStep -= 1;
    }
    if (flowVersion < 3) {
      final profilePhotoStepIndex = steps.indexWhere(
        (step) => step.type == OnboardingStepType.profilePhoto,
      );
      if (migratedStep >= profilePhotoStepIndex) {
        migratedStep = profilePhotoStepIndex;
      }
    }
    return migratedStep.clamp(0, steps.length - 1);
  }
}

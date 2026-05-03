import 'package:flutter/material.dart';

import '../../../../models/onboarding_data.dart';
import '../../../../models/user_model.dart';
import '../../data/onboarding_storage.dart';
import '../../domain/onboarding_step_definition.dart';
import '../../domain/onboarding_validators.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider({OnboardingStorage? storage})
    : _storage = storage ?? OnboardingStorage();

  final OnboardingStorage _storage;
  final List<OnboardingStepDefinition> steps = OnboardingStepDefinition.all;
  final List<String> suggestedInterests = const [
    'Technology',
    'Design',
    'Travel',
    'Business',
    'Wellness',
    'Culture',
    'Photography',
    'Sports',
  ];

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
      case OnboardingStepType.welcome:
      case OnboardingStepType.dateOfBirth:
      case OnboardingStepType.notifications:
      case OnboardingStepType.completion:
        return true;
      case OnboardingStepType.firstName:
        return _onboardingData.profileInfo.firstName.trim().isNotEmpty;
      case OnboardingStepType.lastName:
        return _onboardingData.profileInfo.lastName.trim().isNotEmpty;
      case OnboardingStepType.email:
        return _onboardingData.profileInfo.email.trim().isNotEmpty;
      case OnboardingStepType.gender:
        return _onboardingData.profileInfo.gender.trim().isNotEmpty;
      case OnboardingStepType.country:
        return _onboardingData.address.country.trim().isNotEmpty;
      case OnboardingStepType.city:
        return _onboardingData.address.city.trim().isNotEmpty;
      case OnboardingStepType.street:
        return _onboardingData.address.street.trim().isNotEmpty;
      case OnboardingStepType.zipCode:
        return _onboardingData.address.zipCode.trim().isNotEmpty;
      case OnboardingStepType.interests:
        return _onboardingData.preferences.interests.isNotEmpty;
      case OnboardingStepType.privacy:
        return _onboardingData.preferences.acceptPrivacyPolicy;
    }
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final draft = await _storage.loadDraft();
      _onboardingData = draft ?? OnboardingData.empty();
      _currentStepIndex = _storage.loadCurrentStep().clamp(0, steps.length - 1);
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

  Future<UserModel?> complete() async {
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
      await _storage.saveCompletedUser(user);
      debugPrint('Hive onboarding payload:\n${_storage.prettyPrintAll()}');

      return user;
    } catch (error) {
      debugPrint('Failed to finalize onboarding: $error');
      _inlineError =
          'Something went wrong while finalizing your profile. Please try again.';
      return null;
    } finally {
      _isCompleting = false;
      notifyListeners();
    }
  }

  String? validateCurrentStep() {
    switch (currentStep.type) {
      case OnboardingStepType.welcome:
      case OnboardingStepType.completion:
        return null;
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
        return null;
      case OnboardingStepType.gender:
        return OnboardingValidators.selection(
          _onboardingData.profileInfo.gender,
          fieldLabel: 'gender option',
        );
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
      case OnboardingStepType.zipCode:
        return OnboardingValidators.zipCode(_onboardingData.address.zipCode);
      case OnboardingStepType.interests:
        return null;
      case OnboardingStepType.notifications:
        return null;
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
      profileInfo: _onboardingData.profileInfo.copyWith(email: value.trim()),
    ),
  );

  Future<void> updateDateOfBirth(DateTime value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(dateOfBirth: value),
    ),
  );

  Future<void> updateGender(String value) => _updateData(
    _onboardingData.copyWith(
      profileInfo: _onboardingData.profileInfo.copyWith(gender: value),
    ),
  );

  Future<void> updateCountry(String value) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(country: value.trim()),
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

  Future<void> updateZipCode(String value) => _updateData(
    _onboardingData.copyWith(
      address: _onboardingData.address.copyWith(zipCode: value.trim()),
    ),
  );

  Future<void> toggleInterest(String value) async {
    final current = List<String>.from(_onboardingData.preferences.interests);
    if (current.contains(value)) {
      current.remove(value);
    } else {
      current.add(value);
    }

    await _updateData(
      _onboardingData.copyWith(
        preferences: _onboardingData.preferences.copyWith(interests: current),
      ),
    );
  }

  Future<void> setNotifications(bool value) => _updateData(
    _onboardingData.copyWith(
      preferences: _onboardingData.preferences.copyWith(
        enableNotifications: value,
      ),
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
      case OnboardingStepType.country:
        return _onboardingData.address.country;
      case OnboardingStepType.city:
        return _onboardingData.address.city;
      case OnboardingStepType.street:
        return _onboardingData.address.street;
      case OnboardingStepType.zipCode:
        return _onboardingData.address.zipCode;
      case OnboardingStepType.interests:
        return _onboardingData.preferences.interests.isEmpty
            ? 'No interests selected'
            : _onboardingData.preferences.interests.join(', ');
      case OnboardingStepType.notifications:
        return _onboardingData.preferences.enableNotifications
            ? 'Enabled'
            : 'Muted';
      case OnboardingStepType.privacy:
        return _onboardingData.preferences.acceptPrivacyPolicy
            ? 'Accepted'
            : 'Pending';
      case OnboardingStepType.welcome:
      case OnboardingStepType.completion:
        return '';
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
}

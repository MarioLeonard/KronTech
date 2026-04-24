import 'dart:convert';

import '../../../models/onboarding_data.dart';
import '../../../models/user_model.dart';
import '../../../utils/hive_service.dart';

class OnboardingStorage {
  static const String draftKey = 'onboarding_draft';
  static const String completedUserKey = 'onboarding_completed_user';
  static const String currentStepKey = 'onboarding_current_step';

  Future<OnboardingData?> loadDraft() async {
    final box = HiveService.getOnboardingBox();
    final savedData = box.get(draftKey);
    if (savedData == null) {
      return null;
    }
    return OnboardingData.fromMap(Map<String, dynamic>.from(savedData));
  }

  int loadCurrentStep() {
    final box = HiveService.getOnboardingBox();
    return box.get(currentStepKey, defaultValue: 0) as int;
  }

  Future<void> saveDraft(OnboardingData data) async {
    final box = HiveService.getOnboardingBox();
    await box.put(draftKey, data.toMap());
  }

  Future<void> saveCurrentStep(int step) async {
    final box = HiveService.getOnboardingBox();
    await box.put(currentStepKey, step);
  }

  Future<void> saveCompletedUser(UserModel user) async {
    final box = HiveService.getOnboardingBox();
    await box.put(completedUserKey, user.toMap());
  }

  Map<dynamic, dynamic> readAll() {
    final box = HiveService.getOnboardingBox();
    return box.toMap();
  }

  String prettyPrintAll() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(readAll());
  }
}

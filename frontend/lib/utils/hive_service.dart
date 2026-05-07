import 'package:hive_flutter/hive_flutter.dart';

/// Service to initialize and manage Hive database
class HiveService {
  static const String onboardingBoxName = 'onboarding';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters here if needed
    // Hive.registerAdapter(OnboardingDataAdapter());

    // Open boxes
    await Hive.openBox(onboardingBoxName);
  }

  /// Get the onboarding box
  static Box getOnboardingBox() {
    return Hive.box(onboardingBoxName);
  }

  /// Close all boxes (useful for testing or app shutdown)
  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  /// Clear all data from a specific box
  static Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}

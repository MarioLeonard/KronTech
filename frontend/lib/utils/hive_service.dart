import 'package:hive_flutter/hive_flutter.dart';

/// Service to initialize and manage Hive database
class HiveService {
  static const String onboardingBoxName = 'onboarding';
  static const String savedTripsBoxName = 'saved_trips';

  /// Initialize Hive and open all boxes
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters here if needed
    // Hive.registerAdapter(OnboardingDataAdapter());

    // Open boxes
    await Hive.openBox(onboardingBoxName);
    await Hive.openBox(savedTripsBoxName);
  }

  /// Get the onboarding box
  static Box getOnboardingBox() {
    return Hive.box(onboardingBoxName);
  }

  /// Get the saved trips cache box
  static Box getSavedTripsBox() {
    return Hive.box(savedTripsBoxName);
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

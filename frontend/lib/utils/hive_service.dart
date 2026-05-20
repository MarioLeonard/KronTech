import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String onboardingBoxName = 'onboarding';
  static const String savedTripsBoxName = 'saved_trips';

  static Future<void> init() async {
    await Hive.initFlutter();

    await Hive.openBox(onboardingBoxName);
    await Hive.openBox(savedTripsBoxName);
  }

  static Box getOnboardingBox() {
    return Hive.box(onboardingBoxName);
  }

  static Box getSavedTripsBox() {
    return Hive.box(savedTripsBoxName);
  }

  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }

  static Future<void> clearBox(String boxName) async {
    final box = Hive.box(boxName);
    await box.clear();
  }
}

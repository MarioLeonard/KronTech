part of 'onboarding_data.dart';

class PreferencesData {
  final List<String> interests;
  final bool enableNotifications;
  final bool acceptPrivacyPolicy;

  PreferencesData({
    required this.interests,
    required this.enableNotifications,
    required this.acceptPrivacyPolicy,
  });

  Map<String, dynamic> toMap() {
    return {
      'interests': interests,
      'enableNotifications': enableNotifications,
      'acceptPrivacyPolicy': acceptPrivacyPolicy,
    };
  }

  factory PreferencesData.fromMap(Map<String, dynamic> map) {
    return PreferencesData(
      interests: List<String>.from(map['interests'] ?? []),
      enableNotifications: map['enableNotifications'] ?? false,
      acceptPrivacyPolicy: map['acceptPrivacyPolicy'] ?? false,
    );
  }

  factory PreferencesData.empty() {
    return PreferencesData(
      interests: [],
      enableNotifications: true,
      acceptPrivacyPolicy: false,
    );
  }

  PreferencesData copyWith({
    List<String>? interests,
    bool? enableNotifications,
    bool? acceptPrivacyPolicy,
  }) {
    return PreferencesData(
      interests: interests ?? this.interests,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      acceptPrivacyPolicy: acceptPrivacyPolicy ?? this.acceptPrivacyPolicy,
    );
  }

  bool get isValid => acceptPrivacyPolicy;
}

part 'address_data.dart';
part 'preferences_data.dart';
part 'profile_info_data.dart';

class OnboardingData {
  final ProfileInfoData profileInfo;
  final AddressData address;
  final PreferencesData preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  OnboardingData({
    required this.profileInfo,
    required this.address,
    required this.preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'profileInfo': profileInfo.toMap(),
      'address': address.toMap(),
      'preferences': preferences.toMap(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OnboardingData.fromMap(Map<String, dynamic> map) {
    return OnboardingData(
      profileInfo: ProfileInfoData.fromMap(map['profileInfo'] ?? {}),
      address: AddressData.fromMap(map['address'] ?? {}),
      preferences: PreferencesData.fromMap(map['preferences'] ?? {}),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  factory OnboardingData.empty() {
    return OnboardingData(
      profileInfo: ProfileInfoData.empty(),
      address: AddressData.empty(),
      preferences: PreferencesData.empty(),
    );
  }

  OnboardingData copyWith({
    ProfileInfoData? profileInfo,
    AddressData? address,
    PreferencesData? preferences,
  }) {
    return OnboardingData(
      profileInfo: profileInfo ?? this.profileInfo,
      address: address ?? this.address,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isAllStepsValid =>
      profileInfo.isValid && address.isValid && preferences.isValid;
}

// Models for storing onboarding data collected at each step

class ProfileInfoData {
  static final DateTime defaultDateOfBirth = DateTime(2007);

  final String firstName;
  final String lastName;
  final String email;
  final DateTime dateOfBirth;
  final bool hasSelectedDateOfBirth;
  final String gender; // male, female, other

  ProfileInfoData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.hasSelectedDateOfBirth,
    required this.gender,
  });

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'hasSelectedDateOfBirth': hasSelectedDateOfBirth,
      'gender': gender,
    };
  }

  /// Create from Map
  factory ProfileInfoData.fromMap(Map<String, dynamic> map) {
    return ProfileInfoData(
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: DateTime.parse(
        map['dateOfBirth'] ?? defaultDateOfBirth.toIso8601String(),
      ),
      hasSelectedDateOfBirth: map['hasSelectedDateOfBirth'] ?? false,
      gender: map['gender'] ?? '',
    );
  }

  /// Create empty instance
  factory ProfileInfoData.empty() {
    return ProfileInfoData(
      firstName: '',
      lastName: '',
      email: '',
      dateOfBirth: defaultDateOfBirth,
      hasSelectedDateOfBirth: false,
      gender: '',
    );
  }

  /// Copy with changes
  ProfileInfoData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    bool? hasSelectedDateOfBirth,
    String? gender,
  }) {
    return ProfileInfoData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hasSelectedDateOfBirth:
          hasSelectedDateOfBirth ?? this.hasSelectedDateOfBirth,
      gender: gender ?? this.gender,
    );
  }

  bool get isValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      gender.isNotEmpty;
}

class AddressData {
  final String country;
  final String city;
  final String street;
  final String zipCode;

  AddressData({
    required this.country,
    required this.city,
    required this.street,
    required this.zipCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'country': country,
      'city': city,
      'street': street,
      'zipCode': zipCode,
    };
  }

  factory AddressData.fromMap(Map<String, dynamic> map) {
    return AddressData(
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      zipCode: map['zipCode'] ?? '',
    );
  }

  factory AddressData.empty() {
    return AddressData(country: '', city: '', street: '', zipCode: '');
  }

  AddressData copyWith({
    String? country,
    String? city,
    String? street,
    String? zipCode,
  }) {
    return AddressData(
      country: country ?? this.country,
      city: city ?? this.city,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
    );
  }

  bool get isValid =>
      country.isNotEmpty && city.isNotEmpty && street.isNotEmpty;
}

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

/// Main onboarding data container
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

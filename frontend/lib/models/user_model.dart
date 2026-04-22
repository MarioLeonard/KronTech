import 'onboarding_data.dart';
import 'package:uuid/uuid.dart';

/// Final User model constructed from onboarding data
class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final DateTime dateOfBirth;
  final String gender;
  final String country;
  final String city;
  final String street;
  final String zipCode;
  final List<String> interests;
  final bool enableNotifications;
  final bool acceptPrivacyPolicy;
  final DateTime createdAt;
  final bool onboardingCompleted;

  UserModel({
    String? id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.country,
    required this.city,
    required this.street,
    required this.zipCode,
    required this.interests,
    required this.enableNotifications,
    required this.acceptPrivacyPolicy,
    DateTime? createdAt,
    this.onboardingCompleted = true,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  /// Create UserModel from OnboardingData
  factory UserModel.fromOnboardingData(OnboardingData data) {
    return UserModel(
      firstName: data.profileInfo.firstName,
      lastName: data.profileInfo.lastName,
      email: data.profileInfo.email,
      dateOfBirth: data.profileInfo.dateOfBirth,
      gender: data.profileInfo.gender,
      country: data.address.country,
      city: data.address.city,
      street: data.address.street,
      zipCode: data.address.zipCode,
      interests: data.preferences.interests,
      enableNotifications: data.preferences.enableNotifications,
      acceptPrivacyPolicy: data.preferences.acceptPrivacyPolicy,
      createdAt: data.createdAt,
    );
  }

  /// Get user's full name
  String get fullName => '$firstName $lastName';

  /// Get user's age
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  /// Get user's complete address
  String get completeAddress => '$street, $city, $zipCode, $country';

  /// Convert to Map for storage or API calls
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'country': country,
      'city': city,
      'street': street,
      'zipCode': zipCode,
      'interests': interests,
      'enableNotifications': enableNotifications,
      'acceptPrivacyPolicy': acceptPrivacyPolicy,
      'createdAt': createdAt.toIso8601String(),
      'onboardingCompleted': onboardingCompleted,
    };
  }

  /// Create from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      dateOfBirth: DateTime.parse(
        map['dateOfBirth'] ?? DateTime.now().toIso8601String(),
      ),
      gender: map['gender'] ?? '',
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      street: map['street'] ?? '',
      zipCode: map['zipCode'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      enableNotifications: map['enableNotifications'] ?? false,
      acceptPrivacyPolicy: map['acceptPrivacyPolicy'] ?? false,
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      onboardingCompleted: map['onboardingCompleted'] ?? true,
    );
  }

  /// Copy with changes
  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    String? gender,
    String? country,
    String? city,
    String? street,
    String? zipCode,
    List<String>? interests,
    bool? enableNotifications,
    bool? acceptPrivacyPolicy,
    DateTime? createdAt,
    bool? onboardingCompleted,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
      interests: interests ?? this.interests,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      acceptPrivacyPolicy: acceptPrivacyPolicy ?? this.acceptPrivacyPolicy,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $fullName, email: $email, age: $age)';
  }
}

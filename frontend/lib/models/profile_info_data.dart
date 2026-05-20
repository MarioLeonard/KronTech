part of 'onboarding_data.dart';

class ProfileInfoData {
  static final DateTime defaultDateOfBirth = DateTime(2007);

  final String firstName;
  final String lastName;
  final String email;
  final DateTime dateOfBirth;
  final bool hasSelectedDateOfBirth;
  final String gender;
  final String profilePhotoDataUrl;

  ProfileInfoData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dateOfBirth,
    required this.hasSelectedDateOfBirth,
    required this.gender,
    required this.profilePhotoDataUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'hasSelectedDateOfBirth': hasSelectedDateOfBirth,
      'gender': gender,
      'profilePhotoDataUrl': profilePhotoDataUrl,
    };
  }

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
      profilePhotoDataUrl: map['profilePhotoDataUrl'] ?? '',
    );
  }

  factory ProfileInfoData.empty() {
    return ProfileInfoData(
      firstName: '',
      lastName: '',
      email: '',
      dateOfBirth: defaultDateOfBirth,
      hasSelectedDateOfBirth: false,
      gender: '',
      profilePhotoDataUrl: '',
    );
  }

  ProfileInfoData copyWith({
    String? firstName,
    String? lastName,
    String? email,
    DateTime? dateOfBirth,
    bool? hasSelectedDateOfBirth,
    String? gender,
    String? profilePhotoDataUrl,
  }) {
    return ProfileInfoData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      hasSelectedDateOfBirth:
          hasSelectedDateOfBirth ?? this.hasSelectedDateOfBirth,
      gender: gender ?? this.gender,
      profilePhotoDataUrl: profilePhotoDataUrl ?? this.profilePhotoDataUrl,
    );
  }

  bool get isValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      gender.isNotEmpty;
}

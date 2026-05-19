class UserProfile {
  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.bio,
    this.location,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.country,
    this.city,
    this.street,
    this.hasCompletedOnboarding = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl:
          json['profilePhotoUrl'] as String? ??
          json['photo_url'] as String? ??
          json['profilePhotoDataUrl'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      street: json['street'] as String?,
      hasCompletedOnboarding:
          json['hasCompletedOnboarding'] as bool? ??
          json['has_completed_onboarding'] as bool? ??
          false,
    );
  }

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final String? bio;
  final String? location;
  final String? firstName;
  final String? lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? country;
  final String? city;
  final String? street;
  final bool hasCompletedOnboarding;

  String get fullName {
    final first = firstName?.trim() ?? '';
    final last = lastName?.trim() ?? '';
    return [first, last].where((value) => value.isNotEmpty).join(' ');
  }

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    String? bio,
    String? location,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? gender,
    String? country,
    String? city,
    String? street,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      country: country ?? this.country,
      city: city ?? this.city,
      street: street ?? this.street,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

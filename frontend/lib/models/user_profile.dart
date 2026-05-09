class UserProfile {
  const UserProfile({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
    this.bio,
    this.location,
    this.hasCompletedOnboarding = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? json['id'] as String? ?? '',
      email: json['email'] as String?,
      displayName: json['display_name'] as String?,
      photoUrl:
          json['photo_url'] as String? ??
          json['profilePhotoUrl'] as String? ??
          json['profilePhotoDataUrl'] as String?,
      emailVerified: json['email_verified'] as bool? ?? false,
      bio: json['bio'] as String?,
      location: json['location'] as String?,
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
  final bool hasCompletedOnboarding;
}

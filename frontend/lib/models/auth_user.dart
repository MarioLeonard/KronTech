import 'package:frontend/models/user_profile.dart';

enum AuthProviderType { google, emailPassword }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.provider,
    required this.idToken,
    this.profile,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final String id;
  final String idToken;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final UserProfile? profile;
  final AuthProviderType provider;

  String? get effectivePhotoUrl => profile?.photoUrl ?? photoUrl;

  bool get hasCompletedOnboarding {
    return profile?.hasCompletedOnboarding ?? false;
  }

  AuthUser copyWith({
    String? id,
    String? idToken,
    String? email,
    String? displayName,
    String? photoUrl,
    UserProfile? profile,
    AuthProviderType? provider,
  }) {
    return AuthUser(
      id: id ?? this.id,
      idToken: idToken ?? this.idToken,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      profile: profile ?? this.profile,
      provider: provider ?? this.provider,
    );
  }
}

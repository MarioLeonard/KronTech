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
  });

  final String id;
  final String idToken;
  final String? email;
  final String? displayName;
  final UserProfile? profile;
  final AuthProviderType provider;

  bool get hasCompletedOnboarding {
    return profile?.hasCompletedOnboarding ?? false;
  }

  AuthUser copyWith({
    String? id,
    String? idToken,
    String? email,
    String? displayName,
    UserProfile? profile,
    AuthProviderType? provider,
  }) {
    return AuthUser(
      id: id ?? this.id,
      idToken: idToken ?? this.idToken,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      profile: profile ?? this.profile,
      provider: provider ?? this.provider,
    );
  }
}

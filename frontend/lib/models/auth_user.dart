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
}

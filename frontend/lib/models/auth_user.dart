enum AuthProviderType { google, emailPassword }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.provider,
    required this.idToken,
    this.email,
    this.displayName,
  });

  final String id;
  final String idToken;
  final String? email;
  final String? displayName;
  final AuthProviderType provider;
}

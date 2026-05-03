enum AuthProviderType { google }

class AuthUser {
  const AuthUser({
    required this.id,
    required this.provider,
    this.email,
    this.displayName,
  });

  final String id;
  final String? email;
  final String? displayName;
  final AuthProviderType provider;
}

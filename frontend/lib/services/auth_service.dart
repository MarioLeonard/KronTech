import 'package:frontend/models/auth_user.dart';

enum EmailPasswordAuthMode { signIn, createAccount }

abstract class AuthService {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> continueWithGoogle();
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
    required EmailPasswordAuthMode mode,
  });
  Future<void> signOut();
}

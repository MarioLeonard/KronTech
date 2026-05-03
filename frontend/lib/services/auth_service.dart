import 'package:frontend/models/auth_user.dart';

abstract class AuthService {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> continueWithGoogle();
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  });
  Future<void> signOut();
}

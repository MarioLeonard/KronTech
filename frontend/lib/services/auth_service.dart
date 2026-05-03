import 'package:frontend/models/auth_user.dart';

abstract class AuthService {
  Stream<AuthUser?> authStateChanges();
  Future<AuthUser> continueWithGoogle();
  Future<void> signOut();
}

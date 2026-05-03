import 'package:frontend/models/auth_user.dart';

abstract class AuthService {
  Future<AuthUser> continueWithGoogle();
  Future<AuthUser> continueWithApple();
  Future<AuthUser> continueWithEmailPassword({
    required String email,
    required String password,
  });
}

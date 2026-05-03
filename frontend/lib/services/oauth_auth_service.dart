import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/services/backend_api_service.dart';

class OAuthAuthService implements AuthService {
  OAuthAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    BackendApiService? backendApiService,
  }) : _firebaseAuth = firebaseAuth,
       _backendApiService = backendApiService ?? BackendApiService();

  firebase_auth.FirebaseAuth? _firebaseAuth;
  final BackendApiService _backendApiService;
  AuthUser? _lastSyncedUser;

  firebase_auth.FirebaseAuth get _auth {
    return _firebaseAuth ??= firebase_auth.FirebaseAuth.instance;
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _auth.authStateChanges().asyncMap(_toNullableAuthUser);
  }

  @override
  Future<AuthUser> continueWithGoogle() async {
    if (!kIsWeb) {
      throw const AuthException(
        code: 'unsupported_platform',
        message: 'Google login is currently configured for web only.',
      );
    }

    try {
      final provider = firebase_auth.GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});

      final credential = await _auth.signInWithPopup(provider);
      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          code: 'missing_user',
          message: 'Firebase did not return a valid user.',
        );
      }

      return _completeSignIn(user, provider: AuthProviderType.google);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(
        code: error.code,
        message: _toFirebaseReadableMessage(error),
      );
    } catch (_) {
      throw const AuthException(
        code: 'unexpected',
        message: 'Could not complete authentication. Please try again.',
      );
    }
  }

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
    required EmailPasswordAuthMode mode,
  }) async {
    try {
      final normalizedEmail = email.trim();
      final credential = switch (mode) {
        EmailPasswordAuthMode.signIn => await _auth.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        ),
        EmailPasswordAuthMode.createAccount =>
          await _auth.createUserWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          ),
      };
      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          code: 'missing_user',
          message: 'Firebase did not return a valid user.',
        );
      }

      return _completeSignIn(user, provider: AuthProviderType.emailPassword);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw AuthException(
        code: error.code,
        message: _toFirebaseReadableMessage(error),
      );
    } catch (_) {
      throw const AuthException(
        code: 'unexpected',
        message: 'Could not complete authentication. Please try again.',
      );
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<AuthUser> _completeSignIn(
    firebase_auth.User user, {
    required AuthProviderType provider,
  }) async {
    try {
      return await _toAuthUser(user, provider: provider);
    } on AuthException {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<AuthUser> _toAuthUser(
    firebase_auth.User user, {
    required AuthProviderType provider,
  }) async {
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        code: 'missing_token',
        message: 'Firebase did not provide a valid token.',
      );
    }

    final cachedUser = _lastSyncedUser;
    if (cachedUser != null &&
        cachedUser.id == user.uid &&
        cachedUser.idToken == idToken) {
      return cachedUser;
    }

    final profile = await _backendApiService.syncAuthenticatedUser(idToken);

    final authUser = AuthUser(
      id: user.uid,
      idToken: idToken,
      email: profile.email ?? user.email,
      displayName: profile.displayName ?? user.displayName,
      profile: profile,
      provider: provider,
    );
    _lastSyncedUser = authUser;
    return authUser;
  }

  Future<AuthUser?> _toNullableAuthUser(firebase_auth.User? user) async {
    if (user == null) {
      return null;
    }

    return _completeSignIn(user, provider: _readProvider(user));
  }

  AuthProviderType _readProvider(firebase_auth.User user) {
    final providerIds = user.providerData.map((info) => info.providerId);
    if (providerIds.contains('password')) {
      return AuthProviderType.emailPassword;
    }

    return AuthProviderType.google;
  }

  String _toFirebaseReadableMessage(firebase_auth.FirebaseAuthException error) {
    switch (error.code) {
      case 'popup-closed-by-user':
      case 'web-context-cancelled':
      case 'cancelled-popup-request':
        return 'Google sign-in was cancelled.';
      case 'account-exists-with-different-credential':
        return 'An account already exists for this email using a different sign-in method.';
      case 'network-request-failed':
        return 'The internet connection failed. Check your network and try again.';
      case 'unauthorized-domain':
        return 'This application domain is not authorized in Firebase Authentication.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account exists for this email. Create a new account.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return error.message ??
            'Firebase authentication failed. Please try again.';
    }
  }
}

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/models/user_profile.dart';
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
  String? _syncInProgressKey;
  Future<AuthUser>? _syncInProgress;
  firebase_auth.AuthCredential? _pendingLinkCredential;
  String? _pendingLinkEmail;
  AuthProviderType? _pendingLinkProvider;
  static const Duration _googlePopupTimeout = Duration(seconds: 6);

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

      final credential = await _auth
          .signInWithPopup(provider)
          .timeout(_googlePopupTimeout);
      final user = credential.user;

      if (user == null) {
        throw const AuthException(
          code: 'missing_user',
          message: 'Firebase did not return a valid user.',
        );
      }

      final linkedUser = await _linkPendingCredentialIfNeeded(
        user,
        signedInProvider: AuthProviderType.google,
      );
      return _completeSignIn(linkedUser, provider: AuthProviderType.google);
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'account-exists-with-different-credential') {
        _storePendingLinkCredential(
          email: error.email,
          credential: error.credential,
          provider: AuthProviderType.google,
        );
        throw AuthException(
          code: error.code,
          message:
              'This email already has an account. Sign in with email and password to link Google to it.',
        );
      }
      throw AuthException(
        code: error.code,
        message: _toFirebaseReadableMessage(error),
      );
    } on TimeoutException {
      throw const AuthException(
        code: 'popup-timeout',
        message: 'Google sign-in was cancelled.',
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
    final normalizedEmail = email.trim();
    try {
      if (mode == EmailPasswordAuthMode.createAccount) {
        final linkedCurrentUser = await _linkEmailPasswordToCurrentUser(
          email: normalizedEmail,
          password: password,
        );
        if (linkedCurrentUser != null) {
          return _completeSignIn(
            linkedCurrentUser,
            provider: AuthProviderType.emailPassword,
          );
        }
      }

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

      final linkedUser = await _linkPendingCredentialIfNeeded(
        user,
        signedInProvider: AuthProviderType.emailPassword,
      );
      return _completeSignIn(
        linkedUser,
        provider: AuthProviderType.emailPassword,
      );
    } on AuthException {
      rethrow;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (mode == EmailPasswordAuthMode.createAccount &&
          error.code == 'email-already-in-use') {
        final emailPasswordCredential =
            firebase_auth.EmailAuthProvider.credential(
              email: normalizedEmail,
              password: password,
            );
        _storePendingLinkCredential(
          email: normalizedEmail,
          credential: emailPasswordCredential,
          provider: AuthProviderType.emailPassword,
        );
        try {
          return await continueWithGoogle();
        } on AuthException {
          rethrow;
        } on firebase_auth.FirebaseAuthException {
          throw AuthException(
            code: error.code,
            message:
                'This email already exists. Sign in with Google to link this password to the same account.',
          );
        }
      }
      if (mode == EmailPasswordAuthMode.createAccount &&
          error.code == 'credential-already-in-use') {
        throw AuthException(
          code: error.code,
          message: 'This email and password are already linked. Sign in.',
        );
      }
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
    _clearPendingLinkCredential();
    return _auth.signOut();
  }

  void _storePendingLinkCredential({
    required String? email,
    required firebase_auth.AuthCredential? credential,
    required AuthProviderType provider,
  }) {
    _pendingLinkEmail = email?.trim().toLowerCase();
    _pendingLinkCredential = credential;
    _pendingLinkProvider = provider;
  }

  void _clearPendingLinkCredential() {
    _pendingLinkEmail = null;
    _pendingLinkCredential = null;
    _pendingLinkProvider = null;
  }

  Future<firebase_auth.User?> _linkEmailPasswordToCurrentUser({
    required String email,
    required String password,
  }) async {
    final currentUser = _auth.currentUser;
    final currentEmail = currentUser?.email?.trim().toLowerCase();
    if (currentUser == null || currentEmail != email.trim().toLowerCase()) {
      return null;
    }

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {
      await currentUser.linkWithCredential(credential);
      await currentUser.reload();
      _clearPendingLinkCredential();
      _lastSyncedUser = null;
      return _auth.currentUser ?? currentUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked') {
        return currentUser;
      }
      rethrow;
    }
  }

  Future<firebase_auth.User> _linkPendingCredentialIfNeeded(
    firebase_auth.User user, {
    required AuthProviderType signedInProvider,
  }) async {
    final pendingCredential = _pendingLinkCredential;
    final pendingEmail = _pendingLinkEmail;
    final pendingProvider = _pendingLinkProvider;
    final signedInEmail = user.email?.trim().toLowerCase();

    if (pendingCredential == null ||
        pendingEmail == null ||
        pendingProvider == null ||
        pendingProvider == signedInProvider) {
      return user;
    }

    if (signedInEmail != pendingEmail) {
      await _auth.signOut();
      throw const AuthException(
        code: 'link_email_mismatch',
        message: 'Use the same email address to link these sign-in methods.',
      );
    }

    try {
      await user.linkWithCredential(pendingCredential);
      await user.reload();
      _clearPendingLinkCredential();
      _lastSyncedUser = null;
      return _auth.currentUser ?? user;
    } on firebase_auth.FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked' ||
          error.code == 'credential-already-in-use') {
        _clearPendingLinkCredential();
        return user;
      }
      rethrow;
    }
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

    final syncKey = '${user.uid}:$idToken';
    final syncInProgress = _syncInProgress;
    if (_syncInProgressKey == syncKey && syncInProgress != null) {
      return syncInProgress;
    }

    final syncFuture = _syncBackendProfile(
      user,
      idToken: idToken,
      provider: provider,
    );
    _syncInProgressKey = syncKey;
    _syncInProgress = syncFuture;

    try {
      return await syncFuture;
    } finally {
      if (_syncInProgressKey == syncKey) {
        _syncInProgressKey = null;
        _syncInProgress = null;
      }
    }
  }

  Future<AuthUser> _syncBackendProfile(
    firebase_auth.User user, {
    required String idToken,
    required AuthProviderType provider,
  }) async {
    final profile = await _backendApiService.syncAuthenticatedUser(idToken);

    final authUser = AuthUser(
      id: user.uid,
      idToken: idToken,
      email: profile.email ?? user.email,
      displayName: profile.displayName ?? user.displayName,
      photoUrl: user.photoURL,
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

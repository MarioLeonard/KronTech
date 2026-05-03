import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/services/auth_service.dart';

class OAuthAuthService implements AuthService {
  OAuthAuthService({firebase_auth.FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth;

  firebase_auth.FirebaseAuth? _firebaseAuth;

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
        message: 'Google login este configurat momentan pentru web.',
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
          message: 'Firebase nu a returnat un utilizator valid.',
        );
      }

      return _toAuthUser(user, provider: AuthProviderType.google);
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
        message: 'Nu am putut finaliza autentificarea. Incearca din nou.',
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
          message: 'Firebase nu a returnat un utilizator valid.',
        );
      }

      return _toAuthUser(user, provider: AuthProviderType.emailPassword);
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
        message: 'Nu am putut finaliza autentificarea. Incearca din nou.',
      );
    }
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  Future<AuthUser> _toAuthUser(
    firebase_auth.User user, {
    required AuthProviderType provider,
  }) async {
    final idToken = await user.getIdToken();
    if (idToken == null || idToken.isEmpty) {
      throw const AuthException(
        code: 'missing_token',
        message: 'Firebase nu a furnizat un token valid.',
      );
    }

    return AuthUser(
      id: user.uid,
      idToken: idToken,
      email: user.email,
      displayName: user.displayName,
      provider: provider,
    );
  }

  Future<AuthUser?> _toNullableAuthUser(firebase_auth.User? user) async {
    if (user == null) {
      return null;
    }

    return _toAuthUser(user, provider: _readProvider(user));
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
        return 'Autentificarea cu Google a fost anulata.';
      case 'account-exists-with-different-credential':
        return 'Exista deja un cont cu acest email folosind alta metoda de autentificare.';
      case 'network-request-failed':
        return 'Conexiunea la internet a esuat. Verifica reteaua si incearca din nou.';
      case 'unauthorized-domain':
        return 'Domeniul aplicatiei nu este autorizat in Firebase Authentication.';
      case 'invalid-email':
        return 'Email-ul nu este valid.';
      case 'user-disabled':
        return 'Contul acesta a fost dezactivat.';
      case 'user-not-found':
        return 'Nu exista un cont pentru acest email. Creeaza un cont nou.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email sau parola incorecta.';
      case 'email-already-in-use':
        return 'Exista deja un cont pentru acest email.';
      case 'too-many-requests':
        return 'Prea multe incercari. Incearca din nou mai tarziu.';
      default:
        return error.message ??
            'Autentificarea Firebase a esuat. Incearca din nou.';
    }
  }
}

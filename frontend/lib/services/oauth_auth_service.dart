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
    return _auth.authStateChanges().map(_toNullableAuthUser);
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

      return _toAuthUser(user);
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

  AuthUser _toAuthUser(firebase_auth.User user) {
    return AuthUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      provider: AuthProviderType.google,
    );
  }

  AuthUser? _toNullableAuthUser(firebase_auth.User? user) {
    if (user == null) {
      return null;
    }

    return _toAuthUser(user);
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
      default:
        return error.message ??
            'Autentificarea Firebase cu Google a esuat. Incearca din nou.';
    }
  }
}

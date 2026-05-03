import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/services/auth_service.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthProvider extends ChangeNotifier {
  AuthProvider({required AuthService authService})
    : _authService = authService {
    _authSubscription = _authService.authStateChanges().listen((user) {
      _user = user;
      _status = user == null ? AuthStatus.idle : AuthStatus.authenticated;
      _errorMessage = null;
      _activeProvider = null;
      notifyListeners();
    });
  }

  final AuthService _authService;
  late final StreamSubscription<AuthUser?> _authSubscription;

  AuthStatus _status = AuthStatus.idle;
  AuthUser? _user;
  String? _errorMessage;
  AuthProviderType? _activeProvider;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get errorMessage => _errorMessage;
  AuthProviderType? get activeProvider => _activeProvider;

  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated =>
      _status == AuthStatus.authenticated && _user != null;

  Future<void> signInWithGoogle() {
    return _runSignIn(AuthProviderType.google, _authService.continueWithGoogle);
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim();

    if (normalizedEmail.isEmpty || password.isEmpty) {
      _status = AuthStatus.error;
      _errorMessage = 'Completeaza email-ul si parola.';
      notifyListeners();
      return Future<void>.value();
    }

    return _runSignIn(
      AuthProviderType.emailPassword,
      () => _authService.signInWithEmailPassword(
        email: normalizedEmail,
        password: password,
      ),
    );
  }

  Future<void> _runSignIn(
    AuthProviderType provider,
    Future<AuthUser> Function() signInAction,
  ) async {
    if (isLoading) {
      return;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    _activeProvider = provider;
    notifyListeners();

    try {
      final user = await signInAction();
      _user = user;
      _status = AuthStatus.authenticated;
    } on AuthException catch (error) {
      _status = AuthStatus.error;
      _errorMessage = error.message;
    } catch (_) {
      _status = AuthStatus.error;
      _errorMessage = 'A aparut o eroare neasteptata. Incearca din nou.';
    } finally {
      _activeProvider = null;
      notifyListeners();
    }
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.idle;
    }
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

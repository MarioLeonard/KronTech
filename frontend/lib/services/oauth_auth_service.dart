import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/models/auth_exception.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:frontend/utils/api_endpoints.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class OAuthAuthService implements AuthService {
  OAuthAuthService({
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? secureStorage,
    http.Client? httpClient,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: const ['email']),
       _secureStorage = secureStorage ?? const FlutterSecureStorage(),
       _httpClient = httpClient;

  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _secureStorage;
  http.Client? _httpClient;

  http.Client get _client => _httpClient ??= http.Client();

  static const _providerStorageKey = 'last_auth_provider';
  static const _idTokenStorageKey = 'pending_id_token';

  @override
  Future<AuthUser> continueWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        throw const AuthException(
          code: 'cancelled',
          message: 'Autentificarea cu Google a fost anulata.',
        );
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException(
          code: 'missing_token',
          message: 'Google nu a furnizat un token valid.',
        );
      }

      await _persistAuthMetadata(
        provider: AuthProviderType.google,
        idToken: idToken,
      );

      return AuthUser(
        id: account.id,
        email: account.email,
        displayName: account.displayName,
        provider: AuthProviderType.google,
      );
    } on AuthException {
      rethrow;
    } on PlatformException catch (error) {
      throw AuthException(
        code: error.code,
        message: _toReadableMessage(error.code),
      );
    } catch (_) {
      throw const AuthException(
        code: 'unexpected',
        message: 'Nu am putut finaliza autentificarea. Incearca din nou.',
      );
    }
  }

  @override
  Future<AuthUser> continueWithApple() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw const AuthException(
          code: 'unavailable',
          message: 'Sign in with Apple nu este disponibil pe acest dispozitiv.',
        );
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null || identityToken.isEmpty) {
        throw const AuthException(
          code: 'missing_token',
          message: 'Apple nu a furnizat un token valid.',
        );
      }

      await _persistAuthMetadata(
        provider: AuthProviderType.apple,
        idToken: identityToken,
      );

      return AuthUser(
        id: credential.userIdentifier ?? 'apple-user',
        email: credential.email,
        displayName: null,
        provider: AuthProviderType.apple,
      );
    } on AuthException {
      rethrow;
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const AuthException(
          code: 'cancelled',
          message: 'Autentificarea cu Apple a fost anulata.',
        );
      }
      throw AuthException(
        code: error.code.name,
        message: 'Autentificarea cu Apple a esuat. Incearca din nou.',
      );
    } on PlatformException catch (error) {
      throw AuthException(
        code: error.code,
        message: _toReadableMessage(error.code),
      );
    } catch (_) {
      throw const AuthException(
        code: 'unexpected',
        message: 'Nu am putut finaliza autentificarea. Incearca din nou.',
      );
    }
  }

  @override
  Future<AuthUser> continueWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) {
      throw const AuthException(
        code: 'invalid_input',
        message: 'Completeaza email-ul si parola.',
      );
    }

    if (password.length < 6) {
      throw const AuthException(
        code: 'invalid_input',
        message: 'Parola trebuie sa aiba cel putin 6 caractere.',
      );
    }

    if (ApiEndpoints.baseUrl == 'https://api.example.com') {
      await _persistAuthMetadata(
        provider: AuthProviderType.emailPassword,
        idToken: 'local-dev-session',
      );

      return AuthUser(
        id: email,
        email: email,
        displayName: email.split('@').first,
        provider: AuthProviderType.emailPassword,
      );
    }

    final url = Uri.parse(
      '${ApiEndpoints.baseUrl}${ApiEndpoints.emailPasswordLogin}',
    );

    try {
      final response = await _client.post(
        url,
        headers: const {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final payload = _decodeJsonMap(response.body);
        final userPayload = payload['user'] is Map<String, dynamic>
            ? payload['user'] as Map<String, dynamic>
            : payload;

        final token =
            _readString(payload, const ['id_token', 'token', 'access_token']) ??
            'session';

        await _persistAuthMetadata(
          provider: AuthProviderType.emailPassword,
          idToken: token,
        );

        return AuthUser(
          id: _readString(userPayload, const ['id', 'uid', 'user_id']) ?? email,
          email: _readString(userPayload, const ['email']) ?? email,
          displayName: _readString(userPayload, const ['display_name', 'name']),
          provider: AuthProviderType.emailPassword,
        );
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AuthException(
          code: 'invalid_credentials',
          message: 'Email sau parola invalida.',
        );
      }

      final payload = _decodeJsonMap(response.body);
      throw AuthException(
        code: 'backend_error',
        message:
            _readString(payload, const ['message', 'error']) ??
            'Autentificarea a esuat. Incearca din nou.',
      );
    } on AuthException {
      rethrow;
    } on FormatException {
      throw const AuthException(
        code: 'invalid_response',
        message: 'Raspuns invalid de la server.',
      );
    } catch (_) {
      throw const AuthException(
        code: 'network_error',
        message: 'Conexiunea a esuat. Incearca din nou.',
      );
    }
  }

  Map<String, dynamic> _decodeJsonMap(String body) {
    if (body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw const FormatException('Expected a JSON object');
  }

  String? _readString(Map<String, dynamic> source, List<String> keys) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  Future<void> _persistAuthMetadata({
    required AuthProviderType provider,
    required String idToken,
  }) async {
    await _secureStorage.write(key: _providerStorageKey, value: provider.name);
    await _secureStorage.write(key: _idTokenStorageKey, value: idToken);
  }

  String _toReadableMessage(String errorCode) {
    switch (errorCode) {
      case 'network_error':
      case 'network-request-failed':
        return 'Conexiunea la internet a esuat. Verifica reteaua si incearca din nou.';
      case 'sign_in_failed':
        return 'Autentificarea a esuat. Incearca din nou.';
      default:
        return 'A aparut o eroare neasteptata. Incearca din nou.';
    }
  }
}

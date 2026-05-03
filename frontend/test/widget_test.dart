import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows login entry point for unauthenticated users', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(authService: _FakeAuthService()),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );

    await tester.pump();

    expect(find.text('KronTech'), findsOneWidget);
    expect(find.text('Sign in with Email'), findsNothing);
    expect(find.text('Password'), findsNothing);
    expect(find.text('Create new account'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'test@gmail.com');
    await tester.pump();

    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign in with Email'), findsNothing);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123456',
    );
    await tester.pump();

    expect(find.text('Sign in with Email'), findsOneWidget);
    expect(find.text('Create new account'), findsOneWidget);

    await tester.tap(find.text('Create new account'));
    await tester.pump();

    expect(find.text('Confirm password'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });
}

class _FakeAuthService implements AuthService {
  @override
  Stream<AuthUser?> authStateChanges() {
    return Stream<AuthUser?>.value(null);
  }

  @override
  Future<AuthUser> continueWithGoogle() {
    return Future<AuthUser>.value(
      const AuthUser(
        id: 'test-user',
        idToken: 'test-id-token',
        provider: AuthProviderType.google,
      ),
    );
  }

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
    required EmailPasswordAuthMode mode,
  }) {
    return Future<AuthUser>.value(
      const AuthUser(
        id: 'test-user',
        idToken: 'test-id-token',
        provider: AuthProviderType.emailPassword,
      ),
    );
  }

  @override
  Future<void> signOut() {
    return Future<void>.value();
  }
}

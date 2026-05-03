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
    expect(find.text('Continue with Google'), findsOneWidget);
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
      const AuthUser(id: 'test-user', provider: AuthProviderType.google),
    );
  }

  @override
  Future<void> signOut() {
    return Future<void>.value();
  }
}

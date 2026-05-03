import 'package:flutter/material.dart';
import 'package:frontend/components/social_auth_button.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isLoading = authProvider.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'KronTech',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sign in with your Google account',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 28),
                  if (authProvider.errorMessage != null) ...[
                    _ErrorBanner(
                      message: authProvider.errorMessage!,
                      onDismiss: authProvider.clearError,
                    ),
                    const SizedBox(height: 16),
                  ],
                  SocialAuthButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: isLoading ? null : authProvider.signInWithGoogle,
                    isLoading:
                        isLoading &&
                        authProvider.activeProvider == AuthProviderType.google,
                    backgroundColor: const Color(0xFF1F3A5F),
                    foregroundColor: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    const LinearProgressIndicator(
                      minHeight: 4,
                      borderRadius: BorderRadius.all(Radius.circular(100)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE57373)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFC62828)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Color(0xFFB71C1C)),
              ),
            ),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              tooltip: 'Dismiss error',
            ),
          ],
        ),
      ),
    );
  }
}

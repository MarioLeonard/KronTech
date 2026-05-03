import 'package:flutter/material.dart';
import 'package:frontend/components/social_auth_button.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/services/auth_service.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _emailRegex = RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[A-Za-z]{2,}$');

  bool _hidePassword = true;
  bool _hideConfirmPassword = true;
  bool _isCreatingAccount = false;

  bool get _hasValidEmail {
    return _emailRegex.hasMatch(_emailController.text.trim());
  }

  bool get _hasValidPassword {
    return _passwordController.text.length >= 6;
  }

  bool get _hasValidConfirmPassword {
    return !_isCreatingAccount ||
        _confirmPasswordController.text == _passwordController.text;
  }

  bool get _canSubmitEmailPassword {
    return _hasValidEmail && _hasValidPassword && _hasValidConfirmPassword;
  }

  EmailPasswordAuthMode get _emailPasswordMode {
    return _isCreatingAccount
        ? EmailPasswordAuthMode.createAccount
        : EmailPasswordAuthMode.signIn;
  }

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_handleEmailChanged);
    _passwordController.addListener(_refreshFormState);
    _confirmPasswordController.addListener(_refreshFormState);
  }

  @override
  void dispose() {
    _emailController.removeListener(_handleEmailChanged);
    _passwordController.removeListener(_refreshFormState);
    _confirmPasswordController.removeListener(_refreshFormState);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleEmailChanged() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {});
  }

  void _refreshFormState() {
    setState(() {});
  }

  Future<void> _submitEmailPassword(AuthProvider authProvider) async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || !_canSubmitEmailPassword) {
      return;
    }

    await authProvider.signInWithEmailPassword(
      email: _emailController.text,
      password: _passwordController.text,
      mode: _emailPasswordMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final theme = Theme.of(context);
    final isLoading = authProvider.isLoading;
    final activeProvider = authProvider.activeProvider;
    final showPasswordField = _hasValidEmail;
    final showEmailAction = _hasValidPassword;

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
                    'Sign in to continue',
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
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          enabled: !isLoading,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            hintText: 'you@example.com',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Email-ul este obligatoriu.';
                            }
                            if (!_emailRegex.hasMatch(email)) {
                              return 'Introdu un email valid.';
                            }
                            return null;
                          },
                        ),
                        if (showPasswordField) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _passwordController,
                            textInputAction: _isCreatingAccount
                                ? TextInputAction.next
                                : TextInputAction.done,
                            obscureText: _hidePassword,
                            autofillHints: const [AutofillHints.password],
                            enabled: !isLoading,
                            onFieldSubmitted: (_) {
                              if (!_isCreatingAccount) {
                                _submitEmailPassword(authProvider);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _hidePassword = !_hidePassword;
                                        });
                                      },
                                icon: Icon(
                                  _hidePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _hidePassword
                                    ? 'Show password'
                                    : 'Hide password',
                              ),
                            ),
                            validator: (value) {
                              final password = value ?? '';
                              if (password.isEmpty) {
                                return 'Parola este obligatorie.';
                              }
                              if (password.length < 6) {
                                return 'Parola trebuie sa aiba minim 6 caractere.';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (_isCreatingAccount && _hasValidPassword) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPasswordController,
                            textInputAction: TextInputAction.done,
                            obscureText: _hideConfirmPassword,
                            autofillHints: const [AutofillHints.newPassword],
                            enabled: !isLoading,
                            onFieldSubmitted: (_) {
                              _submitEmailPassword(authProvider);
                            },
                            decoration: InputDecoration(
                              labelText: 'Confirm password',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _hideConfirmPassword =
                                              !_hideConfirmPassword;
                                        });
                                      },
                                icon: Icon(
                                  _hideConfirmPassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                tooltip: _hideConfirmPassword
                                    ? 'Show password'
                                    : 'Hide password',
                              ),
                            ),
                            validator: (value) {
                              if (!_isCreatingAccount) {
                                return null;
                              }
                              if (value != _passwordController.text) {
                                return 'Parolele nu coincid.';
                              }
                              return null;
                            },
                          ),
                        ],
                        if (showEmailAction) ...[
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 52,
                            child: FilledButton(
                              onPressed: isLoading || !_canSubmitEmailPassword
                                  ? null
                                  : () => _submitEmailPassword(authProvider),
                              child:
                                  isLoading &&
                                      activeProvider ==
                                          AuthProviderType.emailPassword
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _isCreatingAccount
                                          ? 'Create account'
                                          : 'Sign in with Email',
                                    ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isCreatingAccount = !_isCreatingAccount;
                                    _confirmPasswordController.clear();
                                  });
                                },
                          child: Text(
                            _isCreatingAccount
                                ? 'Already have an account? Sign in'
                                : 'Create new account',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or continue with',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SocialAuthButton(
                    label: 'Continue with Google',
                    icon: Icons.g_mobiledata,
                    onPressed: isLoading ? null : authProvider.signInWithGoogle,
                    isLoading:
                        isLoading && activeProvider == AuthProviderType.google,
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

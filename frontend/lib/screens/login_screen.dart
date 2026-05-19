import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
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
    final isLoading = authProvider.isLoading;

    return PremiumBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: _AuthPanel(
                        authProvider: authProvider,
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                        isLoading: isLoading,
                        isCreatingAccount: _isCreatingAccount,
                        hidePassword: _hidePassword,
                        hideConfirmPassword: _hideConfirmPassword,
                        hasValidEmail: _hasValidEmail,
                        hasValidPassword: _hasValidPassword,
                        canSubmitEmailPassword: _canSubmitEmailPassword,
                        onSubmitEmailPassword: () =>
                            _submitEmailPassword(authProvider),
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _hidePassword = !_hidePassword;
                          });
                        },
                        onToggleConfirmPasswordVisibility: () {
                          setState(() {
                            _hideConfirmPassword = !_hideConfirmPassword;
                          });
                        },
                        onToggleCreateAccount: _toggleCreateAccount,
                        emailValidator: _validateEmail,
                        passwordValidator: _validatePassword,
                        confirmPasswordValidator: _validateConfirmPassword,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _toggleCreateAccount() {
    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _confirmPasswordController.clear();
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required.';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required.';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_isCreatingAccount) {
      return null;
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match.';
    }
    return null;
  }
}

class _AuthPanel extends StatelessWidget {
  const _AuthPanel({
    required this.authProvider,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.isCreatingAccount,
    required this.hidePassword,
    required this.hideConfirmPassword,
    required this.hasValidEmail,
    required this.hasValidPassword,
    required this.canSubmitEmailPassword,
    required this.onSubmitEmailPassword,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.onToggleCreateAccount,
    required this.emailValidator,
    required this.passwordValidator,
    required this.confirmPasswordValidator,
  });

  final AuthProvider authProvider;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final bool isCreatingAccount;
  final bool hidePassword;
  final bool hideConfirmPassword;
  final bool hasValidEmail;
  final bool hasValidPassword;
  final bool canSubmitEmailPassword;
  final VoidCallback onSubmitEmailPassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final VoidCallback onToggleCreateAccount;
  final FormFieldValidator<String> emailValidator;
  final FormFieldValidator<String> passwordValidator;
  final FormFieldValidator<String> confirmPasswordValidator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeProvider = authProvider.activeProvider;
    final colorScheme = theme.colorScheme;
    final subtitleColor = colorScheme.onSurfaceVariant;
    final primaryTextColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final showEmailPasswordAction = isCreatingAccount
        ? canSubmitEmailPassword
        : hasValidPassword;

    return GlassContainer(
      color: const Color(0xFF00E5FF),
      opacity: 0.05,
      blur: 12.0,
      borderRadius: 24,
      border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
      shadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KRONTECH',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  (isCreatingAccount ? 'Create your account' : 'Welcome back')
                      .toUpperCase(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: subtitleColor.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    enabled: !isLoading,
                    style: theme.textTheme.bodyLarge,
                    cursorColor: primaryTextColor,
                    decoration: _inputDecoration(
                      context: context,
                      hint: 'Email address',
                      icon: Icons.alternate_email,
                      hasSuccess: hasValidEmail,
                    ),
                    validator: emailValidator,
                  ),
                  _AnimatedLoginFieldSlot(
                    visible: hasValidEmail,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: passwordController,
                            textInputAction: isCreatingAccount
                                ? TextInputAction.next
                                : TextInputAction.done,
                            obscureText: hidePassword,
                            autofillHints: const [AutofillHints.password],
                            enabled: !isLoading,
                            style: theme.textTheme.bodyLarge,
                            cursorColor: primaryTextColor,
                            onFieldSubmitted: (_) {
                              if (!isCreatingAccount) {
                                onSubmitEmailPassword();
                              }
                            },
                            decoration: _inputDecoration(
                              context: context,
                              hint: 'Password',
                              icon: Icons.lock_outline,
                              suffixIcon: IconButton(
                                onPressed: isLoading
                                    ? null
                                    : onTogglePasswordVisibility,
                                icon: Icon(
                                  hidePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Colors.white70,
                                ),
                                tooltip: hidePassword
                                    ? 'Show password'
                                    : 'Hide password',
                              ),
                              hasSuccess: hasValidPassword,
                            ),
                            validator: passwordValidator,
                          ),
                          if (!isCreatingAccount)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.white.withValues(
                                    alpha: 0.6,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _AnimatedLoginFieldSlot(
                    visible: isCreatingAccount && hasValidPassword,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: TextFormField(
                        controller: confirmPasswordController,
                        textInputAction: TextInputAction.done,
                        obscureText: hideConfirmPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !isLoading,
                        style: theme.textTheme.bodyLarge,
                        cursorColor: primaryTextColor,
                        onFieldSubmitted: (_) => onSubmitEmailPassword(),
                        decoration: _inputDecoration(
                          context: context,
                          hint: 'Confirm password',
                          icon: Icons.verified_user_outlined,
                          suffixIcon: IconButton(
                            onPressed: isLoading
                                ? null
                                : onToggleConfirmPasswordVisibility,
                            icon: Icon(
                              hideConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.white70,
                            ),
                            tooltip: hideConfirmPassword
                                ? 'Show password'
                                : 'Hide password',
                          ),
                          hasSuccess: canSubmitEmailPassword,
                        ),
                        validator: confirmPasswordValidator,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _AnimatedLoginFieldSlot(
                    visible: showEmailPasswordAction,
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton.icon(
                        onPressed: isLoading || !canSubmitEmailPassword
                            ? null
                            : onSubmitEmailPassword,
                        icon:
                            isLoading &&
                                activeProvider == AuthProviderType.emailPassword
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                isCreatingAccount
                                    ? Icons.person_add_alt_1_rounded
                                    : Icons.login_rounded,
                                size: 20,
                              ),
                        label: Text(
                          isCreatingAccount
                              ? 'CREATE ACCOUNT'
                              : 'SIGN IN WITH EMAIL',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    child: TextButton(
                      onPressed: isLoading ? null : onToggleCreateAccount,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        overlayColor: Colors.transparent,
                        splashFactory: NoSplash.splashFactory,
                      ),
                      child: Text(
                        isCreatingAccount
                            ? 'Already have an account? Sign in'
                            : 'Create new account',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    thickness: 1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: subtitleColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.15),
                    thickness: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SocialAuthButton(
              label: 'Continue with Google',
              icon: SvgPicture.asset(
                'assets/icons/google.svg',
                width: 20,
                height: 20,
              ),
              onPressed: isLoading ? null : authProvider.signInWithGoogle,
              isLoading: isLoading && activeProvider == AuthProviderType.google,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
              foregroundColor: const Color(0xFF1F2937),
              borderColor: Colors.transparent,
            ),
            if (isLoading) ...[
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: const Color(0xFF00E5FF),
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required BuildContext context,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
    bool hasSuccess = false,
  }) {
    final theme = Theme.of(context);
    final errorColor = theme.colorScheme.error;
    const borderRadius = BorderRadius.all(Radius.circular(16));

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      prefixIcon: Icon(
        icon,
        color: Colors.white.withValues(alpha: 0.6),
        size: 20,
      ),
      suffixIcon:
          suffixIcon ??
          (hasSuccess
              ? const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF00E5FF),
                  size: 20,
                )
              : null),
      filled: true,
      fillColor: const Color(0xFF063970).withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Color(0xFF00E5FF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor.withValues(alpha: 0.5)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: errorColor, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}

class _AnimatedLoginFieldSlot extends StatelessWidget {
  const _AnimatedLoginFieldSlot({required this.visible, required this.child});

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 520),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return currentChild ?? const SizedBox.shrink();
      },
      transitionBuilder: (child, animation) {
        return SizeTransition(
          axisAlignment: -1,
          sizeFactor: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: visible
          ? KeyedSubtree(
              key: const ValueKey('visible-login-field'),
              child: child,
            )
          : const SizedBox.shrink(key: ValueKey('hidden-login-field')),
    );
  }
}

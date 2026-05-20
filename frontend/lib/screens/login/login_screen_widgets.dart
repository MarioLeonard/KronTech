part of '../login_screen.dart';

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

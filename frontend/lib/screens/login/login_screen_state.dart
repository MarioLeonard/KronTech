part of '../login_screen.dart';

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

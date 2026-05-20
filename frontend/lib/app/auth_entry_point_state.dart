part of '../main.dart';

class _AuthEntryPointState extends State<AuthEntryPoint> {
  String? _lastShownError;

  void _showAuthErrorIfNeeded(String? errorMessage) {
    if (errorMessage == null) {
      _lastShownError = null;
      return;
    }

    if (errorMessage == _lastShownError) {
      return;
    }

    _lastShownError = errorMessage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final messenger = ScaffoldMessenger.of(context);
      final colorScheme = Theme.of(context).colorScheme;
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Text(errorMessage),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        _showAuthErrorIfNeeded(authProvider.errorMessage);

        final user = authProvider.user;
        if (authProvider.isAuthenticated && user != null) {
          if (user.hasCompletedOnboarding) {
            return MainShell(user: user);
          }

          return const MainOnboardingScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

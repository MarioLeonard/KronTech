import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/onboarding/presentation/controllers/onboarding_provider.dart';
import 'package:frontend/features/onboarding/presentation/screens/main_onboarding_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/screens/main_shell.dart';
import 'package:frontend/services/oauth_auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:frontend/utils/hive_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load .env file from assets before any service initialization
  try {
    await dotenv.load(fileName: 'assets/.env');
  } catch (e) {
    debugPrint('Warning: .env file not found. Using default configuration.');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: OAuthAuthService()),
        ),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()..load()),
      ],
      child: MaterialApp(
        title: 'KronTech',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const AuthEntryPoint(),
      ),
    );
  }
}

class AuthEntryPoint extends StatefulWidget {
  const AuthEntryPoint({super.key});

  @override
  State<AuthEntryPoint> createState() => _AuthEntryPointState();
}

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

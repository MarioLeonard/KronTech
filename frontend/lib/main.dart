import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:frontend/features/onboarding/presentation/controllers/onboarding_provider.dart';
import 'package:frontend/features/onboarding/presentation/screens/main_onboarding_screen.dart';
import 'package:frontend/firebase_options.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/services/oauth_auth_service.dart';
import 'package:frontend/theme/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        ChangeNotifierProvider(
          create: (_) => OnboardingProvider()..load(),
        ),
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

class AuthEntryPoint extends StatelessWidget {
  const AuthEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return HomeScreen(user: authProvider.user!);
        }

        return const MainOnboardingScreen();
      },
    );
  }
}

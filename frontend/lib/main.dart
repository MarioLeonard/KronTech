import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'features/onboarding/presentation/controllers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/main_onboarding_screen.dart';
import 'utils/hive_service.dart';
import 'screens/loading_screen.dart';
import 'app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✓ Firebase initialized');

    // Initialize Hive
    await HiveService.init();
    debugPrint('✓ Hive initialized');
  } catch (e) {
    debugPrint('❌ Initialization error: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingProvider()..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KronTech Onboarding',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: Consumer<OnboardingProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const LoadingScreen(message: 'Loading your profile...');
          }
          return const MainOnboardingScreen();
        },
      ),
    );
  }
}

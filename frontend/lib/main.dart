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

part 'app/auth_entry_point.dart';
part 'app/auth_entry_point_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
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

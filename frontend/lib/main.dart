import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'features/onboarding/presentation/controllers/onboarding_provider.dart';
import 'features/onboarding/presentation/screens/main_onboarding_screen.dart';
import 'utils/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
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

  static const Color _background = Color(0xFF070B14);
  static const Color _surface = Color(0xFF101726);
  static const Color _surfaceStrong = Color(0xFF161F33);
  static const Color _accent = Color(0xFF7C9BFF);
  static const Color _accentSoft = Color(0xFF8EE3FF);
  static const Color _success = Color(0xFF57D7A6);
  static const Color _error = Color(0xFFFF7F96);
  static const Color _textPrimary = Color(0xFFF5F7FB);
  static const Color _textSecondary = Color(0xFF9EA9C7);
  static const Color _outline = Color(0xFF27314A);

  ThemeData _buildTheme() {
    final baseTextTheme = GoogleFonts.dmSansTextTheme(
      ThemeData.dark().textTheme,
    );
    final displayFont = GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);

    final colorScheme = const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: _accent,
      secondary: _accentSoft,
      surface: _surface,
      error: _error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _textPrimary,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _background,
      textTheme: displayFont.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 44,
          fontWeight: FontWeight.w700,
          height: 1.05,
          color: _textPrimary,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.08,
          color: _textPrimary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.15,
          color: _textPrimary,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          height: 1.2,
          color: _textPrimary,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        titleMedium: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
        bodyLarge: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: _textPrimary,
        ),
        bodyMedium: GoogleFonts.dmSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: _textSecondary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: _surfaceStrong,
        contentTextStyle: GoogleFonts.dmSans(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceStrong.withValues(alpha: 0.78),
        hintStyle: GoogleFonts.dmSans(
          color: _textSecondary.withValues(alpha: 0.75),
          fontSize: 15,
        ),
        labelStyle: GoogleFonts.dmSans(
          color: _textSecondary,
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _accentSoft, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _error, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: _error, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _surfaceStrong,
          disabledForegroundColor: _textSecondary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textPrimary,
          side: const BorderSide(color: _outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: _surface.withValues(alpha: 0.94),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      dividerColor: _outline,
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: _outline, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _accent;
          }
          return Colors.transparent;
        }),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _background;
          }
          return _textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _success;
          }
          return _outline;
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KronTech Onboarding',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const MainOnboardingScreen(),
    );
  }
}

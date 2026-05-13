import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const _lightBackground = Color(0xFFF8F9FA);
  static const _primaryBlue = Color(0xFF00E5FF); // Tropical Cyan/Turquoise
  static const _chip = Color(0xFFCAF0F8);
  static const _accentOrange = Color(0xFFFF8C00); // Bright, warm summery orange
  static const _lightText = Color(0xFF0B1324);
  static const _darkText = Color(0xFFCAF0F8);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF00E5FF),
      brightness: Brightness.light,
      surface: Colors.white,
      primary: const Color(0xFF0077B6),
      secondary: _chip,
      tertiary: _accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _lightText,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.15),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0077B6),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE4E7EB),
          disabledForegroundColor: const Color(0xFF667085),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _chip.withValues(alpha: 0.2),
        selectedColor: const Color(0xFF0077B6),
        labelStyle: GoogleFonts.poppins(color: _lightText),
        secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: const Color(0xFF0077B6).withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(color: _lightText, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(_textTheme(_lightText)),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.dark,
      surface: const Color(0xFF00E5FF).withValues(alpha: 0.05), // Brighter translucent cyan tint
      primary: _primaryBlue,
      secondary: const Color(0xFF00B4D8),
      tertiary: _accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _darkText,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white.withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF063970).withValues(alpha: 0.85),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: const Color(0xFF063970).withValues(alpha: 0.85),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00B4D8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF335C93),
          disabledForegroundColor: const Color(0xFFB8D8E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: GoogleFonts.poppins(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _primaryBlue.withValues(alpha: 0.1),
        selectedColor: _accentOrange,
        labelStyle: GoogleFonts.poppins(color: _darkText),
        secondaryLabelStyle: GoogleFonts.poppins(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        indicatorColor: _primaryBlue.withValues(alpha: 0.3),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.poppins(color: _darkText, fontWeight: FontWeight.w600),
        ),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(_textTheme(_darkText)),
    );
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(color: color, fontWeight: FontWeight.w800),
      displayMedium: TextStyle(color: color, fontWeight: FontWeight.w800),
      displaySmall: TextStyle(color: color, fontWeight: FontWeight.w800),
      headlineLarge: TextStyle(color: color, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(color: color, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(color: color, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(color: color, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(color: color, fontWeight: FontWeight.w700),
      titleSmall: TextStyle(color: color, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(color: color),
      bodyMedium: TextStyle(color: color),
      bodySmall: TextStyle(color: color),
      labelLarge: TextStyle(color: color, fontWeight: FontWeight.w700),
      labelMedium: TextStyle(color: color, fontWeight: FontWeight.w700),
      labelSmall: TextStyle(color: color, fontWeight: FontWeight.w700),
    );
  }
}

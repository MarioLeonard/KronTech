import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _lightBackground = Color(0xFFF8F9FA);
  static const _darkBackground = Color(0xFF03045E);
  static const _primaryBlue = Color(0xFF0077B6);
  static const _darkCard = Color(0xFF023E8A);
  static const _chip = Color(0xFFCAF0F8);
  static const _accentOrange = Color(0xFFFF8500);
  static const _lightText = Color(0xFF0B1324);
  static const _darkText = Color(0xFFCAF0F8);

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.light,
      surface: Colors.white,
      primary: _primaryBlue,
      secondary: _chip,
      tertiary: _accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _lightBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryBlue,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFE4E7EB),
          disabledForegroundColor: const Color(0xFF667085),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _chip,
        selectedColor: _primaryBlue,
        labelStyle: const TextStyle(color: _lightText),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: _chip,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: _lightText, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: _primaryBlue),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: Colors.white,
        borderColor: Colors.white,
        focusedColor: Colors.white,
        labelColor: const Color(0xFF475467),
        hintColor: const Color(0xFF98A2B3),
        iconColor: _primaryBlue,
      ),
      textTheme: _textTheme(_lightText),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryBlue,
      brightness: Brightness.dark,
      surface: _darkCard,
      primary: _chip,
      secondary: _primaryBlue,
      tertiary: _accentOrange,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: _darkBackground,
      colorScheme: colorScheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkCard,
        foregroundColor: _darkText,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _accentOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF335C93),
          disabledForegroundColor: const Color(0xFFB8D8E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _chip,
        selectedColor: _accentOrange,
        labelStyle: const TextStyle(color: _darkBackground),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkCard,
        indicatorColor: _primaryBlue,
        labelTextStyle: WidgetStateProperty.all(
          const TextStyle(color: _darkText, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.all(
          const IconThemeData(color: _darkText),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(
        fillColor: const Color(0xFF064A9E),
        borderColor: Colors.white,
        focusedColor: Colors.white,
        labelColor: _darkText,
        hintColor: const Color(0xFF9BDCEB),
        iconColor: _chip,
      ),
      textTheme: _textTheme(_darkText),
    );
  }

  static InputDecorationTheme _inputDecorationTheme({
    required Color fillColor,
    required Color borderColor,
    required Color focusedColor,
    required Color labelColor,
    required Color hintColor,
    required Color iconColor,
  }) {
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: borderColor),
    );

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor,
      prefixIconColor: iconColor,
      suffixIconColor: iconColor,
      labelStyle: TextStyle(color: labelColor),
      hintStyle: TextStyle(color: hintColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: enabledBorder,
      enabledBorder: enabledBorder,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: focusedColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFFFB4AB), width: 1.6),
      ),
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

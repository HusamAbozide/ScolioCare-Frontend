import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Primary: HSL(270, 60%, 60%) ≈ #9966CC
  static const Color primary = Color(0xFF9966CC);
  // Secondary: HSL(290, 50%, 55%) ≈ #B366CC
  static const Color secondary = Color(0xFFB366CC);
  static const Color success = Color(0xFF22C55E);
  static const Color successForeground = Colors.white;
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningForeground = Colors.white;
  static const Color destructive = Color(0xFFEF4444);
  static const Color destructiveForeground = Colors.white;
  static const Color info = Color(0xFF0EA5E9);

  // Muted surface colors (surfaceContainerHighest equivalent for older SDK)
  static const Color lightMuted = Color(0xFFF0ECF5);
  static const Color darkMuted = Color(0xFF2D2340);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: destructive,
      onError: Colors.white,
      background: Color(0xFFFAF9FC),
      onBackground: Color(0xFF2D1F4E),
      surface: Colors.white,
      onSurface: Color(0xFF2D1F4E), // HSL(270, 40%, 15%)
      onSurfaceVariant: Color(0xFF706585), // muted-foreground
      outline: Color(0xFFDDD5E9), // border
    ),
    scaffoldBackgroundColor: const Color(0xFFFAF9FC), // HSL(270, 30%, 98%)
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFDDD5E9), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDD5E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDDD5E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF706585)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFFDDD5E9)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primary),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: primary,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFF706585),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: primary,
      unselectedItemColor: Color(0xFF706585),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: Color(0xFFF0ECF5),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFDDD5E9),
      thickness: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF2D1F4E),
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFAA80DB), // HSL(270, 60%, 65%)
      onPrimary: Colors.white,
      secondary: secondary,
      onSecondary: Colors.white,
      error: Color(0xFF7F1D1D),
      onError: Color(0xFFF0ECF5),
      background: Color(0xFF140E20),
      onBackground: Color(0xFFF0ECF5),
      surface: Color(0xFF1F1730), // card dark
      onSurface: Color(0xFFF0ECF5),
      onSurfaceVariant: Color(0xFFA699B5),
      outline: Color(0xFF382D4C),
    ),
    scaffoldBackgroundColor: const Color(0xFF140E20), // HSL(270, 40%, 8%)
    cardTheme: CardTheme(
      color: const Color(0xFF1F1730),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF382D4C), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1730),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF382D4C)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF382D4C)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFAA80DB), width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFFA699B5)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: Color(0xFF382D4C)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFAA80DB)),
    ),
    tabBarTheme: TabBarTheme(
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFFAA80DB),
      ),
      labelColor: Colors.white,
      unselectedLabelColor: const Color(0xFFA699B5),
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1F1730),
      selectedItemColor: Color(0xFFAA80DB),
      unselectedItemColor: Color(0xFFA699B5),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Color(0xFFAA80DB),
      linearTrackColor: Color(0xFF2D2340),
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF382D4C),
      thickness: 1,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1730),
      foregroundColor: Color(0xFFF0ECF5),
      elevation: 0,
      scrolledUnderElevation: 1,
    ),
  );
}

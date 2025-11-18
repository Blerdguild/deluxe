
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color _darkGreen = Color(0xFF122115);
  static const Color _accentGreen = Color(0xFF2E7D32);
  static const Color _cardGreen = Color(0xFF1A3824);
  static const Color _offWhite = Color(0xFFE8E5DA);
  static const Color _gold = Color(0xFFFFD700);
  static const Color _grey = Color(0xFF9E9E9E);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _accentGreen,
    scaffoldBackgroundColor: _darkGreen,
    fontFamily: GoogleFonts.lato().fontFamily,

    // --- Color Scheme ---
    colorScheme: const ColorScheme.dark(
      primary: _accentGreen,
      secondary: _accentGreen,
      surface: _cardGreen,
      background: _darkGreen,
      onPrimary: _offWhite,
      onSecondary: _offWhite,
      onSurface: _offWhite,
      onBackground: _offWhite,
      error: Colors.redAccent,
      onError: _offWhite,
    ),

    // --- Component Themes ---
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkGreen,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: _offWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: _offWhite),
    ),

    cardTheme: CardThemeData(
      color: _cardGreen,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentGreen,
        foregroundColor: _offWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _darkGreen,
      selectedItemColor: _offWhite,
      unselectedItemColor: _grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: _cardGreen,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
      hintStyle: TextStyle(color: _grey),
    ),

    // --- Text Theme ---
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: _offWhite, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: _offWhite, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: _offWhite, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: _offWhite),
      bodyMedium: TextStyle(color: _offWhite),
      bodySmall: TextStyle(color: _grey),
      labelLarge: TextStyle(color: _offWhite, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: _offWhite),
      labelSmall: TextStyle(color: _offWhite),
    ),
  );
}

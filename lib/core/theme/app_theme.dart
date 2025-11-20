import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // --- Colors ---
  static const Color _background = Color(0xFF0D1610); // Darker Green/Black
  static const Color _cardSurface = Color(0xFF16261A); // Dark Green for cards
  static const Color _primaryGreen = Color(0xFF2E7D32); // Rich Green
  static const Color _textWhite =Color.fromARGB(255, 255, 246, 219); // Off-white/Eggshell
  static const Color _textGrey = Color(0xFFB0BEC5);
  static const Color _gold = Color(0xFFFFD700);

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _primaryGreen,
    scaffoldBackgroundColor: _background,
    fontFamily: GoogleFonts.lato().fontFamily,

    // --- Color Scheme ---
    colorScheme: const ColorScheme.dark(
      primary: _primaryGreen,
      secondary: _primaryGreen,
      surface: _cardSurface,
      background: _background,
      onPrimary: _textWhite,
      onSecondary: _textWhite,
      onSurface: _textWhite,
      onBackground: _textWhite,
      error: Colors.redAccent,
      onError: _textWhite,
    ),

    // --- Component Themes ---
    appBarTheme: const AppBarTheme(
      backgroundColor: _background,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        color: _textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(color: _textWhite),
    ),

    cardTheme: CardThemeData(
      color: _cardSurface,
      elevation: 0, // Flat look for modern feel
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: _textWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _background,
      selectedItemColor: _primaryGreen,
      unselectedItemColor: _textGrey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _cardSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30), // Rounded search bar
        borderSide: BorderSide.none,
      ),
      hintStyle: const TextStyle(color: _textGrey),
      prefixIconColor: _textGrey,
    ),

    // --- Text Theme ---
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(color: _textWhite, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: _textWhite, fontWeight: FontWeight.w600),
      titleSmall: TextStyle(color: _textWhite, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: _textWhite),
      bodyMedium: TextStyle(color: _textWhite),
      bodySmall: TextStyle(color: _textGrey),
      labelLarge: TextStyle(color: _textWhite, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: _textWhite),
      labelSmall: TextStyle(color: _textWhite),
    ),
  );
}

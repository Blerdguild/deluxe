// C:/dev/flutter_projects/deluxe/lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static final darkGreenTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color(0xFF2E7D32),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      secondary: const Color(0xFFC8E6C9),
    ),
    useMaterial3: true,
  );
}

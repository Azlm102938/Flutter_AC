import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F8EF7),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  );
}

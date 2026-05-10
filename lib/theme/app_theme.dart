import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Poppins",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F8EF7),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: "Poppins",
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F8EF7),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0B1220),
  );
}

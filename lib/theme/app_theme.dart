import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF0D2444);
  static const Color accentColor = Color(0xFF4ECDC4);
  static const Color backgroundColor = Colors.white;
  static const Color textColor = Colors.black87;
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  static const Color greyColor = Colors.grey;

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textColor,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textColor,
  );

  // Theme Data
  static ThemeData get theme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: lightGreyColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
    );
  }
} 

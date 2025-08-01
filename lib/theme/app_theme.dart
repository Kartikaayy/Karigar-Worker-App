import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: const Color.fromARGB(255, 241, 244, 248),
      textTheme: GoogleFonts.poppinsTextTheme(),
      primaryColor: const Color(0xFF4A5AEF),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 241, 244, 248),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

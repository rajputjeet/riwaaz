import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (Deep Crimson / Ruby #90002B)
  static const Color primary = Color(0xFF90002B);         // Deep Ruby Crimson (Main Brand)
  static const Color primaryLight = Color(0xFFB00E3D);    // Vibrant Crimson Highlight
  static const Color primaryDark = Color(0xFF5E001C);     // Deep Crimson Shade

  // Secondary Brand Color (Rich Royal Wedding Gold)
  static const Color secondary = Color(0xFFD4A017);       // Royal Indian Wedding Gold
  static const Color secondaryLight = Color(0xFFF3D088);  // Champagne Gold Highlight
  static const Color secondaryDark = Color(0xFFB8860B);   // Deep Antique Gold

  // Gold Accents
  static const Color gold = Color(0xFFD4A017);            // Rich Gold
  static const Color goldLight = Color(0xFFF3D088);       // Light Gold Highlight
  static const Color goldDark = Color(0xFFB8860B);        // Deep Antique Gold

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFF9F2);
  static const Color cream = Color(0xFFF7EFE6);
  static const Color lightGrey = Color(0xFFF2F2F2);
  static const Color greyLight = Color(0xFFF2F2F2);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color black = Color(0xFF1A1A1A);

  // Semantic Colors
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);

  // Background
  static const Color background = Color(0xFFFFF8F0);      // Warm Cream / Soft Ivory
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceBg = Color(0xFFFAF0E6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB00E3D), Color(0xFF90002B)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3D088), Color(0xFFD4A017), Color(0xFFB8860B)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF3D088), Color(0xFFD4A017), Color(0xFFB8860B)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFB00E3D), Color(0xFF90002B), Color(0xFF5E001C)],
  );
}

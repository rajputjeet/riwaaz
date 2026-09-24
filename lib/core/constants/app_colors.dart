import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF380C1D);         // Deep Royal Maroon / Wine (Main Brand)
  static const Color primaryLight = Color(0xFF5E1B33);    // Lighter Wine
  static const Color primaryDark = Color(0xFF220510);     // Dark Wine / Burgundy Black

  // Secondary Brand Color (Replaces Yellow/Gold)
  static const Color secondary = Color(0xFFFFF9F2);       // Soft Warm Ivory (Secondary Brand)
  static const Color secondaryLight = Color(0xFFFFFFFF);  // Pure White
  static const Color secondaryDark = Color(0xFFEFE5D8);   // Warm Ivory/Muted Beige

  // Gold aliases replaced with secondary color (no yellow/gold)
  static const Color gold = Color(0xFFFFF9F2);            // Secondary Ivory
  static const Color goldLight = Color(0xFFFFFFFF);       // Ivory Highlight
  static const Color goldDark = Color(0xFF380C1D);        // Primary Wine for high contrast text/icons

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFFF9F2);
  static const Color cream = Color(0xFFF7EFE6);
  static const Color lightGrey = Color(0xFFF2F2F2);
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
  static const Color background = Color(0xFFFFF9F2);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceBg = Color(0xFFFAF0E6);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5E1B33), Color(0xFF380C1D)],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF9F2)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFFFF9F2)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF5E1B33), Color(0xFF380C1D), Color(0xFF220510)],
  );
}

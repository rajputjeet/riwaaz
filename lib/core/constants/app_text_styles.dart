import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Base Typography Helpers
  static TextStyle serif({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.cormorantGaramond(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle sans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  // Headlines (Serif - Cormorant Garamond)
  static TextStyle displayLarge = GoogleFonts.cormorantGaramond(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.cormorantGaramond(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.2,
  );

  static TextStyle displaySmall = GoogleFonts.cormorantGaramond(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.3,
  );

  static TextStyle headlineLarge = GoogleFonts.cormorantGaramond(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.black,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.4,
  );

  static TextStyle headlineSmall = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.4,
  );

  // Body (Sans - Plus Jakarta Sans)
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGrey,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.grey,
    height: 1.5,
  );

  // Labels (Sans - Plus Jakarta Sans)
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.grey,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // Brand
  static TextStyle brandTitle = GoogleFonts.cormorantGaramond(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
    letterSpacing: 1.0,
  );

  static TextStyle brandSubtitle = GoogleFonts.plusJakartaSans(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.goldLight,
    letterSpacing: 1.5,
  );

  // Price
  static TextStyle price = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );
}

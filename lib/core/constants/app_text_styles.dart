import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get headline => GoogleFonts.courierPrime(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 2.0,
      );

  static TextStyle get title => GoogleFonts.courierPrime(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get body => GoogleFonts.courierPrime(
        fontSize: 16,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySecondary => GoogleFonts.courierPrime(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonText => GoogleFonts.courierPrime(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );
}

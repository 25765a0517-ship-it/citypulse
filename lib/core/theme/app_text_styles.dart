import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Plus Jakarta Sans Headlines & Titles
  static TextStyle displayLarge = GoogleFonts.plusJakartaSans(
    fontSize: 40.0,
    height: 48.0 / 40.0,
    letterSpacing: -0.8,
    fontWeight: FontWeight.w800,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLarge = GoogleFonts.plusJakartaSans(
    fontSize: 32.0,
    height: 40.0 / 32.0,
    letterSpacing: -0.48,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineLargeMobile = GoogleFonts.plusJakartaSans(
    fontSize: 26.0,
    height: 34.0 / 26.0,
    letterSpacing: -0.26,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMedium = GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    height: 32.0 / 24.0,
    letterSpacing: -0.24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSmall = GoogleFonts.plusJakartaSans(
    fontSize: 20.0,
    height: 28.0 / 20.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle titleMedium = GoogleFonts.plusJakartaSans(
    fontSize: 18.0,
    height: 24.0 / 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  // Labels
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    letterSpacing: 0.14,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    height: 16.0 / 12.0,
    letterSpacing: 0.24,
    fontWeight: FontWeight.w600,
    color: AppColors.onSurface,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 10.0,
    height: 14.0 / 10.0,
    letterSpacing: 0.4,
    fontWeight: FontWeight.w700,
    color: AppColors.onSurface,
  );

  // Inter Body Typography
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16.0,
    height: 24.0 / 16.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurface,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14.0,
    height: 20.0 / 14.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12.0,
    height: 16.0 / 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.onSurfaceVariant,
  );
}

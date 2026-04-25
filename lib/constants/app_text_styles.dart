import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Headings (H1-H3) | Semibold
  static final TextStyle h1 = GoogleFonts.inter(
    fontSize: 30,
    fontWeight: FontWeight.w600,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  static final TextStyle h2 = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  // Body Text (400)
  static final TextStyle body = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  // Labels & Buttons (500)
  static final TextStyle button = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    decoration: TextDecoration.none,
  );

  static final TextStyle label = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  // Secondary Text (400) - using darkBrown color
  static final TextStyle secondary = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  // Small & tiny text
  static final TextStyle small = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );

  static final TextStyle tiny = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.darkBrown,
    decoration: TextDecoration.none,
  );
}

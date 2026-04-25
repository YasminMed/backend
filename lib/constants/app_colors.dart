import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillora/providers/theme_provider.dart';

class AppColors {
  // MAIN APP COLORS
  static const Color studyPink = Color(0xFFFF6B6B);
  static const Color careerGreen = Color(0xFF93A344); // More vibrant green

  // FULL PALETTE
  static const Color accent = Color(0xFFF19C79);
  static const Color softGreen = Color(0xFFCBDFBD);
  static const Color lime = Color(0xFFD4E09B);
  static const Color limeGreen = Color(0xFFD4E09B);
  static const Color darkBrown = Color(0xFF6F5E53);
  static const Color darkOlive = Color(0xFF2D3B1E);
  static const Color secondary = Color(
    0xFFF19C79,
  ); // Using accent as secondary for consistency
  // Neutrals
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color primary = Color(0xFFFF6B6B);

  static Color getPrimaryColor(BuildContext context, {bool listen = true}) {
    return getMainColor(context, listen: listen);
  }

  static Color getMainColor(BuildContext context, {bool listen = true}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: listen);
    return themeProvider.currentPath == AppPath.study ? studyPink : careerGreen;
  }

  static Color getSecondaryColor(BuildContext context, {bool listen = true}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: listen);
    return themeProvider.currentPath == AppPath.study
        ? secondary
        : Color(0xFFA9D576);
  }

  static Color getAccentColor(BuildContext context, {bool listen = true}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: listen);
    return themeProvider.currentPath == AppPath.study
        ? accent
        : Color(0xFFDAE59F);
  }

  static Color getSurfaceColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF1E1E1E)
        : Colors.white;
  }

  static Color getTextColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.black
        : Colors.white;
  }
}

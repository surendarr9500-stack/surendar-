import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // MoES / Oceanic color palette
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color primaryDark = Color(0xFF002171);
  static const Color primaryLight = Color(0xFF5472D3);
  static const Color secondaryTeal = Color(0xFF00695C);
  static const Color accentCyan = Color(0xFF00ACC1);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color errorRed = Color(0xFFC62828);
  static const Color warningAmber = Color(0xFFF9A825);
  static const Color successGreen = Color(0xFF2E7D32);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  
  // Component status colors
  static const Color statusNormal = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFC107);
  static const Color statusDegraded = Color(0xFFFF9800);
  static const Color statusCritical = Color(0xFFF44336);
  static const Color statusMaintenance = Color(0xFF2196F3);
  static const Color statusOffline = Color(0xFF9E9E9E);
  static const Color statusUnknown = Color(0xFFBDBDBD);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        primary: primaryBlue,
        secondary: secondaryTeal,
        tertiary: accentCyan,
        background: backgroundLight,
        surface: surfaceLight,
        error: errorRed,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: surfaceLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.white,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.dark,
        primary: primaryLight,
        secondary: secondaryTeal,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'NORMAL':
        return statusNormal;
      case 'WARNING':
        return statusWarning;
      case 'DEGRADED':
        return statusDegraded;
      case 'CRITICAL':
        return statusCritical;
      case 'MAINTENANCE':
        return statusMaintenance;
      case 'OFFLINE':
        return statusOffline;
      default:
        return statusUnknown;
    }
  }
}

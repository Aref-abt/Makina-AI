import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primaryDarkGreen = Color(0xFF288061);
  static const Color primaryLightGreen = Color(0xFF08CE4A);
  
  // Secondary Colors
  static const Color orange = Color(0xFFFF9500);
  static const Color yellow = Color(0xFFFFCC00);
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  
  // Status Colors
  static const Color critical = Color(0xFFE53935);
  static const Color warning = Color(0xFFFF9500);
  static const Color healthy = Color(0xFF08CE4A);
  static const Color info = Color(0xFF2196F3);
  
  // Severity Colors
  static const Color severityHigh = Color(0xFFE53935);
  static const Color severityMedium = Color(0xFFFF9500);
  static const Color severityLow = Color(0xFF08CE4A);
  
  // Ticket Status Colors
  static const Color statusToDo = Color(0xFF9E9E9E);
  static const Color statusInProgress = Color(0xFF2196F3);
  static const Color statusDone = Color(0xFF08CE4A);
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFEEEEEE);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1D21);
  static const Color darkSurface = Color(0xFF242830);
  static const Color darkCard = Color(0xFF2D323C);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF3D4450);
  static const Color darkDivider = Color(0xFF3D4450);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDarkGreen, primaryLightGreen],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9500), Color(0xFFFFCC00)],
  );
  
  static const LinearGradient criticalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE53935), Color(0xFFFF5252)],
  );
}

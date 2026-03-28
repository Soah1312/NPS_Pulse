import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.backgroundPrimary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentAmber,
      secondary: AppColors.accentBlue,
      surface: AppColors.backgroundSecondary,
      onPrimary: AppColors.backgroundPrimary,
      onSecondary: AppColors.backgroundPrimary,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
    ),

    // No white cards ever
    cardTheme: CardThemeData(
      color: AppColors.backgroundSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),

    // Bottom navigation
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundSecondary,
      selectedItemColor: AppColors.accentAmber,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      selectedLabelStyle: AppTypography.labelSmall.copyWith(
        color: AppColors.accentAmber,
      ),
    ),

    // App bar — no elevation, matches background
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTypography.headingMedium,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    ),

    // Input fields — dark filled, no white
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundTertiary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentAmber, width: 1.5),
      ),
      labelStyle: AppTypography.bodyMedium,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textDisabled,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),

    // Dividers
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSubtle,
      thickness: 1,
      space: 1,
    ),
  );
}

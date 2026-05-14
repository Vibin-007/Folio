import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color darkBgBase = Color(0xFF0A0A0A);
  static const Color darkBgSurface = Color(0xFF111111);
  static const Color darkBgElevated = Color(0xFF1A1A1A);
  static const Color darkBgOverlay = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkBorderFocus = Color(0xFF444444);
  static const Color darkTextPrimary = Color(0xFFF0F0F0);
  static const Color darkTextSecondary = Color(0xFF888888);
  static const Color darkTextMuted = Color(0xFF444444);
  static const Color darkTextInverse = Color(0xFF0A0A0A);
  static const Color darkWhite = Color(0xFFFFFFFF);

  static const Color lightBgBase = Color(0xFFFAFAFA);
  static const Color lightBgSurface = Color(0xFFF4F4F4);
  static const Color lightBgElevated = Color(0xFFEBEBEB);
  static const Color lightBgOverlay = Color(0xFFE0E0E0);
  static const Color lightBorder = Color(0xFFD4D4D4);
  static const Color lightBorderFocus = Color(0xFFA0A0A0);
  static const Color lightTextPrimary = Color(0xFF0A0A0A);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightTextMuted = Color(0xFFAAAAAA);
  static const Color lightTextInverse = Color(0xFFFAFAFA);
  static const Color lightWhite = Color(0xFFFFFFFF);

  static const Color darkBg = darkBgBase;
  static const Color darkText = darkTextPrimary;
  static const Color darkSurface = darkBgSurface;
  static const Color lightBg = lightBgBase;
  static const Color lightText = lightTextPrimary;
  static const Color lightSurface = lightBgSurface;
}

class AppTextStyles {
  static TextStyle get appTitle => GoogleFonts.dmSerifDisplay(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );

  static TextStyle get labelXl => GoogleFonts.dmSans(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.01,
  );

  static TextStyle get labelLg => GoogleFonts.dmSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: -0.01,
  );

  static TextStyle get labelMd => GoogleFonts.dmSans(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get labelSm => GoogleFonts.dmSans(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static TextStyle get labelXs => GoogleFonts.dmSans(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.02,
  );

  static TextStyle get monoCode => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
}

class AppTheme {
  static Color get darkBg => AppColors.darkBgBase;
  static Color get lightBg => AppColors.lightBgBase;
  static Color get darkText => AppColors.darkTextPrimary;
  static Color get lightText => AppColors.lightTextPrimary;
  static Color get darkBorder => AppColors.darkBorder;
  static Color get lightBorder => AppColors.lightBorder;
  static Color get darkSurface => AppColors.darkBgSurface;
  static Color get lightSurface => AppColors.lightBgSurface;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgBase,
      canvasColor: AppColors.lightBgBase,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightTextPrimary,
        onPrimary: AppColors.lightWhite,
        surface: AppColors.lightBgSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
      textTheme: _buildTextTheme(
        AppColors.lightTextPrimary,
        AppColors.lightTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      dividerColor: AppColors.lightBorder,
      cardTheme: CardThemeData(
        color: AppColors.lightBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.lightBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.lightBorderFocus,
            width: 2,
          ),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        hintStyle: const TextStyle(color: AppColors.lightTextMuted),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightBgSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgBase,
      canvasColor: AppColors.darkBgBase,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkTextPrimary,
        onPrimary: AppColors.darkBgBase,
        surface: AppColors.darkBgSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      textTheme: _buildTextTheme(
        AppColors.darkTextPrimary,
        AppColors.darkTextSecondary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      dividerColor: AppColors.darkBorder,
      cardTheme: CardThemeData(
        color: AppColors.darkBgSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: AppColors.darkBorderFocus,
            width: 2,
          ),
        ),
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        hintStyle: const TextStyle(color: AppColors.darkTextMuted),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextPrimary),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkBgSurface,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      displayLarge: AppTextStyles.appTitle.copyWith(color: primary),
      displayMedium: AppTextStyles.appTitle.copyWith(color: primary),
      displaySmall: AppTextStyles.appTitle.copyWith(color: primary),
      headlineLarge: AppTextStyles.labelXl.copyWith(color: primary),
      headlineMedium: AppTextStyles.labelLg.copyWith(color: primary),
      headlineSmall: AppTextStyles.labelMd.copyWith(color: primary),
      titleLarge: AppTextStyles.labelLg.copyWith(color: primary),
      titleMedium: AppTextStyles.labelMd.copyWith(color: primary),
      titleSmall: AppTextStyles.labelSm.copyWith(color: primary),
      bodyLarge: AppTextStyles.labelMd.copyWith(color: primary),
      bodyMedium: AppTextStyles.labelSm.copyWith(color: primary),
      bodySmall: AppTextStyles.labelXs.copyWith(color: secondary),
      labelLarge: AppTextStyles.labelMd.copyWith(color: primary),
      labelMedium: AppTextStyles.labelSm.copyWith(color: primary),
      labelSmall: AppTextStyles.labelXs.copyWith(color: secondary),
    );
  }
}

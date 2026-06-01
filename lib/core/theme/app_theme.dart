import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF141414);
  static const Color card = Color(0xFF1A1A2E);
  static const Color cardBorder = Color(0xFF252547);
  static const Color cyan = Color(0xFF00D4FF);
  static const Color orange = Color(0xFFFF6B35);
  static const Color blue = Color(0xFF0066FF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color gray = Color(0xFFA0A0A0);
  static const Color inputFill = Color(0xFF1E1E1E);
  static const Color inputBorder = Color(0xFF333333);
  static const Color appBarBg = Color(0xFF0A0A0A);
  static const Color chipGreen = Color(0xFF00FF88);
  static const Color chipYellow = Color(0xFFFFD700);
  static const Color chipRed = Color(0xFFFF3355);
  static const Color chipPurple = Color(0xFF9B59B6);
  static const Color shadowCyan = Color(0x0D00D4FF);
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final rajdhani = GoogleFonts.rajdhani();
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );
    final titleTextTheme = GoogleFonts.rajdhaniTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.cyan,
        secondary: AppColors.blue,
        surface: AppColors.surface,
        error: AppColors.chipRed,
        onPrimary: AppColors.black,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: titleTextTheme.displayLarge?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: titleTextTheme.displayMedium?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: titleTextTheme.displaySmall?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineLarge: titleTextTheme.headlineLarge?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: titleTextTheme.headlineMedium?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: titleTextTheme.headlineSmall?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: titleTextTheme.titleLarge?.copyWith(
          fontFamily: rajdhani.fontFamily,
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: textTheme.titleMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: textTheme.titleSmall?.copyWith(
          color: AppColors.gray,
        ),
        bodyLarge: textTheme.bodyLarge?.copyWith(
          color: AppColors.white,
        ),
        bodyMedium: textTheme.bodyMedium?.copyWith(
          color: AppColors.gray,
        ),
        bodySmall: textTheme.bodySmall?.copyWith(
          color: AppColors.gray,
        ),
        labelLarge: textTheme.labelLarge?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.appBarBg,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: rajdhani.fontFamily,
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.cyan, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 4,
        shadowColor: AppColors.shadowCyan,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.blue;
            }
            return null;
          }),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.cyan,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.cyan, width: 1),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: AppColors.gray),
        labelStyle: const TextStyle(color: AppColors.gray),
        errorStyle: const TextStyle(color: AppColors.chipRed),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.cyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.chipRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.chipRed, width: 2),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.gray,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.card,
        selectedColor: AppColors.cyan.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: AppColors.white),
        side: const BorderSide(color: AppColors.cardBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.cyan,
        foregroundColor: AppColors.black,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.cyan;
          return AppColors.gray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.cyan.withValues(alpha: 0.3);
          }
          return AppColors.inputBorder;
        }),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.cyan,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surface,
        contentTextStyle: const TextStyle(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

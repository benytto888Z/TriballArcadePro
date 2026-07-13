// lib/core/theme/neon_theme.dart

import 'package:flutter/material.dart';
import '../values/color_values.dart';

class NeonTheme {
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorValues.neonBgDark,
    primaryColor: ColorValues.neonCyan,
    fontFamily: 'Orbitron',
    canvasColor: ColorValues.neonBgDark,

    colorScheme: const ColorScheme.dark(
      primary: ColorValues.neonCyan,
      secondary: ColorValues.neonPink,
      tertiary: ColorValues.neonPurple,
      surface: ColorValues.neonSurface,
      error: ColorValues.neonRed,
      onPrimary: ColorValues.neonBgDark,
      onSecondary: ColorValues.whiteColor,
      onSurface: ColorValues.whiteColor,
    ),

    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: ColorValues.neonCyan),
      titleTextStyle: TextStyle(
        fontFamily: 'Orbitron',
        color: ColorValues.neonCyan,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        shadows: [
          Shadow(color: ColorValues.neonCyan.withOpacity(0.6), blurRadius: 12),
        ],
      ),
    ),

    cardTheme: CardThemeData(
      color: ColorValues.neonSurface.withOpacity(0.6),
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColorValues.neonCyan, width: 1.5),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.neonPink,
        foregroundColor: ColorValues.whiteColor,
        elevation: 8,
        shadowColor: ColorValues.neonPink,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ColorValues.neonCyan, width: 2),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Orbitron',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorValues.neonSurface.withOpacity(0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorValues.neonCyan),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: ColorValues.neonCyan.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorValues.neonPink, width: 2),
      ),
      hintStyle: const TextStyle(color: ColorValues.greyTxtInfoColor),
      labelStyle: const TextStyle(color: ColorValues.neonCyan),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'PressStart2P',
        color: ColorValues.neonCyan,
        fontSize: 48,
        letterSpacing: 4,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Orbitron',
        color: ColorValues.neonCyan,
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 3,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Orbitron',
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: Colors.white,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Orbitron',
        color: ColorValues.darkSubtitleTextColor,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Orbitron',
        color: ColorValues.neonCyan,
        fontSize: 14,
        letterSpacing: 1.5,
      ),
    ),

    iconTheme: const IconThemeData(color: ColorValues.neonCyan),
    dividerColor: ColorValues.neonPurple.withValues(alpha: 0.3),

    sliderTheme: SliderThemeData(
      activeTrackColor: ColorValues.neonPink,
      inactiveTrackColor: ColorValues.neonPink.withValues(alpha:0.2),
      thumbColor: ColorValues.neonCyan,
      overlayColor: ColorValues.neonCyan.withValues(alpha:0.2),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
            ? ColorValues.neonPink
            : ColorValues.neonCyan,
      ),
      trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
            ? ColorValues.neonPink.withOpacity(0.4)
            : ColorValues.neonCyan.withOpacity(0.2),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorValues.neonSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColorValues.neonCyan, width: 2),
      ),
    ),
  );
}
// lib/core/theme/esports_theme.dart

import 'package:flutter/material.dart';
import '../values/color_values.dart';

class EsportsTheme {
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ColorValues.esportsBg,
    primaryColor: ColorValues.esportsGold,
    fontFamily: 'Rajdhani',
    canvasColor: ColorValues.esportsBg,

    colorScheme: const ColorScheme.dark(
      primary: ColorValues.esportsGold,
      secondary: ColorValues.esportsRed,
      tertiary: ColorValues.esportsBlue,
      surface: ColorValues.esportsSurface,
      error: ColorValues.esportsRed,
      onPrimary: ColorValues.esportsBg,
      onSecondary: ColorValues.whiteColor,
      onSurface: ColorValues.esportsText,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: ColorValues.esportsBg,
      elevation: 0,
      iconTheme: IconThemeData(color: ColorValues.esportsGold),
      titleTextStyle: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsGold,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
      ),
    ),

    cardTheme: CardThemeData(
      color: ColorValues.esportsSurface,
      elevation: 12,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.esportsGold,
        foregroundColor: ColorValues.esportsBg,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: ColorValues.esportsSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ColorValues.esportsGold),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: ColorValues.esportsGold.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ColorValues.esportsGold, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF6E6E6E)),
      labelStyle: const TextStyle(color: ColorValues.esportsGold),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsGold,
        fontSize: 48,
        fontWeight: FontWeight.w900,
        letterSpacing: 2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsGold,
        fontSize: 36,
        fontWeight: FontWeight.w900,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsText,
        fontSize: 28,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsText,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsText,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsText,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.darkSubtitleTextColor,
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Rajdhani',
        color: ColorValues.esportsGold,
        fontSize: 14,
        letterSpacing: 1.2,
      ),
    ),

    iconTheme: const IconThemeData(color: ColorValues.esportsGold),
    dividerColor: ColorValues.esportsGold.withOpacity(0.3),

    sliderTheme: SliderThemeData(
      activeTrackColor: ColorValues.esportsGold,
      inactiveTrackColor: ColorValues.esportsGold.withOpacity(0.2),
      thumbColor: ColorValues.esportsGold,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(ColorValues.esportsGold),
      trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
            ? ColorValues.esportsGold.withOpacity(0.5)
            : Colors.grey.withOpacity(0.3),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ColorValues.esportsSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
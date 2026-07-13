// lib/core/theme/carnival_theme.dart

import 'package:flutter/material.dart';
import '../values/color_values.dart';

class CarnivalTheme {
  static ThemeData get themeData => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ColorValues.carnivalBg,
    primaryColor: ColorValues.carnivalOrange,
    fontFamily: 'FredokaOne',
    canvasColor: ColorValues.carnivalBg,

    colorScheme: const ColorScheme.light(
      primary: ColorValues.carnivalOrange,
      secondary: ColorValues.carnivalRed,
      tertiary: ColorValues.carnivalPurple,
      surface: Colors.white,
      error: ColorValues.carnivalRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: ColorValues.carnivalOrange,
      elevation: 4,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        fontFamily: 'FredokaOne',
        color: Colors.white,
        fontSize: 24,
      ),
    ),

    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 6,
      shadowColor: ColorValues.carnivalOrange.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorValues.carnivalOrange,
        foregroundColor: Colors.white,
        elevation: 6,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontFamily: 'FredokaOne',
          fontSize: 16,
        ),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: ColorValues.carnivalOrange),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: ColorValues.carnivalOrange.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: const BorderSide(color: ColorValues.carnivalOrange, width: 2),
      ),
      hintStyle: const TextStyle(color: Color(0xFF999999)),
      labelStyle: const TextStyle(color: ColorValues.carnivalOrange),
    ),

    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'FredokaOne',
        color: ColorValues.carnivalOrange,
        fontSize: 48,
      ),
      displayMedium: TextStyle(
        fontFamily: 'FredokaOne',
        color: ColorValues.carnivalOrange,
        fontSize: 36,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'FredokaOne',
        color: Colors.black,
        fontSize: 28,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'FredokaOne',
        color: Colors.black,
        fontSize: 22,
      ),
      titleLarge: TextStyle(
        fontFamily: 'FredokaOne',
        color: Colors.black,
        fontSize: 18,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Baloo2',
        color: Colors.black,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Baloo2',
        color: Color(0xFF555555),
        fontSize: 14,
      ),
      labelLarge: TextStyle(
        fontFamily: 'FredokaOne',
        color: ColorValues.carnivalOrange,
        fontSize: 14,
      ),
    ),

    iconTheme: const IconThemeData(color: ColorValues.carnivalOrange),
    dividerColor: ColorValues.carnivalOrange.withOpacity(0.3),

    sliderTheme: SliderThemeData(
      activeTrackColor: ColorValues.carnivalOrange,
      inactiveTrackColor: ColorValues.carnivalOrange.withOpacity(0.2),
      thumbColor: ColorValues.carnivalRed,
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.all(ColorValues.carnivalOrange),
      trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
            ? ColorValues.carnivalOrange.withOpacity(0.5)
            : Colors.grey.withOpacity(0.3),
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
    ),
  );
}
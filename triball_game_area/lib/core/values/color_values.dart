// lib/core/values/color_values.dart

import 'package:flutter/material.dart';

class ColorValues {
  // ==========================================
  // EXISTING COLORS (gardés)
  // ==========================================
  static const Color whiteColor = Color(0xFFFFFFFF);
  static const Color blackColor = Color(0xFF000000);
  static const Color grayColor = Color(0xFF808080);
  static const Color txtFieldHintColor = Color(0xFFB1B1B1);
  static const Color txtFieldTxtColor = Color(0xFFFFFFFF);
  static const Color greyTxtInfoColor = Color(0xFF9E9E9E);
  static const Color darkSubtitleTextColor = Color(0xFFCCCCCC);
  static const Color darkSubtitleTextColor2 = Color(0xFFAAAAAA);
  static const Color darkBodyTextColor = Color(0xFFDDDDDD);
  static const Color btnBgColorYellow = Color(0xFFFFBE0B);
  static const Color bottomNavBgColor = Color(0xFF1A1A2E);

  // ==========================================
  // NEON ARCADE THEME (Primary)
  // ==========================================
  static const Color neonBgDark = Color(0xFF0A0E27);
  static const Color neonBgDarker = Color(0xFF05071A);
  static const Color neonSurface = Color(0xFF12172E);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonCyan = Color(0xFF00F5FF);
  static const Color neonPurple = Color(0xFF8338EC);
  static const Color neonYellow = Color(0xFFFFBE0B);
  static const Color neonGreen = Color(0xFF06FFA5);
  static const Color neonRed = Color(0xFFFF3366);
  static const Color neonBlue = Color(0xFF3A86FF);

  // ==========================================
  // ESPORTS THEME
  // ==========================================
  static const Color esportsBg = Color(0xFF1A1A2E);
  static const Color esportsSurface = Color(0xFF16213E);
  static const Color esportsGold = Color(0xFFFFD700);
  static const Color esportsRed = Color(0xFFE94560);
  static const Color esportsBlue = Color(0xFF0F3460);
  static const Color esportsGreen = Color(0xFF00D9A3);
  static const Color esportsText = Color(0xFFEAEAEA);

  // ==========================================
  // CARNIVAL THEME
  // ==========================================
  static const Color carnivalBg = Color(0xFFFFF8E7);
  static const Color carnivalOrange = Color(0xFFFF6B35);
  static const Color carnivalYellow = Color(0xFFFFD23F);
  static const Color carnivalRed = Color(0xFFEE4266);
  static const Color carnivalBlue = Color(0xFF4ECDC4);
  static const Color carnivalPurple = Color(0xFFA06CD5);
  static const Color carnivalGreen = Color(0xFF95E06C);

  // ==========================================
  // GAME-SPECIFIC
  // ==========================================
  static const Color scorePositive = Color(0xFF06FFA5);
  static const Color scoreNegative = Color(0xFFFF3366);
  static const Color scoreBonus = Color(0xFFFFBE0B);
  static const Color scoreX0 = Color(0xFFFF0044);
  static const Color scoreX2 = Color(0xFFFFD700);
  static const Color gameTimer = Color(0xFF00F5FF);
  static const Color gamePrimary = Color(0xFF00F5FF);
  static const Color gameSecondary = Color(0xFFFF006E);

  // ==========================================
  // CONNECTION STATUS
  // ==========================================
  static const Color connectionConnected = Color(0xFF06FFA5);
  static const Color connectionDisconnected = Color(0xFFFF3366);
  static const Color connectionConnecting = Color(0xFFFFBE0B);
  static const Color connectionReconnecting = Color(0xFFFF8800);

  // ==========================================
  // GRADIENTS
  // ==========================================
  static const LinearGradient neonGradient = LinearGradient(
    colors: [neonPink, neonPurple, neonCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient esportsGradient = LinearGradient(
    colors: [esportsBlue, esportsBg],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient carnivalGradient = LinearGradient(
    colors: [carnivalOrange, carnivalYellow],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
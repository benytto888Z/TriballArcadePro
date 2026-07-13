// lib/core/theme/theme_colors.dart

import 'package:flutter/material.dart';
import 'app_theme_controller.dart';

/// Abstraction qui fournit les couleurs adaptées au thème actif.
/// Utilisable partout via ThemeColors.primary, ThemeColors.background, etc.
abstract class ThemeColors {
  static AppThemeMode get _mode {
    try {
      return AppThemeController.instance.currentTheme.value;
    } catch (_) {
      return AppThemeMode.neon;
    }
  }

  // ==========================================
  // BACKGROUND
  // ==========================================
  static Color get background {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF0A0E27);
      case AppThemeMode.esports: return const Color(0xFF1A1A2E);
      case AppThemeMode.carnival: return const Color(0xFFFFF8E7);
    }
  }

  static Color get backgroundDeep {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF05071A);
      case AppThemeMode.esports: return const Color(0xFF0F0F1F);
      case AppThemeMode.carnival: return const Color(0xFFFFEEC8);
    }
  }

  static Color get surface {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF12172E);
      case AppThemeMode.esports: return const Color(0xFF16213E);
      case AppThemeMode.carnival: return Colors.white;
    }
  }

  // ==========================================
  // PRIMARY / SECONDARY / ACCENT
  // ==========================================
  static Color get primary {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF00F5FF);   // cyan
      case AppThemeMode.esports: return const Color(0xFFFFD700); // gold
      case AppThemeMode.carnival: return const Color(0xFFFF6B35); // orange
    }
  }

  static Color get secondary {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFFFF006E);   // pink
      case AppThemeMode.esports: return const Color(0xFFE94560); // red
      case AppThemeMode.carnival: return const Color(0xFFEE4266); // red
    }
  }

  static Color get accent {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF8338EC);   // purple
      case AppThemeMode.esports: return const Color(0xFF2773CD); // blue
      // case AppThemeMode.esports: return const Color(0xFF0F3460); // blue
      case AppThemeMode.carnival: return const Color(0xFFA06CD5); // purple
    }
  }

  static Color get tertiary {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFFFFBE0B);   // yellow
      case AppThemeMode.esports: return const Color(0xFF00D9A3); // green
      case AppThemeMode.carnival: return const Color(0xFFFFD23F); // yellow
    }
  }

  // ==========================================
  // TEXT
  // ==========================================
  static Color get textPrimary {
    switch (_mode) {
      case AppThemeMode.neon: return Colors.white;
       case AppThemeMode.esports: return const Color(0xFFEAEAEA);
      case AppThemeMode.carnival: return const Color(0xFF1A1A1A);
    }
  }

  static Color get textSecondary {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFFCCCCCC);

       case AppThemeMode.esports: return const Color(0xFFB0B0B0);
      case AppThemeMode.carnival: return const Color(0xFF555555);
    }
  }

  static Color get textHint {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF888888);
      case AppThemeMode.esports: return const Color(0xFF6E6E6E);
      case AppThemeMode.carnival: return const Color(0xFF999999);
    }
  }

  // ==========================================
  // STATUS COLORS
  // ==========================================
  static Color get success {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF06FFA5);
      case AppThemeMode.esports: return const Color(0xFF00D9A3);
      // case AppThemeMode.carnival: return const Color(0xFF95E06C);
      case AppThemeMode.carnival: return const Color(0xFF09350B);
    }
  }

  static Color get error {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFFFF3366);
      case AppThemeMode.esports: return const Color(0xFFE94560);
      case AppThemeMode.carnival: return const Color(0xFFEE4266);
    }
  }

  static Color get warning {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFFFFBE0B);
      case AppThemeMode.esports: return const Color(0xFFFFD700);
      case AppThemeMode.carnival: return const Color(0xFFFFD23F);
    }
  }

  static Color get info {
    switch (_mode) {
      case AppThemeMode.neon: return const Color(0xFF3A86FF);
      case AppThemeMode.esports: return const Color(0xFF4ECDC4);
      case AppThemeMode.carnival: return const Color(0xFF4ECDC4);
    }
  }

  // ==========================================
  // GAME-SPECIFIC
  // ==========================================
  static Color get scorePositive => success;
  static Color get scoreNegative => error;
  static Color get scoreBonus => tertiary;
  static Color get scoreX0 => error;
  static Color get scoreX2 => warning;

  static Color get connectionConnected => success;
  static Color get connectionDisconnected => error;
  static Color get connectionConnecting => warning;

  // ==========================================
  // FONTS
  // ==========================================
  static String get fontPrimary {
    switch (_mode) {
      case AppThemeMode.neon: return 'Orbitron';
      case AppThemeMode.esports: return 'Rajdhani';
      case AppThemeMode.carnival: return 'FredokaOne';
    }
  }

  static String get fontDisplay {
    switch (_mode) {
      case AppThemeMode.neon: return 'PressStart2P';
      case AppThemeMode.esports: return 'Rajdhani';
      case AppThemeMode.carnival: return 'FredokaOne';
    }
  }

  static String get fontBody {
    switch (_mode) {
      case AppThemeMode.neon: return 'Orbitron';
      case AppThemeMode.esports: return 'Rajdhani';
      case AppThemeMode.carnival: return 'Baloo2';
    }
  }

  // ==========================================
  // STYLE PROPERTIES
  // ==========================================
  static double get cornerRadius {
    switch (_mode) {
      case AppThemeMode.neon: return 8.0;
      case AppThemeMode.esports: return 6.0;
      case AppThemeMode.carnival: return 24.0;
    }
  }

  static double get cornerRadiusLarge {
    switch (_mode) {
      case AppThemeMode.neon: return 16.0;
      case AppThemeMode.esports: return 12.0;
      case AppThemeMode.carnival: return 32.0;
    }
  }

  static double get letterSpacing {
    switch (_mode) {
      case AppThemeMode.neon: return 2.0;
      case AppThemeMode.esports: return 1.5;
      case AppThemeMode.carnival: return 0.5;
    }
  }

  static bool get useGlow {
    switch (_mode) {
      case AppThemeMode.neon: return true;
      case AppThemeMode.esports: return false;
      case AppThemeMode.carnival: return false;
    }
  }

  static bool get useShadows {
    switch (_mode) {
      case AppThemeMode.neon: return false;
      case AppThemeMode.esports: return true;
      case AppThemeMode.carnival: return true;
    }
  }

  // ==========================================
  // GRADIENTS
  // ==========================================
  static LinearGradient get primaryGradient {
    switch (_mode) {
      case AppThemeMode.neon:
        return const LinearGradient(
          colors: [Color(0xFFFF006E), Color(0xFF8338EC), Color(0xFF00F5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeMode.esports:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFF9500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case AppThemeMode.carnival:
        return const LinearGradient(
          colors: [Color(0xFFFF6B35), Color(0xFFFFD23F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  static LinearGradient get backgroundGradient {
    switch (_mode) {
      case AppThemeMode.neon:
        return const LinearGradient(
          colors: [Color(0xFF12172E), Color(0xFF05071A)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case AppThemeMode.esports:
        return const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1F)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case AppThemeMode.carnival:
        return const LinearGradient(
          colors: [Color(0xFFFFF8E7), Color(0xFFFFEEC8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }
}
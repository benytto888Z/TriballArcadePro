// lib/core/utils/helpers.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Helpers {
  Helpers._();

  // ==========================================
  // TIME FORMATTING
  // ==========================================
  static String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String formatDurationWithMs(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');
    return '$minutes:$seconds.$ms';
  }

  static String formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  // ==========================================
  // SCORE
  // ==========================================
  static String formatScore(int score) {
    return score >= 0 ? '+$score' : '$score';
  }

  static Color scoreColor(int score) {
    if (score > 0) return const Color(0xFF06FFA5);
    if (score < 0) return const Color(0xFFFF3366);
    return const Color(0xFF808080);
  }

  // ==========================================
  // HOLE → POSITION (3x3 grid)
  // ==========================================
  static int holeToIndex(String holeId) {
    switch (holeId) {
      case 'LEFT_TOP':    return 0;
      case 'CENTER_TOP':  return 1;
      case 'RIGHT_TOP':   return 2;
      case 'LEFT_MID':    return 3;
      case 'CENTER_MID':  return 4;
      case 'RIGHT_MID':   return 5;
      case 'LEFT_LOW':    return 6;
      case 'CENTER_LOW':  return 7;
      case 'RIGHT_LOW':   return 8;
    }
    return -1;
  }

  static String holeDisplay(String holeId) {
    switch (holeId) {
      case 'LEFT_TOP':    return '+10';
      case 'CENTER_TOP':  return '-10';
      case 'RIGHT_TOP':   return '+5';
      case 'LEFT_MID':    return '-5';
      case 'CENTER_MID':  return '+30';
      case 'RIGHT_MID':   return '-5';
      case 'LEFT_LOW':    return '+5';
      case 'CENTER_LOW':  return '×0';
      case 'RIGHT_LOW':   return '×2';
    }
    return '?';
  }

  // ==========================================
  // SNACKBAR
  // ==========================================
  static void showSnackbar(String title, String message,
      {Color? color, IconData? icon}) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: color ?? Colors.black87,
      colorText: Colors.white,
      icon: icon != null ? Icon(icon, color: Colors.white) : null,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 2),
    );
  }

  // ==========================================
  // PLAYER COLORS
  // ==========================================
  static const List<Color> playerColors = [
    Color(0xFF00F5FF), // cyan
    Color(0xFFFF006E), // pink
    Color(0xFFFFBE0B), // yellow
    Color(0xFF06FFA5), // green
    Color(0xFF8338EC), // purple
    Color(0xFFFF8800), // orange
  ];

  static Color playerColor(int index) {
    return playerColors[index % playerColors.length];
  }
}
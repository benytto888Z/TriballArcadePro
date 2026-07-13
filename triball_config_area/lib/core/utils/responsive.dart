// lib/core/utils/responsive.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum DeviceType { phone, tablet, desktop, tv }

/// Helper pour le responsive design.
/// Basé sur la LARGEUR de l'écran en paysage.
class Responsive {
  Responsive._();

  // Breakpoints en pixels logiques (largeur paysage)
  static const double phoneMax = 720;
  static const double tabletMax = 1100;
  static const double desktopMax = 1920;

  static double get screenWidth {
    final ctx = Get.context;
    if (ctx == null) return 926;
    return MediaQuery.of(ctx).size.width;
  }

  static double get screenHeight {
    final ctx = Get.context;
    if (ctx == null) return 428;
    return MediaQuery.of(ctx).size.height;
  }

  static DeviceType get deviceType {
    final w = screenWidth;
    if (w < phoneMax) return DeviceType.phone;
    if (w < tabletMax) return DeviceType.tablet;
    if (w < desktopMax) return DeviceType.desktop;
    return DeviceType.tv;
  }

  static bool get isPhone   => deviceType == DeviceType.phone;
  static bool get isTablet  => deviceType == DeviceType.tablet;
  static bool get isDesktop => deviceType == DeviceType.desktop;
  static bool get isTV      => deviceType == DeviceType.tv;

  /// Renvoie une valeur selon le device type
  static T value<T>({
    required T phone,
    T? tablet,
    T? desktop,
    T? tv,
  }) {
    switch (deviceType) {
      case DeviceType.phone:   return phone;
      case DeviceType.tablet:  return tablet ?? phone;
      case DeviceType.desktop: return desktop ?? tablet ?? phone;
      case DeviceType.tv:      return tv ?? desktop ?? tablet ?? phone;
    }
  }

  /// Facteur de scale pour les fonts selon device
  static double get fontScale {
    switch (deviceType) {
      case DeviceType.phone:   return 1.0;
      case DeviceType.tablet:  return 1.1;
      case DeviceType.desktop: return 1.15;
      case DeviceType.tv:      return 1.3;
    }
  }

  /// Padding adaptatif horizontal
  static double get horizontalPadding {
    return value(
      phone: 16.w,
      tablet: 24.w,
      desktop: 32.w,
      tv: 48.w,
    );
  }

  /// Padding adaptatif vertical
  static double get verticalPadding {
    return value(
      phone: 12.h,
      tablet: 16.h,
      desktop: 20.h,
      tv: 32.h,
    );
  }

  /// Nombre de colonnes pour les grids
  static int get gridColumns {
    return value(
      phone: 2,
      tablet: 3,
      desktop: 4,
      tv: 6,
    );
  }
}
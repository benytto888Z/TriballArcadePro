// triball_game_area/lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/pulsing_dot.dart';
import 'splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [ThemeColors.background, ThemeColors.backgroundDeep],
                radius: 1.5,
              ),
            ),
          ),
          const FloatingParticles(count: 30),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AnimatedLogo(fontSize: 80, subtitleFontSize: 24),
                SizedBox(height: 16.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: ThemeColors.accent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: ThemeColors.accent.withOpacity(0.5)),
                  ),
                  child: Text(
                    'GAME AREA',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.accent,
                      letterSpacing: 6,
                    ),
                  ),
                ),
                SizedBox(height: 60.h),
                SizedBox(
                  width: 400.w,
                  child: Obx(() => Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: controller.progress.value,
                          minHeight: 10,
                          backgroundColor: ThemeColors.primary.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation(ThemeColors.secondary),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          PulsingDot(
                            color: controller.isReady.value
                                ? ThemeColors.success
                                : ThemeColors.primary,
                            size: 12,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            controller.status.value.tr,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: ThemeColors.primary,
                              fontSize: 16.sp,
                              letterSpacing: 3,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'app_version'.tr,
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  color: ThemeColors.textSecondary.withOpacity(0.5),
                  fontSize: 12.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
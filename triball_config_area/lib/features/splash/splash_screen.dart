// triball_config_area/lib/features/splash/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/values/app_styles.dart';
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
                colors: [
                  ThemeColors.background,
                  ThemeColors.backgroundDeep,
                ],
                radius: 1.5,
              ),
            ),
          ),
          const FloatingParticles(count: 25),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ============= LOGO =============
                    const AnimatedLogo(
                      fontSize: 52,
                      subtitleFontSize: 16,
                    ),
                    SizedBox(height: 12.h),

                    // ============= SUBTITLE =============
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: ThemeColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ThemeColors.primary.withOpacity(0.4),
                        ),
                      ),
                      child: Text(
                        'CONFIG AREA',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: ThemeColors.primary,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),

                    // ============= PROGRESS BAR =============
                    SizedBox(
                      width: 280.w,
                      child: Obx(() => Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: controller.progress.value,
                              minHeight: 8,
                              backgroundColor: ThemeColors.primary
                                  .withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation(
                                ThemeColors.secondary,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            '${(controller.progress.value * 100).round()}%',
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: ThemeColors.primary,
                              fontSize: 11.sp,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      )),
                    ),
                    SizedBox(height: 20.h),

                    // ============= STATUS TEXT =============
                    Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PulsingDot(
                          color: controller.isReady.value
                              ? ThemeColors.success
                              : ThemeColors.primary,
                          size: 10,
                        ),
                        SizedBox(width: 10.w),
                        Flexible(
                          child: Text(
                            controller.status.value.tr,
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              color: controller.isReady.value
                                  ? ThemeColors.success
                                  : ThemeColors.primary,
                              fontSize: 13.sp,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )),
                    SizedBox(height: 30.h),

                    // ============= CONNECTION STATUS =============
                    Obx(() {
                      return Column(
                        children: [
                          // ESP32
                          _ConnectionRow(
                            icon: Icons.router,
                            label: 'platform'.tr,
                            connected: controller.platformConnected.value,
                          ),
                          SizedBox(height: 8.h),
                          // Game Area
                          _ConnectionRow(
                            icon: Icons.tv,
                            label: 'game_area_label'.tr,
                            connected: controller.gameAreaDetected.value,
                            waitingLabel:
                            'waiting_for_game_area_short'.tr,
                          ),
                        ],
                      );
                    }),

                    SizedBox(height: 30.h),

                    // ============= VERSION =============
                    Text(
                      'app_version'.tr,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        color: ThemeColors.textSecondary.withOpacity(0.5),
                        fontSize: 9.sp,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONNECTION ROW
// ============================================================
class _ConnectionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool connected;
  final String? waitingLabel;

  const _ConnectionRow({
    required this.icon,
    required this.label,
    required this.connected,
    this.waitingLabel,
  });

  @override
  Widget build(BuildContext context) {
    final color = connected ? ThemeColors.success : ThemeColors.warning;
    final text = connected
        ? 'connected'.tr
        : (waitingLabel ?? 'connecting'.tr);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          connected ? Icons.check_circle : Icons.hourglass_top,
          color: color,
          size: 16.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          '$label : $text',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: color,
            fontSize: 11.sp,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
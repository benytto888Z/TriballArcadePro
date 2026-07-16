// triball_game_area/lib/features/waiting/waiting_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/values/app_styles.dart';
import '../../widgets/animated_logo.dart';
import '../../widgets/floating_particles.dart';
import '../game/utils/game_screen_breakpoints.dart';
import 'waiting_controller.dart';
import 'widgets/admin_exit_zone.dart';
import 'widgets/waiting_instructions.dart';
import 'widgets/waiting_leaderboard_carousel.dart';
import 'widgets/waiting_status_bar.dart';

class WaitingScreen extends GetView<WaitingController> {
  const WaitingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundDeep,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: ThemeColors.backgroundGradient,
            ),
          ),
          FloatingParticles(
            count: GameScreenBreakpoints.waitingParticlesCount(),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: GameScreenBreakpoints.waitingScreenPaddingH(),
                vertical: GameScreenBreakpoints.waitingScreenPaddingV(),
              ),
              child: Column(
                children: [
                  const WaitingStatusBar(),
                  SizedBox(height: GameScreenBreakpoints.waitingScreenPaddingV()),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          flex: GameScreenBreakpoints.waitingLeftFlex(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedLogo(
                                fontSize: GameScreenBreakpoints.waitingLogoFontSize(),
                                subtitleFontSize: GameScreenBreakpoints.waitingSubtitleFontSize(),
                              ),
                              SizedBox(height: 30.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: ThemeColors.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: ThemeColors.accent.withOpacity(0.5),
                                  ),
                                  boxShadow: ThemeColors.useGlow
                                      ? [
                                    BoxShadow(
                                      color: ThemeColors.accent.withOpacity(0.3),
                                      blurRadius: 20,
                                    ),
                                  ]
                                      : null,
                                ),
                                child: Text(
                                  'GAME AREA',
                                  style: TextStyle(
                                    fontFamily: AppStyles.defaultFontFamily2,
                                    fontSize: GameScreenBreakpoints.waitingBadgeFontSize()*1.2,
                                    fontWeight: FontWeight.w800,
                                    color: ThemeColors.accent,
                                    shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                                    letterSpacing: 6,
                                  ),
                                ),
                              ),
                              SizedBox(height: 30.h),
                              const WaitingInstructions(),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: GameScreenBreakpoints.waitingContentSpacing(),
                        ),
                        Expanded(
                          flex: GameScreenBreakpoints.waitingRightFlex(),
                          child: const WaitingLeaderboardCarousel(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ✅ Zone de tap cachée pour admin (coin en haut à droite)
          Positioned(
            top: 0,
            right: 0,
            child: AdminExitZone(),
          ),
        ],
      ),
    );
  }
}
// triball_game_area/lib/features/waiting/widgets/waiting_instructions.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/values/app_styles.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../waiting_controller.dart';

class WaitingInstructions extends GetView<WaitingController> {
  const WaitingInstructions({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final lastWinner = controller.lastWinnerName.value;
      final hasWinner = lastWinner.isNotEmpty;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasWinner) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: ThemeColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ThemeColors.warning.withOpacity(0.5)),
                boxShadow: ThemeColors.useGlow
                    ? [
                  BoxShadow(
                    color: ThemeColors.warning.withOpacity(0.3),
                    blurRadius: 20,
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '🏆',
                    style: TextStyle(
                      fontSize: GameScreenBreakpoints.waitingWinnerTrophySize(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'last_winner'.tr.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppStyles.defaultFontFamily2,
                          fontSize: GameScreenBreakpoints.waitingStatusLabelSize()*1.2,
                          color: ThemeColors.textSecondary,
                          shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 5)],
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        lastWinner.toUpperCase(),
                        style: TextStyle(
                          fontFamily: AppStyles.defaultFontFamily2,
                          fontSize: GameScreenBreakpoints.waitingWinnerNameFontSize()*1.2,
                          fontWeight: FontWeight.w900,
                          color: ThemeColors.warning,
                          shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 5)],
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
          ],

          _PulsingText(
            text: 'waiting_for_config'.tr,
            color: ThemeColors.primary,
            fontSize: GameScreenBreakpoints.waitingMessageFontSize(),
          ),
          SizedBox(height: 12.h),
          Text(
            'waiting_instruction_detail'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppStyles.defaultFontFamily2,
              fontSize: GameScreenBreakpoints.waitingDetailFontSize()*1.3,
              color: ThemeColors.textSecondary,
              fontWeight: FontWeight.w900,
              shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 5)],
              height: 1.6,
              letterSpacing: 1,
            ),
          ),
        ],
      );
    });
  }
}

class _PulsingText extends StatefulWidget {
  final String text;
  final Color color;
  final double fontSize;

  const _PulsingText({
    required this.text,
    required this.color,
    required this.fontSize,
  });

  @override
  State<_PulsingText> createState() => _PulsingTextState();
}

class _PulsingTextState extends State<_PulsingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, _) {
        return Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily:AppStyles.defaultFontFamily2,
            fontSize: widget.fontSize*1.3,
            fontWeight: FontWeight.w700,
            color: widget.color.withOpacity(_opacity.value),
            letterSpacing: 3,
              shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
          ),
        );
      },
    );
  }
}
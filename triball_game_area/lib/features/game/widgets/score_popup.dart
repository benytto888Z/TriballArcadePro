// lib/features/game/widgets/score_popup.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/theme_colors.dart';
import '../../../core/constants/game_constants.dart';
import '../game_controller.dart';
import '../utils/game_screen_breakpoints.dart';


class ScorePopup extends GetView<GameController> {
  const ScorePopup({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final event = controller.lastEvent.value;
      final result = controller.lastResult.value;
     if (event == null || result == null) return const SizedBox.shrink();

      return _AnimatedPopup(
        key: ValueKey(event.timestamp),
        event: event,
        isOvershoot: result.isOvershoot,
      );
    });
  }
}

class _AnimatedPopup extends StatefulWidget {
  final dynamic event;
  final bool isOvershoot;

  const _AnimatedPopup({
    super.key,
    required this.event,
    required this.isOvershoot,
  });

  @override
  State<_AnimatedPopup> createState() => _AnimatedPopupState();
}

class _AnimatedPopupState extends State<_AnimatedPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _scale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.3)
              .chain(CurveTween(curve: Curves.elasticOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween(begin: 1.3, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 20),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
      TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.8)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 10),
    ]).animate(_ctrl);

    _opacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 15),
    ]).animate(_ctrl);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color _color() {
    if (widget.event.isX0) return ThemeColors.error;
    if (widget.event.isX2) return ThemeColors.warning;
    if (widget.event.value >= 30) return ThemeColors.primary;
    if (widget.event.isPositive) return ThemeColors.success;
    if (widget.event.isNegative) return ThemeColors.error;
    return ThemeColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _opacity,
              child: Transform.scale(
                scale: _scale.value,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 30.w,
                    vertical: 14.h,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.6), blurRadius: 30),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.event.displayValue,
                        style: TextStyle(
                          fontFamily: GameConstants.gameFontFamily,
                          fontSize: GameScreenBreakpoints.scorePopupFontSize()*3,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: 2,
                            shadows: [ Shadow(color: Color(0x84070707), offset: Offset(0, 6), blurRadius: 7)]
                        ),
                      ),
                      if (widget.isOvershoot) ...[
                        SizedBox(height: 4.h),
                        Text(
                          'OVERSHOOT',
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize: 120.sp,
                            color: ThemeColors.error,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w900,
                              shadows: [ Shadow(color: Color(0x84070707), offset: Offset(0, 6), blurRadius: 7)]
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
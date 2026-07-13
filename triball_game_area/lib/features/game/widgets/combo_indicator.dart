// lib/features/game/widgets/combo_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../data/models/combo_model.dart';
import '../game_controller.dart';

class ComboIndicator extends GetView<GameController> {
  const ComboIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showComboBanner.value) {
        return const SizedBox.shrink();
      }
      final combo = controller.currentCombo.value;
      if (combo == null || combo.type == ComboType.none) {
        return const SizedBox.shrink();
      }

      return _AnimatedComboBanner(
        key: ValueKey(combo.timestamp),
        combo: combo,
      );
    });
  }
}

class _AnimatedComboBanner extends StatefulWidget {
  final ComboModel combo;

  const _AnimatedComboBanner({super.key, required this.combo});

  @override
  State<_AnimatedComboBanner> createState() => _AnimatedComboBannerState();
}

class _AnimatedComboBannerState extends State<_AnimatedComboBanner>
    with TickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late AnimationController _pulseCtrl;
  late Animation<double> _slide;
  late Animation<double> _scale;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _slide = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _entryCtrl, curve: Curves.elasticOut),
    );
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _color() {
    switch (widget.combo.type) {
      case ComboType.tripleCombo:   return ThemeColors.warning;
      case ComboType.doubleCombo:   return ThemeColors.primary;
      case ComboType.perfectStreak: return ThemeColors.success;
      case ComboType.precisionShot: return ThemeColors.tertiary;
      case ComboType.none:          return ThemeColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final combo = widget.combo;
    final mult = combo.type.multiplier;
    final grantsBonus = combo.grantsBonusTurn;

    return AnimatedBuilder(
      animation: Listenable.merge([_entryCtrl, _pulseCtrl]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, _slide.value * 100),
          child: Transform.scale(
            scale: _scale.value * _pulse.value,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 28.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: color, width: 3),
                boxShadow: [
                  BoxShadow(color: color.withOpacity(0.7), blurRadius: 30),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(combo.type.emoji, style: TextStyle(fontSize: 36.sp)),
                  SizedBox(width: 12.w),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.type.translationKey.tr.toUpperCase(),
                        style: TextStyle(
                          fontFamily: GameConstants.gameFontFamily,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          color: color,
                          letterSpacing: 3,
                          shadows: [
                            Shadow(color: color, blurRadius: 15),
                          ],
                        ),
                      ),
                      if (mult > 1.0) ...[
                        SizedBox(height: 2.h),
                        Text(
                          '×${mult.toStringAsFixed(0)} ${'multiplier'.tr}',
                          style: TextStyle(
                            fontFamily: GameConstants.gameFontFamily,
                            fontSize: 12.sp,
                            color: color.withOpacity(0.9),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      // ✅ NEW : Bonus turn indicator
                      if (grantsBonus) ...[
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: ThemeColors.success.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: ThemeColors.success,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.add_circle,
                                color: ThemeColors.success,
                                size: 12.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'bonus_turn'.tr.toUpperCase(),
                                style: TextStyle(
                                  fontFamily: GameConstants.gameFontFamily,
                                  fontSize: 9.sp,
                                  color: ThemeColors.success,
                                  letterSpacing: 1.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
// lib/widgets/animated_logo.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/theme_colors.dart';
import '../core/values/app_styles.dart';

/// Logo TRIBALL animé avec effet glow pulsé et glitch.
class AnimatedLogo extends StatefulWidget {
  final double fontSize;
  final double subtitleFontSize;
  final Duration animationDuration;
  final bool showSubtitle;

  const AnimatedLogo({
    super.key,
    this.fontSize = 92,
    this.subtitleFontSize = 58,
    this.animationDuration = const Duration(seconds: 3),
    this.showSubtitle = true,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _entranceController;
  late Animation<double> _glowAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Glow pulse animation (loop)
    _glowController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Entrance animation (one-shot)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, _) {
                return Text(
                  'TRIBALL',
                  style: TextStyle(
                    fontFamily: AppStyles.defaultFontFamily2,
                    fontSize: widget.fontSize.sp*1.2,
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.primary,
                    letterSpacing: 10,
                    shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 5), blurRadius: 9)]
                  ),
                );
              },
            ),
            if (widget.showSubtitle) ...[
              SizedBox(height: 6.h),
              AnimatedBuilder(
                animation: _glowAnimation,
                builder: (context, _) {
                  return Text(
                    'ARCADE PROS',
                    style: TextStyle(
                      fontFamily: AppStyles.defaultFontFamily2,
                      fontSize: widget.subtitleFontSize.sp*1.2,
                      color: ThemeColors.secondary,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)]
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
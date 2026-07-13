// lib/widgets/animated_logo.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/theme_colors.dart';

/// Logo TRIBALL animé avec effet glow pulsé et glitch.
class AnimatedLogo extends StatefulWidget {
  final double fontSize;
  final double subtitleFontSize;
  final Duration animationDuration;
  final bool showSubtitle;

  const AnimatedLogo({
    super.key,
    this.fontSize = 64,
    this.subtitleFontSize = 18,
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
                    fontFamily: ThemeColors.fontDisplay,
                    fontSize: widget.fontSize.sp,
                    fontWeight: FontWeight.w900,
                    color: ThemeColors.primary,
                    letterSpacing: 10,
                    shadows: ThemeColors.useGlow
                        ? [
                      Shadow(
                        color: ThemeColors.primary
                            .withOpacity(_glowAnimation.value),
                        blurRadius: 30 * _glowAnimation.value,
                      ),
                      Shadow(
                        color: ThemeColors.secondary
                            .withOpacity(_glowAnimation.value * 0.8),
                        blurRadius: 60 * _glowAnimation.value,
                      ),
                    ]
                        : [
                      Shadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                    'ARCADE PRO',
                    style: TextStyle(
                      fontFamily: ThemeColors.fontPrimary,
                      fontSize: widget.subtitleFontSize.sp,
                      color: ThemeColors.secondary,
                      letterSpacing: 8,
                      fontWeight: FontWeight.w700,
                      shadows: ThemeColors.useGlow
                          ? [
                        Shadow(
                          color: ThemeColors.secondary
                              .withOpacity(_glowAnimation.value),
                          blurRadius: 20 * _glowAnimation.value,
                        ),
                      ]
                          : null,
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
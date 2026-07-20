// lib/features/leaderboard/widgets/animated_triball_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../core/theme/theme_colors.dart';

/// Background animé reproduisant la grille Triball 3×3
/// avec trous illuminés en pulsation néon
class AnimatedTriballBackground extends StatefulWidget {
  /// Opacité globale du background (0.0 = invisible, 1.0 = pleine)
  final double opacity;

  /// Vitesse de l'animation (1.0 = normale)
  final double speedFactor;

  const AnimatedTriballBackground({
    super.key,
    this.opacity = 0.45,
    this.speedFactor = 1.0,
  });

  @override
  State<AnimatedTriballBackground> createState() =>
      _AnimatedTriballBackgroundState();
}

class _AnimatedTriballBackgroundState extends State<AnimatedTriballBackground>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _rotateCtrl;

  // Configuration des 9 trous (3×3 grille Triball)
  static const List<_HoleConfig> holes = [
    // Row TOP : +10, -10, +5
    _HoleConfig(value: '+10', color: Color(0xFF06FFA5), row: 0, col: 0),
    _HoleConfig(value: '-10', color: Color(0xFFFF3366), row: 0, col: 1),
    _HoleConfig(value: '+5',  color: Color(0xFF06FFA5), row: 0, col: 2),
    // Row MID : -5, +30, -5
    _HoleConfig(value: '-5',  color: Color(0xFFFF3366), row: 1, col: 0),
    _HoleConfig(value: '+30', color: Color(0xFF00F5FF), row: 1, col: 1),
    _HoleConfig(value: '-5',  color: Color(0xFFFF3366), row: 1, col: 2),
    // Row LOW : +5, x0, x2
    _HoleConfig(value: '+5',  color: Color(0xFF06FFA5), row: 2, col: 0),
    _HoleConfig(value: '×0',  color: Color(0xFFFF006E), row: 2, col: 1),
    _HoleConfig(value: '×2',  color: Color(0xFFFFD700), row: 2, col: 2),
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (2500 / widget.speedFactor).round(),
      ),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: Duration(seconds: (20 / widget.speedFactor).round()),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: widget.opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Background gradient subtle
                Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        ThemeColors.primary.withOpacity(0.08),
                        Colors.transparent,
                      ],
                      radius: 1.0,
                    ),
                  ),
                ),

                // Rotating grid lines (subtle)
                AnimatedBuilder(
                  animation: _rotateCtrl,
                  builder: (context, _) {
                    return Transform.rotate(
                      angle: _rotateCtrl.value * 2 * pi * 0.05,
                      child: CustomPaint(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        painter: _GridLinesPainter(),
                      ),
                    );
                  },
                ),

                // The 9 holes grid
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, _) {
                      return SizedBox(
                        width: 160.w,
                        height: 270.h,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: 9,
                          itemBuilder: (context, index) {
                            final hole = holes[index];

                            // Désynchronisation : chaque trou pulse à un moment différent
                            final phase =
                                (_pulseCtrl.value + (index * 0.11)) % 1.0;
                            final wave =
                            (sin(phase * 2 * pi) * 0.5 + 0.5);

                            return _AnimatedHole(
                              value: hole.value,
                              color: hole.color,
                              pulsePhase: wave,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// HOLE CONFIG
// ============================================================
class _HoleConfig {
  final String value;
  final Color color;
  final int row;
  final int col;

  const _HoleConfig({
    required this.value,
    required this.color,
    required this.row,
    required this.col,
  });
}

// ============================================================
// ANIMATED HOLE (individual)
// ============================================================
class _AnimatedHole extends StatelessWidget {
  final String value;
  final Color color;
  final double pulsePhase; // 0.0 → 1.0

  const _AnimatedHole({
    required this.value,
    required this.color,
    required this.pulsePhase,
  });

  @override
  Widget build(BuildContext context) {
    // Intensité variable selon la phase
    final intensity = 0.4 + pulsePhase * 0.6;
    final scale = 0.9 + pulsePhase * 0.15;

    return Transform.scale(
      scale: scale,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.15 * intensity),
          border: Border.all(
            color: color.withOpacity(0.7 + intensity * 0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6 * intensity),
              blurRadius: 20 * intensity,
              spreadRadius: 2 * intensity,
            ),
            BoxShadow(
              color: color.withOpacity(0.3 * intensity),
              blurRadius: 40 * intensity,
              spreadRadius: 1 * intensity,
            ),
          ],
        ),
        child: Center(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14.sp,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 1,
              shadows: [
                Shadow(
                  color: color.withOpacity(intensity),
                  blurRadius: 8 * intensity,
                ),
                Shadow(
                  color: color.withOpacity(intensity * 0.5),
                  blurRadius: 16 * intensity,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// GRID LINES PAINTER (subtle background)
// ============================================================
class _GridLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeColors.primary.withOpacity(0.08)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Cercles concentriques
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, 30.0 * i, paint);
    }

    // Rayons
    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * pi;
      final end = Offset(
        center.dx + cos(angle) * 150,
        center.dy + sin(angle) * 150,
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(_GridLinesPainter oldDelegate) => false;
}
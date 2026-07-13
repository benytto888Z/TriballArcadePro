// lib/widgets/animated_background.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final _rand = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    _generateParticles();
  }

  void _generateParticles() {
    _particles.clear();
    for (int i = 0; i < 30; i++) {
      _particles.add(_Particle(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size: _rand.nextDouble() * 4 + 1,
        speed: _rand.nextDouble() * 0.3 + 0.1,
        opacity: _rand.nextDouble() * 0.6 + 0.2,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final mode = Get.find<AppThemeController>().currentTheme.value;
      return AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _BgPainter(
              progress: _controller.value,
              particles: _particles,
              mode: mode,
              primary: ThemeColors.primary,
              secondary: ThemeColors.secondary,
            ),
          );
        },
      );
    });
  }
}

class _Particle {
  final double x, y, size, speed, opacity;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _BgPainter extends CustomPainter {
  final double progress;
  final List<_Particle> particles;
  final AppThemeMode mode;
  final Color primary;
  final Color secondary;

  _BgPainter({
    required this.progress,
    required this.particles,
    required this.mode,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (mode) {
      case AppThemeMode.neon:
        _paintNeon(canvas, size);
        break;
      case AppThemeMode.esports:
        _paintEsports(canvas, size);
        break;
      case AppThemeMode.carnival:
        _paintCarnival(canvas, size);
        break;
    }
  }

  void _paintNeon(Canvas canvas, Size size) {
    // Perspective synthwave grid
    final paint = Paint()
      ..color = primary.withOpacity(0.15)
      ..strokeWidth = 1;

    final horizonY = size.height * 0.5;
    // Horizontal lines
    for (int i = 0; i < 12; i++) {
      double t = (i / 12.0 + progress) % 1.0;
      double y = horizonY + t * t * (size.height - horizonY);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // Vertical lines converging
    for (int i = -8; i <= 8; i++) {
      double xBottom = size.width / 2 + i * size.width / 8;
      canvas.drawLine(
        Offset(size.width / 2, horizonY),
        Offset(xBottom, size.height),
        paint,
      );
    }

    // Floating glowing particles
    final particlePaint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width;
      particlePaint.color = (p.x > 0.5 ? primary : secondary)
          .withOpacity(p.opacity * 0.4);
      canvas.drawCircle(Offset(x, y), p.size, particlePaint);
    }
  }

  void _paintEsports(Canvas canvas, Size size) {
    // Subtle hexagons
    final paint = Paint()
      ..color = primary.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const hexSize = 50.0;
    for (double y = -hexSize; y < size.height + hexSize; y += hexSize * 1.5) {
      for (double x = -hexSize; x < size.width + hexSize; x += hexSize * 1.732) {
        final offsetX = (y ~/ (hexSize * 1.5)) % 2 == 0 ? 0 : hexSize * 0.866;
        _drawHex(canvas, Offset(x + offsetX, y), hexSize / 2, paint);
      }
    }
  }

  void _drawHex(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = i * pi / 3;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _paintCarnival(Canvas canvas, Size size) {
    // Floating colorful confetti
    final paint = Paint()..style = PaintingStyle.fill;
    final colors = [primary, secondary, const Color(0xFFFFD23F),
      const Color(0xFF4ECDC4), const Color(0xFF95E06C)];
    for (int i = 0; i < particles.length; i++) {
      final p = particles[i];
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width +
          sin(progress * 2 * pi + i) * 20;
      paint.color = colors[i % colors.length].withOpacity(p.opacity * 0.5);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(progress * 2 * pi + i);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: p.size * 3, height: p.size * 2),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BgPainter oldDelegate) => true;
}
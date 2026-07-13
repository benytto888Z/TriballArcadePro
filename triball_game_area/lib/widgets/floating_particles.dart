// lib/widgets/floating_particles.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/theme_colors.dart';

/// Particules néon flottantes en arrière-plan (effet ambiance).
class FloatingParticles extends StatefulWidget {
  final int count;

  const FloatingParticles({super.key, this.count = 25});

  @override
  State<FloatingParticles> createState() => _FloatingParticlesState();
}

class _FloatingParticlesState extends State<FloatingParticles>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _rand = Random();
  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _particles = List.generate(widget.count, (_) {
      return _Particle(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        size: _rand.nextDouble() * 4 + 1,
        speed: _rand.nextDouble() * 0.3 + 0.1,
        opacity: _rand.nextDouble() * 0.5 + 0.2,
        useSecondary: _rand.nextBool(),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: Size.infinite,
            painter: _ParticlesPainter(
              particles: _particles,
              progress: _controller.value,
              primary: ThemeColors.primary,
              secondary: ThemeColors.secondary,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  final double x, y, size, speed, opacity;
  final bool useSecondary;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.useSecondary,
  });
}

class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color primary;
  final Color secondary;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.primary,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final y = ((p.y + progress * p.speed) % 1.0) * size.height;
      final x = p.x * size.width + sin(progress * 2 * pi + p.y * 10) * 15;
      paint.color =
          (p.useSecondary ? secondary : primary).withOpacity(p.opacity);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) => true;
}
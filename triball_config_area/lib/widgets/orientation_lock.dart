// lib/widgets/orientation_lock.dart

import 'package:flutter/material.dart';
import '../core/values/color_values.dart';

class OrientationLock extends StatefulWidget {
  final Widget child;
  final Orientation expectedOrientation;

  const OrientationLock({
    super.key,
    required this.child,
    required this.expectedOrientation,
  });

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  // ✅ NEW : Délai avant d'afficher le message de rotation
  bool _showRotateMessage = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final actualOrientation = constraints.maxHeight > constraints.maxWidth
          ? Orientation.portrait
          : Orientation.landscape;

      if (actualOrientation != widget.expectedOrientation) {
        // ✅ Délai de 1.5s avant d'afficher "Please rotate"
        //    pour laisser le temps à la rotation auto de se faire
        if (!_showRotateMessage) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              // Re-check orientation
              final size = MediaQuery.of(context).size;
              final stillBad = (size.height > size.width
                  ? Orientation.portrait
                  : Orientation.landscape) !=
                  widget.expectedOrientation;
              if (stillBad) {
                setState(() => _showRotateMessage = true);
              }
            }
          });
        }

        // Pendant les 1.5 premières secondes, écran noir simple
        if (!_showRotateMessage) {
          return Container(color: ColorValues.neonBgDark);
        }

        return _RotateScreen(target: widget.expectedOrientation);
      }

      // ✅ Reset le flag quand l'orientation est OK
      if (_showRotateMessage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _showRotateMessage = false);
          }
        });
      }

      return widget.child;
    });
  }
}

class _RotateScreen extends StatelessWidget {
  final Orientation target;

  const _RotateScreen({required this.target});

  @override
  Widget build(BuildContext context) {
    final isTargetLandscape = target == Orientation.landscape;
    return Material(
      color: ColorValues.neonBgDark,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              builder: (context, t, _) {
                return Transform.rotate(
                  angle: t * 1.5708,
                  child: Icon(
                    isTargetLandscape
                        ? Icons.screen_rotation
                        : Icons.screen_lock_portrait,
                    color: ColorValues.neonCyan,
                    size: 80,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              isTargetLandscape
                  ? 'PLEASE ROTATE TO LANDSCAPE'
                  : 'PLEASE ROTATE TO PORTRAIT',
              style: const TextStyle(
                fontFamily: 'Orbitron',
                color: ColorValues.neonCyan,
                fontSize: 16,
                letterSpacing: 3,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(color: ColorValues.neonCyan, blurRadius: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
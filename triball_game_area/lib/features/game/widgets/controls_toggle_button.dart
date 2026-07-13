// lib/features/game/widgets/controls_toggle_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../game_controller.dart';

/// Bouton flottant en bas-gauche pour afficher/masquer les contrôles du jeu
class ControlsToggleButton extends GetView<GameController> {
  const ControlsToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
      return const SizedBox.shrink();
    }
}
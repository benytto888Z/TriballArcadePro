// lib/features/game/widgets/game_controls_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/game_constants.dart';
import '../../../core/theme/theme_colors.dart';
import '../game_controller.dart';

class GameControlsBar extends GetView<GameController> {
  const GameControlsBar({super.key});

  @override
  Widget build(BuildContext context) {
     return const SizedBox.shrink();
  }
}

class _AnimatedControlsPanel extends StatefulWidget {
  @override
  State<_AnimatedControlsPanel> createState() => _AnimatedControlsPanelState();
}

class _AnimatedControlsPanelState extends State<_AnimatedControlsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _slide = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameController>();

    final canPause = controller.isPlaying;
    final canResume = controller.isPaused;
    final canShowNext = controller.isMultiMode && controller.isPlaying;

    final buttons = <Widget>[];

    if (canPause) {
      buttons.add(_ControlButton(
        icon: Icons.pause,
        label: 'pause'.tr,
        color: ThemeColors.warning,
        onTap: () {
          controller.pauseGame();
          controller.hideControls();
        },
      ));
    }
    if (canResume) {
      buttons.add(_ControlButton(
        icon: Icons.play_arrow,
        label: 'resume'.tr,
        color: ThemeColors.success,
        onTap: () {
          controller.resumeGame();
          controller.hideControls();
        },
      ));
    }
    if (canShowNext) {
      buttons.add(_ControlButton(
        icon: Icons.skip_next,
        label: 'next_player'.tr,
        color: ThemeColors.accent,
        isPrimary: true,
        onTap: () {
          controller.nextPlayer();
          controller.hideControls();
        },
      ));
    }
    buttons.add(_ControlButton(
      icon: Icons.refresh,
      label: 'restart'.tr,
      color: ThemeColors.secondary,
      onTap: () {
        controller.restartGame();
        controller.hideControls();
      },
    ));
    buttons.add(_ControlButton(
      icon: Icons.exit_to_app,
      label: 'quit'.tr,
      color: ThemeColors.error,
      onTap: () => _confirmQuit(controller),
    ));

    // ✅ Largeur disponible = largeur écran - marges (16 left + 16 right + 70 pour le bouton toggle)
    final screenWidth = MediaQuery.of(context).size.width;
    final maxPanelWidth = screenWidth - 32.w - 60.w;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ConstrainedBox(
          // ✅ Limite la largeur max du panel
          constraints: BoxConstraints(maxWidth: maxPanelWidth),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: ThemeColors.surface.withOpacity(0.95),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ThemeColors.primary.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: ThemeColors.useGlow
                  ? [
                BoxShadow(
                  color: ThemeColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ]
                  : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // ✅ SingleChildScrollView avec scrollDirection horizontal
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: buttons
                    .expand((btn) => [btn, SizedBox(width: 8.w)])
                    .toList()
                  ..removeLast(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmQuit(GameController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Text(
          'quit_game'.tr,
          style: TextStyle(color: ThemeColors.primary),
        ),
        content: Text('quit_confirm'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.hideControls();
              controller.quitGame();
            },
            child: Text(
              'yes'.tr,
              style: TextStyle(color: ThemeColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CONTROL BUTTON
// ============================================================
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isPrimary;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isPrimary ? 14.w : 10.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(isPrimary ? 0.25 : 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color,
            width: isPrimary ? 2 : 1.5,
          ),
          boxShadow: isPrimary && ThemeColors.useGlow
              ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 12)]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16.sp),
            SizedBox(width: 5.w),
            Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                fontFamily: GameConstants.gameFontFamily,
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
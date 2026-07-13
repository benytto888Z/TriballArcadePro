// triball_config_area/lib/widgets/game_area_status_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/controllers/config_broadcaster_controller.dart';
import '../core/controllers/websocket_controller.dart';
import '../core/theme/theme_colors.dart';

/// Indicateur de statut montrant :
/// - Connexion ESP32 (plateforme)
/// - Connexion Game Area (TV)
class GameAreaStatusIndicator extends StatelessWidget {
  final bool showLabel;
  final bool compact;
  final VoidCallback? onTap;

  const GameAreaStatusIndicator({
    super.key,
    this.showLabel = true,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ws = Get.find<WebSocketController>();
    final broadcaster = Get.find<ConfigBroadcasterController>();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Obx(() {
        final espConnected = ws.isConnected;
        final espDeclared = ws.isDeclared.value;
        final gameAreaCount = broadcaster.gameAreaCount.value;
        final hasGameArea = gameAreaCount > 0;

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10.w : 16.w,
            vertical: compact ? 6.h : 10.h,
          ),
          decoration: BoxDecoration(
            color: ThemeColors.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _borderColor(espConnected, hasGameArea),
              width: 1.5,
            ),
            boxShadow: ThemeColors.useGlow
                ? [
              BoxShadow(
                color: _borderColor(espConnected, hasGameArea)
                    .withOpacity(0.3),
                blurRadius: 10,
              ),
            ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== ESP32 STATUS =====
              _StatusRow(
                icon: Icons.router,
                label: 'platform'.tr,
                isConnected: espConnected,
                statusText: espConnected
                    ? (espDeclared ? 'connected'.tr : 'connecting'.tr)
                    : 'disconnected'.tr,
                color: espConnected
                    ? ThemeColors.success
                    : ThemeColors.error,
                compact: compact,
              ),

              if (showLabel) ...[
                SizedBox(height: compact ? 4.h : 8.h),

                // ===== GAME AREA STATUS =====
                _StatusRow(
                  icon: Icons.tv,
                  label: 'game_area_label'.tr,
                  isConnected: hasGameArea,
                  statusText: hasGameArea
                      ? '$gameAreaCount ${'connected'.tr.toLowerCase()}'
                      : 'waiting_for_game_area'.tr,
                  color: hasGameArea
                      ? ThemeColors.success
                      : ThemeColors.warning,
                  compact: compact,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Color _borderColor(bool espConnected, bool hasGameArea) {
    if (!espConnected) return ThemeColors.error;
    if (!hasGameArea) return ThemeColors.warning;
    return ThemeColors.success;
  }
}

// ============================================================
// STATUS ROW
// ============================================================
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isConnected;
  final String statusText;
  final Color color;
  final bool compact;

  const _StatusRow({
    required this.icon,
    required this.label,
    required this.isConnected,
    required this.statusText,
    required this.color,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot pulsant
        _PulsingDot(color: color, size: compact ? 8 : 10),
        SizedBox(width: 8.w),
        // Icon
        Icon(icon, color: color, size: compact ? 14.sp : 16.sp),
        SizedBox(width: 6.w),
        // Label + status
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: compact ? 8.sp : 9.sp,
                fontWeight: FontWeight.w700,
                color: ThemeColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              statusText,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: compact ? 10.sp : 11.sp,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// PULSING DOT
// ============================================================
class _PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const _PulsingDot({required this.color, required this.size});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_anim.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(_anim.value * 0.6),
                blurRadius: widget.size * _anim.value,
              ),
            ],
          ),
        );
      },
    );
  }
}
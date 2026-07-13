// lib/widgets/connection_indicator.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../core/controllers/websocket_controller.dart';
import '../core/services/ websocket_service.dart';
import '../core/theme/theme_colors.dart';
import 'glow_container.dart';

enum ConnectionIndicatorSize { small, medium, large }

/// Widget réutilisable qui affiche le statut de connexion à la Platform.
/// Réactif via GetX : se met à jour automatiquement.
class ConnectionIndicator extends StatelessWidget {
  final ConnectionIndicatorSize size;
  final bool showLabel;
  final bool showPing;
  final VoidCallback? onTap;

  const ConnectionIndicator({
    super.key,
    this.size = ConnectionIndicatorSize.medium,
    this.showLabel = true,
    this.showPing = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WebSocketController>();
    final dotSize = _dotSize();
    final fontSize = _fontSize();

    return Obx(() {
      final state = controller.connectionState.value;
      final color = _color(state);

      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8.w,
            vertical: 4.h,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dot avec glow
              GlowContainer(
                glowColor: color,
                blurRadius: 10,
                padding: EdgeInsets.all(2.r),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: dotSize,
                  height: dotSize,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Label
              if (showLabel) ...[
                SizedBox(width: 6.w),
                Text(
                  '${'platform'.tr}: ${_label(state)}',
                  style: TextStyle(
                    fontFamily: ThemeColors.fontPrimary,
                    color: color,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ],

              // Ping latency
              if (showPing && controller.isConnected) ...[
                SizedBox(width: 8.w),
                Obx(() => Text(
                  '${controller.pingLatencyMs.value}ms',
                  style: TextStyle(
                    fontFamily: ThemeColors.fontPrimary,
                    color: ThemeColors.textSecondary,
                    fontSize: fontSize * 0.85,
                  ),
                )),
              ],
            ],
          ),
        ),
      );
    });
  }

  double _dotSize() {
    switch (size) {
      case ConnectionIndicatorSize.small: return 8.r;
      case ConnectionIndicatorSize.medium: return 10.r;
      case ConnectionIndicatorSize.large: return 14.r;
    }
  }

  double _fontSize() {
    switch (size) {
      case ConnectionIndicatorSize.small: return 10.sp;
      case ConnectionIndicatorSize.medium: return 12.sp;
      case ConnectionIndicatorSize.large: return 16.sp;
    }
  }

  String _label(WsConnectionState s) {
    switch (s) {
      case WsConnectionState.connected:    return 'connected'.tr;
      case WsConnectionState.connecting:   return 'connecting'.tr;
      case WsConnectionState.reconnecting: return 'reconnecting'.tr;
      case WsConnectionState.error:        return 'error'.tr;
      case WsConnectionState.disconnected: return 'disconnected'.tr;
    }
  }

  Color _color(WsConnectionState s) {
    switch (s) {
      case WsConnectionState.connected:    return ThemeColors.success;
      case WsConnectionState.connecting:
      case WsConnectionState.reconnecting: return ThemeColors.warning;
      case WsConnectionState.error:
      case WsConnectionState.disconnected: return ThemeColors.error;
    }
  }
}
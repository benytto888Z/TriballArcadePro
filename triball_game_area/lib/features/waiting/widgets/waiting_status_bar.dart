// triball_game_area/lib/features/waiting/widgets/waiting_status_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/theme/theme_colors.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../waiting_controller.dart';

class WaitingStatusBar extends GetView<WaitingController> {
  const WaitingStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.waitingStatusBarPaddingH(),
        vertical: GameScreenBreakpoints.waitingStatusBarPaddingV(),
      ),
      decoration: BoxDecoration(
        color: ThemeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
      ),
      child: Obx(() {
        final esp = controller.espConnected.value;
        final config = controller.configAreaConnected.value;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _StatusItem(
              icon: Icons.router,
              label: 'platform'.tr,
              isConnected: esp,
            ),
            Container(
              width: 1,
              height: GameScreenBreakpoints.statsPanelDividerHeight(),
              color: ThemeColors.primary.withOpacity(0.2),
            ),
            _StatusItem(
              icon: Icons.tablet_android,
              label: 'config_area_label'.tr,
              isConnected: config,
            ),
            Container(
              width: 1,
              height: GameScreenBreakpoints.statsPanelDividerHeight(),
              color: ThemeColors.primary.withOpacity(0.2),
            ),
            _ClockWidget(),
          ],
        );
      }),
    );
  }
}

class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isConnected;

  const _StatusItem({
    required this.icon,
    required this.label,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final color = isConnected ? ThemeColors.success : ThemeColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.6), blurRadius: 8),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Icon(
          icon,
          color: color,
          size: GameScreenBreakpoints.waitingStatusIconSize(),
        ),
        SizedBox(width: 8.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.waitingStatusLabelSize(),
                fontWeight: FontWeight.w700,
                color: ThemeColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              isConnected ? 'connected'.tr : 'disconnected'.tr,
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: GameScreenBreakpoints.waitingStatusValueSize(),
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClockWidget extends StatefulWidget {
  @override
  State<_ClockWidget> createState() => _ClockWidgetState();
}

class _ClockWidgetState extends State<_ClockWidget> {
  String _time = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    Stream.periodic(const Duration(seconds: 1)).listen((_) {
      if (mounted) _updateTime();
    });
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _time =
      '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _time,
      style: TextStyle(
        fontFamily: 'Orbitron',
        fontSize: GameScreenBreakpoints.waitingClockFontSize(),
        fontWeight: FontWeight.w900,
        color: ThemeColors.primary,
        letterSpacing: 3,
        shadows: ThemeColors.useGlow
            ? [Shadow(color: ThemeColors.primary, blurRadius: 12)]
            : null,
      ),
    );
  }
}
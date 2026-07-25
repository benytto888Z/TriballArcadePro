import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../core/constants/game_constants.dart';
import '../core/controllers/config_broadcaster_controller.dart';
import '../core/services/game_session_guard_service.dart';
import '../core/theme/app_theme_controller.dart';
import '../core/theme/theme_colors.dart';
import 'animated_triball_background.dart';

/// Écran de sécurité plein écran de Config Area.
/// Il remplace visuellement et interactivement toute l'application pendant
/// une partie, tout en restant synchronisé avec le thème actif.
class FuturisticConfigAreaLockOverlay extends StatelessWidget {
  final Widget child;
  const FuturisticConfigAreaLockOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final guard = Get.find<GameSessionGuardService>();
    final broadcaster = Get.find<ConfigBroadcasterController>();
    final theme = Get.find<AppThemeController>();

    return Obx(() {
      // Lecture explicite afin de reconstruire l'écran lors d'un changement
      // Neon / Esports / Carnival effectué par l'administrateur.
      final themeMode = theme.currentTheme.value;
      if (!guard.isLocked) return child;

      final status = broadcaster.remoteGameStatus.value;
      return Scaffold(
        backgroundColor: ThemeColors.backgroundDeep,
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedTriballBackground(
                opacity: themeMode == AppThemeMode.carnival ? 0.30 : 0.48,
                speedFactor: themeMode == AppThemeMode.esports ? 1.25 : 0.9,
              ),
            ),
            Positioned.fill(child: _ThemeAtmosphere(mode: themeMode)),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth >= 720;
                  final maxWidth = wide ? 760.0 : 520.0;
                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 36.w : 20.w,
                        vertical: 24.h,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: _SecurityConsole(
                          mode: themeMode,
                          state: status?.state ?? guard.remoteState.value,
                          player: status?.currentPlayerName,
                          elapsed: status?.elapsedFormatted ?? '--:--',
                          scores: status?.scores ?? const {},
                          onAdminUnlock: () => _showAdminDialog(guard),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _showAdminDialog(GameSessionGuardService guard) async {
    final codeController = TextEditingController();
    await Get.dialog<void>(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
          side: BorderSide(color: ThemeColors.primary, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: ThemeColors.warning),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'admin_access'.tr,
                style: TextStyle(
                  fontFamily: ThemeColors.fontPrimary,
                  color: ThemeColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        content: TextField(
          controller: codeController,
          autofocus: true,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: ThemeColors.fontDisplay,
            color: ThemeColors.primary,
            fontSize: 24,
            letterSpacing: 10,
          ),
          decoration: InputDecoration(
            labelText: 'enter_admin_code'.tr,
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ThemeColors.primary.withOpacity(.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ThemeColors.warning, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: Text('cancel'.tr)),
          ElevatedButton.icon(
            onPressed: () {
              final ok = guard.verifyAndGrantAdmin(
                codeController.text,
                GameConstants.adminSecurityCode,
              );
              if (ok) {
                Get.back();
              } else {
                Get.snackbar('error'.tr, 'invalid_security_code'.tr);
              }
            },
            icon: const Icon(Icons.lock_open),
            label: Text('unlock_admin'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    codeController.dispose();
  }
}

class _ThemeAtmosphere extends StatelessWidget {
  final AppThemeMode mode;
  const _ThemeAtmosphere({required this.mode});

  @override
  Widget build(BuildContext context) {
    final colors = switch (mode) {
      AppThemeMode.neon => [
          const Color(0xE605071A),
          const Color(0xB30A0E27),
          const Color(0xB305071A),
        ],
      AppThemeMode.esports => [
          const Color(0xED0F0F1F),
          const Color(0xC71A1A2E),
          const Color(0xE60F0F1F),
        ],
      AppThemeMode.carnival => [
          const Color(0xEFFFF8E7),
          const Color(0xCFFFF0CA),
          const Color(0xEFFFF8E7),
        ],
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
    );
  }
}

class _SecurityConsole extends StatelessWidget {
  final AppThemeMode mode;
  final String state;
  final String? player;
  final String elapsed;
  final Map<String, int> scores;
  final VoidCallback onAdminUnlock;

  const _SecurityConsole({
    required this.mode,
    required this.state,
    required this.player,
    required this.elapsed,
    required this.scores,
    required this.onAdminUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final carnival = mode == AppThemeMode.carnival;
    final panelColor = ThemeColors.surface.withOpacity(carnival ? .94 : .82);
    final glow = ThemeColors.useGlow
        ? [
            BoxShadow(
              color: ThemeColors.primary.withOpacity(.42),
              blurRadius: 36,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: ThemeColors.secondary.withOpacity(.22),
              blurRadius: 70,
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withOpacity(carnival ? .16 : .48),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
        border: Border.all(color: ThemeColors.primary, width: 2),
        boxShadow: glow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedLockEmblem(mode: mode),
          SizedBox(height: 16.h),
          Text(
            'session_locked_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ThemeColors.fontDisplay,
              fontSize: 25.sp,
              fontWeight: FontWeight.w900,
              color: ThemeColors.primary,
              letterSpacing: ThemeColors.letterSpacing + 1,
              shadows: ThemeColors.useGlow
                  ? [Shadow(color: ThemeColors.primary, blurRadius: 18)]
                  : null,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'session_locked_message'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: ThemeColors.fontBody,
              fontSize: 12.sp,
              color: ThemeColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          _LiveStatusCard(
            state: state,
            player: player,
            elapsed: elapsed,
            scores: scores,
          ),
          SizedBox(height: 22.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAdminUnlock,
              icon: const Icon(Icons.admin_panel_settings),
              label: Text('admin_unlock'.tr.toUpperCase()),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeColors.warning,
                foregroundColor: carnival ? Colors.black87 : Colors.black,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ThemeColors.cornerRadius),
                ),
                textStyle: TextStyle(
                  fontFamily: ThemeColors.fontPrimary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shield_outlined, color: ThemeColors.success, size: 16.sp),
              SizedBox(width: 7.w),
              Flexible(
                child: Text(
                  'ADMIN • SECURE SESSION • ${mode.name.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: ThemeColors.fontPrimary,
                    fontSize: 8.5.sp,
                    color: ThemeColors.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnimatedLockEmblem extends StatefulWidget {
  final AppThemeMode mode;
  const _AnimatedLockEmblem({required this.mode});

  @override
  State<_AnimatedLockEmblem> createState() => _AnimatedLockEmblemState();
}

class _AnimatedLockEmblemState extends State<_AnimatedLockEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final scale = .94 + (_controller.value * .08);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 86.w,
            height: 86.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [ThemeColors.primary, ThemeColors.secondary],
              ),
              boxShadow: [
                BoxShadow(
                  color: ThemeColors.primary.withOpacity(.45),
                  blurRadius: 18 + _controller.value * 18,
                  spreadRadius: _controller.value * 3,
                ),
              ],
            ),
            child: Icon(Icons.lock, color: Colors.black, size: 43.sp),
          ),
        );
      },
    );
  }
}

class _LiveStatusCard extends StatelessWidget {
  final String state;
  final String? player;
  final String elapsed;
  final Map<String, int> scores;

  const _LiveStatusCard({
    required this.state,
    required this.player,
    required this.elapsed,
    required this.scores,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ThemeColors.primary.withOpacity(.13),
            ThemeColors.secondary.withOpacity(.08),
          ],
        ),
        borderRadius: BorderRadius.circular(ThemeColors.cornerRadiusLarge),
        border: Border.all(color: ThemeColors.primary.withOpacity(.45)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PulsingStatusDot(),
              SizedBox(width: 9.w),
              Text(
                state.toUpperCase(),
                style: TextStyle(
                  fontFamily: ThemeColors.fontPrimary,
                  color: ThemeColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13.sp,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          if (player != null) ...[
            SizedBox(height: 12.h),
            Text(
              player!.toUpperCase(),
              style: TextStyle(
                fontFamily: ThemeColors.fontDisplay,
                color: ThemeColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            elapsed,
            style: TextStyle(
              fontFamily: ThemeColors.fontDisplay,
              color: ThemeColors.warning,
              fontSize: 24.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          if (scores.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.w,
              runSpacing: 8.h,
              children: scores.entries.map((entry) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ThemeColors.background.withOpacity(.58),
                    borderRadius: BorderRadius.circular(ThemeColors.cornerRadius),
                  ),
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: TextStyle(
                      fontFamily: ThemeColors.fontPrimary,
                      color: ThemeColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 10.sp,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _PulsingStatusDot extends StatefulWidget {
  @override
  State<_PulsingStatusDot> createState() => _PulsingStatusDotState();
}

class _PulsingStatusDotState extends State<_PulsingStatusDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .35, end: 1).animate(_controller),
      child: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: ThemeColors.success,
          boxShadow: [BoxShadow(color: ThemeColors.success, blurRadius: 10)],
        ),
      ),
    );
  }
}

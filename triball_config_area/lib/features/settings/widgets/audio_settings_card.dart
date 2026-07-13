// lib/features/settings/widgets/audio_settings_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class AudioSettingsCard extends StatelessWidget {
  const AudioSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioService>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.volume_up, color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('audio_settings'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== SFX TOGGLE + VOLUME =====
          Obx(() => _ToggleRow(
            icon: Icons.music_note,
            label: 'sound_effects'.tr,
            value: audio.soundEnabled.value,
            onChanged: (_) => audio.toggleSound(),
          )),
          Obx(() {
            if (!audio.soundEnabled.value) return const SizedBox.shrink();
            return _SliderRow(
              icon: Icons.tune,
              label: 'sfx_volume'.tr,
              value: audio.sfxVolume.value,
              displayValue: '${(audio.sfxVolume.value * 100).round()}%',
              onChanged: (v) => audio.setSfxVolume(v),
            );
          }),

          _SubDivider(),

          // ===== BGM TOGGLE + VOLUME =====
          Obx(() => _ToggleRow(
            icon: Icons.queue_music,
            label: 'background_music'.tr,
            value: audio.musicEnabled.value,
            onChanged: (_) => audio.toggleMusic(),
          )),
          Obx(() {
            if (!audio.musicEnabled.value) return const SizedBox.shrink();
            return _SliderRow(
              icon: Icons.tune,
              label: 'music_volume'.tr,
              value: audio.musicVolume.value,
              displayValue: '${(audio.musicVolume.value * 100).round()}%',
              onChanged: (v) => audio.setMusicVolume(v),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// TOGGLE ROW
// ============================================================
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.primary, size: 16.h),
          SizedBox(width: 10.w),
          Expanded(
            child: ThemedText.body(label, fontSize: 13.h),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: ThemeColors.primary,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SLIDER ROW
// ============================================================
class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 28.w, top: 2.h, bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.textSecondary, size: 12.h),
          SizedBox(width: 6.w),
          SizedBox(
            width: 90.w,
            child: ThemedText.caption(
              label,
              fontSize: 11.h,
              color: ThemeColors.textSecondary,
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14),
              ),
              child: Slider(
                value: value,
                min: 0,
                max: 1,
                onChanged: onChanged,
                activeColor: ThemeColors.primary,
                inactiveColor: ThemeColors.primary.withOpacity(0.2),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          SizedBox(
            width: 40.w,
            child: Text(
              displayValue,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontFamily: ThemeColors.fontPrimary,
                fontSize: 11.h,
                color: ThemeColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Divider(
        height: 1,
        color: ThemeColors.primary.withOpacity(0.15),
      ),
    );
  }
}
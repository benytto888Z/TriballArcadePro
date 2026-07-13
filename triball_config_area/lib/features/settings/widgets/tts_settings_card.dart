// lib/features/settings/widgets/tts_settings_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../widgets/themed_card.dart';
import '../../../widgets/themed_text.dart';

class TtsSettingsCard extends StatelessWidget {
  const TtsSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();

    return ThemedCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(Icons.record_voice_over,
                  color: ThemeColors.primary, size: 22.h),
              SizedBox(width: 10.w),
              ThemedText.title('voice_announcements'.tr, fontSize: 16.h),
            ],
          ),
          SizedBox(height: 14.h),

          // ===== ENABLE TOGGLE =====
          Obx(() => Row(
            children: [
              Icon(Icons.mic, color: ThemeColors.primary, size: 16.h),
              SizedBox(width: 10.w),
              Expanded(
                child: ThemedText.body(
                  'voice_enabled'.tr,
                  fontSize: 13.h,
                ),
              ),
              Switch(
                value: tts.ttsEnabled.value,
                onChanged: (_) => tts.toggleTts(),
                activeColor: ThemeColors.primary,
              ),
            ],
          )),

          Obx(() {
            if (!tts.ttsEnabled.value) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),

                // ===== VOLUME =====
                _SliderRow(
                  icon: Icons.volume_up,
                  label: 'voice_volume'.tr,
                  value: tts.volume.value,
                  min: 0,
                  max: 1,
                  displayValue: '${(tts.volume.value * 100).round()}%',
                  onChanged: (v) => tts.setVolume(v),
                ),

                // ===== PITCH =====
                _SliderRow(
                  icon: Icons.graphic_eq,
                  label: 'voice_pitch'.tr,
                  value: tts.pitch.value,
                  min: 0.5,
                  max: 2.0,
                  displayValue: tts.pitch.value.toStringAsFixed(1),
                  onChanged: (v) => tts.setPitch(v),
                ),

                // ===== RATE =====
                _SliderRow(
                  icon: Icons.speed,
                  label: 'voice_speed'.tr,
                  value: tts.rate.value,
                  min: 0.1,
                  max: 1.0,
                  displayValue: tts.rate.value.toStringAsFixed(1),
                  onChanged: (v) => tts.setRate(v),
                ),

                SizedBox(height: 12.h),

                // ===== VOICE SELECTOR =====
                _VoiceSelector(),

                SizedBox(height: 12.h),

                // ===== TEST BUTTON =====
                _TestVoiceButton(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================
// VOICE SELECTOR
// ============================================================
class _VoiceSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();

    return Obx(() {
      final voices = tts.availableVoices.toList();
      final selected = tts.selectedVoice.value;

      // ✅ Pas de voix → message
      if (voices.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Icon(Icons.info_outline,
                  color: ThemeColors.textSecondary, size: 14.h),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedText.caption(
                  'no_voices_available'.tr,
                  fontSize: 11.h,
                  color: ThemeColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      // ✅ Détermine la value courante de manière SÉCURISÉE
      //    Vérifie que la voix sélectionnée existe TOUJOURS dans la liste
      String? currentValue;
      if (selected != null &&
          voices.any((v) => v.name == selected.name)) {
        currentValue = selected.name;
      } else {
        // Fallback : première voix de la liste
        currentValue = voices.first.name;
        // Auto-sélectionne la première voix au changement de langue
        WidgetsBinding.instance.addPostFrameCallback((_) {
          tts.setVoice(voices.first);
        });
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: ThemeColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: ThemeColors.primary, size: 16.h),
            SizedBox(width: 10.w),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  // ✅ KEY : reconstruit le dropdown quand la liste change
                  key: ValueKey('voice_dropdown_${voices.length}_$currentValue'),
                  value: currentValue,
                  dropdownColor: ThemeColors.surface,
                  style: TextStyle(
                    fontFamily: ThemeColors.fontBody,
                    fontSize: 12.h,
                    color: ThemeColors.textPrimary,
                  ),
                  icon: Icon(Icons.arrow_drop_down,
                      color: ThemeColors.primary, size: 18.h),
                  items: voices.map((voice) {
                    return DropdownMenuItem<String>(
                      value: voice.name,
                      child: Text(
                        voice.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(fontSize: 12.h),
                      ),
                    );
                  }).toList(),
                  onChanged: (name) {
                    if (name == null) return;
                    final voice = voices.firstWhereOrNull(
                          (v) => v.name == name,
                    );
                    if (voice != null) tts.setVoice(voice);
                  },
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}


// ============================================================
// TEST VOICE BUTTON
// ============================================================
class _TestVoiceButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tts = Get.find<TtsService>();

    return Center(
      child: Obx(() {
        final isSpeaking = tts.isSpeaking.value;
        return InkWell(
          onTap: () {
            if (isSpeaking) {
              tts.stop();
            } else {
              tts.speakTest();
            }
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
            decoration: BoxDecoration(
              color: isSpeaking
                  ? ThemeColors.error.withOpacity(0.2)
                  : ThemeColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSpeaking ? ThemeColors.error : ThemeColors.primary,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSpeaking ? Icons.stop : Icons.play_arrow,
                  color:
                  isSpeaking ? ThemeColors.error : ThemeColors.primary,
                  size: 18.h,
                ),
                SizedBox(width: 6.w),
                Text(
                  (isSpeaking ? 'stop'.tr : 'test_voice'.tr).toUpperCase(),
                  style: TextStyle(
                    fontFamily: ThemeColors.fontPrimary,
                    fontSize: 12.h,
                    fontWeight: FontWeight.w700,
                    color: isSpeaking
                        ? ThemeColors.error
                        : ThemeColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

// ============================================================
// SLIDER ROW (reusable)
// ============================================================
class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.textSecondary, size: 14.h),
          SizedBox(width: 8.w),
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
                min: min,
                max: max,
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
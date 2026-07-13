// lib/features/how_to_play/how_to_play_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/services/audio_service.dart';
import '../../data/models/guide_section_model.dart';

class HowToPlayController extends GetxController {
  final AudioService _audio = Get.find<AudioService>();

  // ============================================
  // OBSERVABLES
  // ============================================
  final Rx<GuideCategory> selectedCategory = GuideCategory.basics.obs;
  final RxInt expandedItemIndex = (-1).obs;

  // ============================================
  // GUIDE STRUCTURE (centralisée, évolutive)
  // ============================================
  late final List<GuideSection> sections;

  @override
  void onInit() {
    super.onInit();
    _buildSections();
  }

  void _buildSections() {
    sections = [
      // ============================================
      // BASICS — Bases du jeu
      // ============================================
      GuideSection(
        category: GuideCategory.basics,
        items: [
          GuideItem(
            titleKey: 'guide_basics_objective_title',
            descriptionKey: 'guide_basics_objective_desc',
            icon: Icons.gps_fixed,
            accentColor: Colors.cyan,
          ),
          GuideItem(
            titleKey: 'guide_basics_turn_title',
            descriptionKey: 'guide_basics_turn_desc',
            icon: Icons.refresh,
            accentColor: Colors.amber,
            bulletPointKeys: [
              'guide_basics_turn_bullet_1',
              'guide_basics_turn_bullet_2',
              'guide_basics_turn_bullet_3',
            ],
          ),
          GuideItem(
            titleKey: 'guide_basics_winning_title',
            descriptionKey: 'guide_basics_winning_desc',
            icon: Icons.emoji_events,
            accentColor: Colors.green,
          ),
        ],
      ),

      // ============================================
      // SCORING — Système de points
      // ============================================
      GuideSection(
        category: GuideCategory.scoring,
        items: [
          GuideItem(
            titleKey: 'guide_scoring_holes_title',
            descriptionKey: 'guide_scoring_holes_desc',
            icon: Icons.grid_3x3,
            customWidget: const _HoleGridDemoSlot(),
          ),
          GuideItem(
            titleKey: 'guide_scoring_special_title',
            descriptionKey: 'guide_scoring_special_desc',
            icon: Icons.star,
            accentColor: Colors.yellow,
            bulletPointKeys: [
              'guide_scoring_x0_bullet',
              'guide_scoring_x2_bullet',
              'guide_scoring_jackpot_bullet',
            ],
          ),
          GuideItem(
            titleKey: 'guide_scoring_overshoot_title',
            descriptionKey: 'guide_scoring_overshoot_desc',
            icon: Icons.block,
            accentColor: Colors.red,
          ),
        ],
      ),

      // ============================================
      // MODES — Modes de jeu
      // ============================================
      GuideSection(
        category: GuideCategory.modes,
        items: [
          GuideItem(
            titleKey: 'mode_classic',
            descriptionKey: 'mode_classic_desc',
            icon: Icons.flag,
            accentColor: Colors.cyan,
          ),
          GuideItem(
            titleKey: 'mode_solo_chrono',
            descriptionKey: 'mode_solo_chrono_desc',
            icon: Icons.timer,
            accentColor: Colors.amber,
          ),
          GuideItem(
            titleKey: 'mode_tournament',
            descriptionKey: 'mode_tournament_desc',
            icon: Icons.emoji_events,
            accentColor: Colors.purple,
          ),
          GuideItem(
            titleKey: 'mode_hardcore',
            descriptionKey: 'guide_hardcore_new_rule',    // ✅ Nouvelle description enrichie
            icon: Icons.local_fire_department,
            accentColor: Colors.red,
          ),
          GuideItem(
            titleKey: 'mode_combo',
            descriptionKey: 'mode_combo_desc',
            icon: Icons.bolt,
            accentColor: Colors.pink,
          ),
          GuideItem(
            titleKey: 'mode_champion',
            descriptionKey: 'mode_champion_desc',
            icon: Icons.workspace_premium,
            accentColor: Colors.orange,
          ),
        ],
      ),

      // ============================================
      // COMBOS — Combos & bonus
      // ============================================
      GuideSection(
        category: GuideCategory.combos,
        items: [
          GuideItem(
            titleKey: 'combo_double',
            descriptionKey: 'guide_combo_double_desc',
            icon: Icons.flash_on,
            accentColor: Colors.cyan,
          ),
          GuideItem(
            titleKey: 'combo_triple',
            descriptionKey: 'guide_combo_triple_desc',
            icon: Icons.flash_on,
            accentColor: Colors.orange,
          ),

          GuideItem(
            titleKey: 'combo_streak',
            descriptionKey: 'guide_combo_streak_desc',
            icon: Icons.trending_up,
            accentColor: Colors.green,
          ),

        ],
      ),

      // ============================================
      // CONTROLS — Contrôles
      // ============================================
      GuideSection(
        category: GuideCategory.controls,
        items: [
          GuideItem(
            titleKey: 'guide_controls_pause_title',
            descriptionKey: 'guide_controls_pause_desc',
            icon: Icons.pause,
            accentColor: Colors.amber,
          ),
          GuideItem(
            titleKey: 'guide_controls_next_title',
            descriptionKey: 'guide_controls_next_desc',
            icon: Icons.skip_next,
            accentColor: Colors.purple,
          ),
          GuideItem(
            titleKey: 'guide_controls_restart_title',
            descriptionKey: 'guide_controls_restart_desc',
            icon: Icons.refresh,
            accentColor: Colors.pink,
          ),
          GuideItem(
            titleKey: 'guide_controls_quit_title',
            descriptionKey: 'guide_controls_quit_desc',
            icon: Icons.exit_to_app,
            accentColor: Colors.red,
          ),
        ],
      ),

      // ============================================
      // TIPS — Astuces
      // ============================================
      GuideSection(
        category: GuideCategory.tips,
        items: [
          GuideItem(
            titleKey: 'guide_tip_1_title',
            descriptionKey: 'guide_tip_1_desc',
            icon: Icons.lightbulb,
            accentColor: Colors.yellow,
          ),
          GuideItem(
            titleKey: 'guide_tip_2_title',
            descriptionKey: 'guide_tip_2_desc',
            icon: Icons.psychology,
            accentColor: Colors.green,
          ),
          GuideItem(
            titleKey: 'guide_tip_3_title',
            descriptionKey: 'guide_tip_3_desc',
            icon: Icons.center_focus_strong,
            accentColor: Colors.cyan,
          ),
        ],
      ),

      // ============================================
      // PLATFORM — Plateforme physique
      // ============================================
      GuideSection(
        category: GuideCategory.platform,
        items: [
          GuideItem(
            titleKey: 'guide_platform_setup_title',
            descriptionKey: 'guide_platform_setup_desc',
            icon: Icons.cable,
            accentColor: Colors.cyan,
            bulletPointKeys: [
              'guide_platform_setup_bullet_1',
              'guide_platform_setup_bullet_2',
              'guide_platform_setup_bullet_3',
            ],
          ),
          GuideItem(
            titleKey: 'guide_platform_connection_title',
            descriptionKey: 'guide_platform_connection_desc',
            icon: Icons.wifi,
            accentColor: Colors.green,
          ),
          GuideItem(
            titleKey: 'guide_platform_leds_title',
            descriptionKey: 'guide_platform_leds_desc',
            icon: Icons.lightbulb_outline,
            accentColor: Colors.pink,
          ),
        ],
      ),

      // ============================================
// GAME CENTER — Mode Game Center
// ============================================
      GuideSection(
        category: GuideCategory.platform,
        items: [
          GuideItem(
            titleKey: 'guide_gc_setup_title',
            descriptionKey: 'guide_gc_setup_desc',
            icon: Icons.cast_connected,
            accentColor: Colors.cyan,
            bulletPointKeys: [
              'guide_gc_setup_bullet_1',
              'guide_gc_setup_bullet_2',
              'guide_gc_setup_bullet_3',
              'guide_gc_setup_bullet_4',
            ],
          ),
          GuideItem(
            titleKey: 'guide_gc_config_title',
            descriptionKey: 'guide_gc_config_desc',
            icon: Icons.touch_app,
            accentColor: Colors.green,
            bulletPointKeys: [
              'guide_gc_config_bullet_1',
              'guide_gc_config_bullet_2',
              'guide_gc_config_bullet_3',
            ],
          ),
          GuideItem(
            titleKey: 'guide_gc_play_title',
            descriptionKey: 'guide_gc_play_desc',
            icon: Icons.sports_esports,
            accentColor: Colors.purple,
          ),
          GuideItem(
            titleKey: 'guide_gc_troubleshoot_title',
            descriptionKey: 'guide_gc_troubleshoot_desc',
            icon: Icons.build,
            accentColor: Colors.orange,
            bulletPointKeys: [
              'guide_gc_troubleshoot_bullet_1',
              'guide_gc_troubleshoot_bullet_2',
              'guide_gc_troubleshoot_bullet_3',
            ],
          ),
        ],
      ),

      // ============================================
      // FAQ
      // ============================================
      GuideSection(
        category: GuideCategory.faq,
        items: [
          GuideItem(
            titleKey: 'guide_faq_1_title',
            descriptionKey: 'guide_faq_1_desc',
            icon: Icons.help_outline,
          ),
          GuideItem(
            titleKey: 'guide_faq_2_title',
            descriptionKey: 'guide_faq_2_desc',
            icon: Icons.help_outline,
          ),
          GuideItem(
            titleKey: 'guide_faq_3_title',
            descriptionKey: 'guide_faq_3_desc',
            icon: Icons.help_outline,
          ),
          GuideItem(
            titleKey: 'guide_faq_4_title',
            descriptionKey: 'guide_faq_4_desc',
            icon: Icons.help_outline,
          ),
        ],
      ),
    ];
  }

  // ============================================
  // GETTERS
  // ============================================
  GuideSection get currentSection {
    return sections.firstWhere(
          (s) => s.category == selectedCategory.value,
      orElse: () => sections.first,
    );
  }

  // ============================================
  // ACTIONS
  // ============================================
  void selectCategory(GuideCategory cat) {
    //_audio.playSfx(AssetPaths.audioButtonPress);
    selectedCategory.value = cat;
    expandedItemIndex.value = -1;
  }

  void toggleExpand(int index) {
   // _audio.playSfx(AssetPaths.audioButtonPress);
    if (expandedItemIndex.value == index) {
      expandedItemIndex.value = -1;
    } else {
      expandedItemIndex.value = index;
    }
  }

  void onBackPressed() {
    //_audio.playSfx(AssetPaths.audioButtonPress);
    Get.back();
  }
}

// Placeholder pour le custom widget de la grille
class _HoleGridDemoSlot extends StatelessWidget {
  const _HoleGridDemoSlot();

  @override
  Widget build(BuildContext context) {
    // Affiché via HoleGridDemo widget importé dans le screen
    return const SizedBox.shrink();
  }
}
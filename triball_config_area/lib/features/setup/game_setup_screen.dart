// lib/features/setup/game_setup_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/game_constants.dart';
import '../../core/services/avatar_capture_service.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../widgets/avatar_capture_dialog.dart';
import '../../widgets/floating_particles.dart';
import '../../widgets/orientation_wrappers.dart';
import '../../widgets/themed_card.dart';
import '../../widgets/themed_text.dart';
import '../../widgets/game_mode_card.dart';
import '../../widgets/player_chip.dart';
import '../../widgets/player_count_selector.dart';
import 'game_setup_controller.dart';
import 'widgets/match_type_card.dart';
import 'widgets/page_indicator.dart';
import 'widgets/setup_navigation_bar.dart';

class GameSetupScreen extends GetView<GameSetupController> {
  const GameSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PortraitWrapper(
      child: Scaffold(
        backgroundColor: ThemeColors.backgroundDeep,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: ThemeColors.backgroundGradient,
              ),
            ),
            const FloatingParticles(count: 15),
            SafeArea(
              child: Column(
                children: [
                  const _Header(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: const _StepsIndicator(),
                  ),
                  SizedBox(height: 12.h),
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: controller.onPageChanged,
                      children: const [
                        _MatchTypePage(),
                        _GameModePage(),
                        _PlayersPage(),
                      ],
                    ),
                  ),
                  const SetupNavigationBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================
class _Header extends GetView<GameSetupController> {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: controller.previousPage,
            icon: Icon(Icons.arrow_back,
                color: ThemeColors.primary, size: 26.sp),
          ),
          SizedBox(width: 6.w),
          const Expanded(child: _HeaderTitle()),
          const _PageNumberBadge(),
        ],
      ),
    );
  }
}

class _HeaderTitle extends GetView<GameSetupController> {
  const _HeaderTitle();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final page = controller.currentPage.value;
      String title;
      switch (page) {
        case 0: title = 'match_type'.tr; break;
        case 1: title = 'game_mode'.tr; break;
        case 2: title = 'players'.tr; break;
        default: title = 'game_setup'.tr;
      }
      return ThemedText.headline(
        title.toUpperCase(),
        fontSize: 20.sp,
        withGlow: true,
        color: ThemeColors.primary,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    });
  }
}

class _PageNumberBadge extends GetView<GameSetupController> {
  const _PageNumberBadge();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final current = controller.displayPageNumber;
      final total = controller.displayTotalPages;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ThemeColors.primary.withOpacity(0.4),
          ),
        ),
        child: Text(
          '$current/$total',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: ThemeColors.primary,
            letterSpacing: 1.5,
          ),
        ),
      );
    });
  }
}

class _StepsIndicator extends GetView<GameSetupController> {
  const _StepsIndicator();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final preselected = controller.matchTypePreselected.value;
      final page = controller.currentPage.value;
      final total = controller.displayTotalPages;

      return PageIndicator(
        currentPage: preselected ? page - 1 : page,
        totalPages: total,
        pageTitles: preselected
            ? ['game_mode'.tr, 'players'.tr]
            : ['match_type'.tr, 'game_mode'.tr, 'players'.tr],
      );
    });
  }
}

// ============================================================
// PAGE 1 : MATCH TYPE
// ============================================================
class _MatchTypePage extends GetView<GameSetupController> {
  const _MatchTypePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          _SectionTitle(
            icon: Icons.category,
            label: 'select_match_type'.tr,
          ),
          SizedBox(height: 8.h),
          ThemedText.caption(
            'select_match_type_desc'.tr,
            fontSize: 11.sp,
            color: ThemeColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 240.h,
            child: const _MatchTypeList(),
          ),
          SizedBox(height: 20.h),
          const _MatchTypeInfoBox(),
        ],
      ),
    );
  }
}

class _MatchTypeList extends GetView<GameSetupController> {
  const _MatchTypeList();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final selected = controller.selectedMatchType.value;
      final types = controller.availableMatchTypes;

      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final type = types[index];
          return MatchTypeCard(
            matchType: type,
            isSelected: selected == type,
            onTap: () => controller.selectMatchType(type),
          );
        },
      );
    });
  }
}

class _MatchTypeInfoBox extends GetView<GameSetupController> {
  const _MatchTypeInfoBox();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final type = controller.selectedMatchType.value;

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline,
                color: ThemeColors.primary, size: 20.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.translationKey.tr.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    type.descriptionKey.tr,
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10.sp,
                      color: ThemeColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _MatchTypeInfoDetails(type: type),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _MatchTypeInfoDetails extends StatelessWidget {
  final MatchType type;

  const _MatchTypeInfoDetails({required this.type});

  @override
  Widget build(BuildContext context) {
    final details = <String>[];

    if (type == MatchType.competition) {
      details.add('${'tournament_players'.tr} : 2-6');
      details.add('info_turn_based'.tr);
    } else if (type == MatchType.soloChrono) {
      details.add('info_single_player'.tr);
      details.add('info_saves_to_top10'.tr);
    } else if (type == MatchType.tournament) {
      details.add('${'tournament_players'.tr} : 4, 8, 16');
      details.add('info_direct_elimination'.tr);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.map((d) {
        return Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: Row(
            children: [
              Icon(Icons.circle, color: ThemeColors.primary, size: 6.sp),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  d,
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 9.sp,
                    color: ThemeColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ============================================================
// PAGE 2 : GAME MODE
// ============================================================
class _GameModePage extends GetView<GameSetupController> {
  const _GameModePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          _SectionTitle(
            icon: Icons.videogame_asset,
            label: 'select_game_mode'.tr,
          ),
          SizedBox(height: 8.h),
          const _GameModeDescription(),
          SizedBox(height: 16.h),
          const _GameModeGrid(),
          SizedBox(height: 16.h),
          const _TargetScoreInfo(),
        ],
      ),
    );
  }
}

class _GameModeDescription extends GetView<GameSetupController> {
  const _GameModeDescription();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final matchType = controller.selectedMatchType.value;

      return ThemedText.caption(
        '${matchType.translationKey.tr} → ${'select_game_mode_desc'.tr}',
        fontSize: 11.sp,
        color: ThemeColors.textSecondary,
      );
    });
  }
}

class _GameModeGrid extends GetView<GameSetupController> {
  const _GameModeGrid();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final selected = controller.selectedMode.value;
      final modes = controller.availableModes;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.9,
        ),
        itemCount: modes.length,
        itemBuilder: (context, index) {
          final mode = modes[index];
          return GameModeCard(
            mode: mode,
            isSelected: selected == mode,
            onTap: () => controller.selectMode(mode),
          );
        },
      );
    });
  }
}

class _TargetScoreInfo extends GetView<GameSetupController> {
  const _TargetScoreInfo();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final targetScore = controller.selectedMode.value.targetScore;

      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: ThemeColors.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColors.warning.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.flag, color: ThemeColors.warning, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              '${'target'.tr} :',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 12.sp,
                color: ThemeColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$targetScore pts',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 20.sp,
                fontWeight: FontWeight.w900,
                color: ThemeColors.warning,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// PAGE 3 : PLAYERS
// ============================================================
class _PlayersPage extends GetView<GameSetupController> {
  const _PlayersPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 12.h),
          const _SummaryBar(),
          SizedBox(height: 16.h),
          _SectionTitle(
            icon: Icons.group,
            label: 'select_players'.tr,
          ),
          SizedBox(height: 8.h),
          const _PlayerCountSection(),
          SizedBox(height: 16.h),
          _SectionTitle(
            icon: Icons.badge,
            label: 'player'.tr.toUpperCase(),
          ),
          SizedBox(height: 8.h),
          const _PlayerNamesSection(),
          SizedBox(height: 16.h),
          const _RecentPlayersSection(),
          SizedBox(height: 16.h),
          const _OptionsSection(),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

class _SummaryBar extends GetView<GameSetupController> {
  const _SummaryBar();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit .value explicitement
      final type = controller.selectedMatchType.value;
      final mode = controller.selectedMode.value;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: ThemeColors.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: ThemeColors.primary.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Text(type.icon, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                type.translationKey.tr.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: ThemeColors.primary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: ThemeColors.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: ThemeColors.warning.withOpacity(0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mode.icon, style: TextStyle(fontSize: 12.sp)),
                  SizedBox(width: 4.w),
                  Text(
                    mode.translationKey.tr.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.warning,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ============================================================
// SUB-WIDGETS COMMON
// ============================================================
class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SectionTitle({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.primary, size: 18.sp),
        SizedBox(width: 8.w),
        ThemedText.title(
          label,
          fontSize: 14.sp,
          color: ThemeColors.primary,
        ),
      ],
    );
  }
}

class _PlayerCountSection extends GetView<GameSetupController> {
  const _PlayerCountSection();

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.all(14.w),
      child: Obx(() {
        // ✅ Lit .value explicitement
        final type = controller.selectedMatchType.value;
        final count = controller.playerNames.length;

        if (type == MatchType.soloChrono) {
          return Row(
            children: [
              Icon(Icons.lock, color: ThemeColors.warning, size: 16.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: ThemedText.body(
                  '1 ${'player'.tr.toLowerCase()} — ${'match_type_solo_chrono'.tr}',
                  fontSize: 13.sp,
                ),
              ),
            ],
          );
        }

        if (type == MatchType.tournament) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: type.allowedSizes.map((size) {
                  final isSelected = count == size;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: InkWell(
                      onTap: () => controller.setPlayerCount(size),
                      borderRadius: BorderRadius.circular(10),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? ThemeColors.accent.withOpacity(0.2)
                              : ThemeColors.surface.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? ThemeColors.accent
                                : ThemeColors.accent.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$size',
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 22.sp,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? ThemeColors.accent
                                    : ThemeColors.textPrimary,
                              ),
                            ),
                            Text(
                              'players'.tr,
                              style: TextStyle(
                                fontFamily: 'Orbitron',
                                fontSize: 8.sp,
                                color: ThemeColors.textSecondary,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }

        // Competition (2-6)
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlayerCountSelector(
              currentCount: count,
              minCount: controller.minPlayers,
              maxCount: controller.maxPlayers,
              onChanged: controller.setPlayerCount,
            ),
            SizedBox(height: 8.h),
            ThemedText.caption(
              'player_count'.trParams({'count': '$count'}),
              fontSize: 11.sp,
              color: ThemeColors.textSecondary,
            ),
          ],
        );
      }),
    );
  }
}

class _PlayerNamesSection extends GetView<GameSetupController> {
  const _PlayerNamesSection();

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.all(14.w),
      child: Obx(() {
        // ✅ Lit .length de la liste (RxList)
        final count = controller.playerNames.length;

        return Column(
          children: List.generate(count, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < count - 1 ? 10.h : 0,
              ),
              child: _PlayerNameRow(index: index),
            );
          }),
        );
      }),
    );
  }
}

class _PlayerNameRow extends GetView<GameSetupController> {
  final int index;
  const _PlayerNameRow({required this.index});

  @override
  Widget build(BuildContext context) {
    final color = Helpers.playerColor(index);

    return Row(
      children: [
        // ✅ AVATAR PREVIEW ou BADGE NUMÉRO (tap pour capturer)
        _PlayerAvatarPreview(
          index: index,
          color: color,
        ),
        SizedBox(width: 10.w),

        // TextField nom
        Expanded(
          child: TextField(
            controller: controller.getTextControllerFor(index),
            maxLength: GameConstants.playerNameMaxLength,
            style: TextStyle(
              fontFamily: 'Orbitron',
              color: ThemeColors.textPrimary,
              fontSize: 14.sp,
            ),
            decoration: InputDecoration(
              counterText: '',
              hintText: 'enter_player_name'
                  .trParams({'number': '${index + 1}'}),
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: ThemeColors.textHint,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 10.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color.withOpacity(0.4)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color.withOpacity(0.4)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: color, width: 2),
              ),
            ),
          ),
        ),

        // Bouton remove
        Obx(() {
          if (controller.playerNames.length > controller.minPlayers) {
            return Padding(
              padding: EdgeInsets.only(left: 6.w),
              child: IconButton(
                onPressed: () => controller.removePlayer(index),
                icon: Icon(
                  Icons.remove_circle_outline,
                  color: ThemeColors.error,
                  size: 22.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
}

// ============================================================
// ✅ AVATAR PREVIEW WIDGET (séparé pour isoler le Obx)
// ============================================================
class _PlayerAvatarPreview extends StatelessWidget {
  final int index;
  final Color color;

  const _PlayerAvatarPreview({
    required this.index,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Récupère le service via Get.find()
    AvatarCaptureService? avatarService;
    try {
      avatarService = Get.find<AvatarCaptureService>();
    } catch (_) {
      avatarService = null;
    }

    if (avatarService == null) {
      // Pas de service caméra → badge simple
      return _SimpleBadge(index: index, color: color);
    }

    return GestureDetector(
      onTap: () => _openCapture(context),
      child: Obx(() {
        // ✅ Lit directement la map observable
        final hasPhoto = avatarService!.avatarPreviews.containsKey(index);
        final previewBytes = hasPhoto
            ? avatarService.getPreviewBytes(index)
            : null;

        if (previewBytes != null) {
          // ===== PHOTO PREVIEW =====
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                  boxShadow: ThemeColors.useGlow
                      ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                    ),
                  ]
                      : null,
                ),
                child: ClipOval(
                  child: Image.memory(
                    previewBytes,
                    fit: BoxFit.cover,
                    width: 40.w,
                    height: 40.w,
                    errorBuilder: (_, __, ___) {
                      return _SimpleBadge(index: index, color: color);
                    },
                  ),
                ),
              ),
              // Petit badge caméra
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: ThemeColors.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: ThemeColors.surface, width: 1.5),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 10.w,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        }

        // ===== BADGE NUMÉRO + CAMÉRA =====
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: color, width: 2),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    color: color,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                width: 16.w,
                height: 16.w,
                decoration: BoxDecoration(
                  color: ThemeColors.accent.withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: ThemeColors.surface, width: 1.5),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 9.w,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
  void _openCapture(BuildContext context) {
    final setupController = Get.find<GameSetupController>();
    final playerName = setupController.playerNames[index];

    Get.dialog(
      AvatarCaptureDialog(
        playerName: playerName,
        playerIndex: index,
      ),
      barrierDismissible: false,
    );
  }
}


// ============================================================
// SIMPLE BADGE (fallback sans service caméra)
// ============================================================
class _SimpleBadge extends StatelessWidget {
  final int index;
  final Color color;

  const _SimpleBadge({required this.index, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontFamily: 'Orbitron',
            color: color,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _RecentPlayersSection extends GetView<GameSetupController> {
  const _RecentPlayersSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ✅ Lit la liste
      final recents = controller.recentPlayerNames.toList();
      if (recents.isEmpty) return const SizedBox.shrink();

      return ThemedCard(
        padding: EdgeInsets.all(14.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history,
                    color: ThemeColors.textSecondary, size: 14.sp),
                SizedBox(width: 6.w),
                ThemedText.caption(
                  'recent_players'.tr,
                  fontSize: 11.sp,
                  color: ThemeColors.textSecondary,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: recents.take(10).map((name) {
                return PlayerChip(
                  name: name,
                  onTap: () {
                    int targetIdx = controller.playerNames.indexWhere(
                          (n) => n.trim().isEmpty || n.startsWith('Player '),
                    );
                    if (targetIdx < 0) {
                      targetIdx = controller.playerNames.length - 1;
                    }
                    controller.applyRecentName(targetIdx, name);
                  },
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}

class _OptionsSection extends GetView<GameSetupController> {
  const _OptionsSection();

  @override
  Widget build(BuildContext context) {
    return ThemedCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      child: Column(
        children: [
          _OptionRow(
            icon: Icons.volume_up,
            label: 'sound_effects'.tr,
            observable: controller.soundEnabled,
            onToggle: controller.toggleSound,
          ),
          _Divider(),
          _OptionRow(
            icon: Icons.record_voice_over,
            label: 'voice_announcements'.tr,
            observable: controller.ttsEnabled,
            onToggle: controller.toggleTts,
          ),
          _Divider(),
          _OptionRow(
            icon: Icons.replay,
            label: 'Bounce on overshoot',
            observable: controller.overshootBounce,
            onToggle: controller.toggleOvershootBounce,
          ),
        ],
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxBool observable;
  final VoidCallback onToggle;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.observable,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, color: ThemeColors.primary, size: 18.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: ThemedText.body(label, fontSize: 13.sp),
          ),
          Obx(() => Switch(
            value: observable.value,
            onChanged: (_) => onToggle(),
            activeColor: ThemeColors.primary,
          )),
        ],
      ),
    );
  }


}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: ThemeColors.primary.withOpacity(0.15),
    );
  }
}



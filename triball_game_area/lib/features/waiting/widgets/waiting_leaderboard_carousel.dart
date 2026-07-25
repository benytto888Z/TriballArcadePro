// triball_game_area/lib/features/waiting/widgets/waiting_leaderboard_carousel.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/controllers/platform_event_bus.dart';
import '../../../core/theme/theme_colors.dart';
import '../../../core/values/app_styles.dart';
import '../../../data/models/game_state_model.dart';
import '../../../data/models/leaderboard_entry_model.dart';
import '../../../data/models/platform_leaderboard_model.dart';
import '../../game/utils/game_screen_breakpoints.dart';
import '../waiting_controller.dart';

class WaitingLeaderboardCarousel extends GetView<WaitingController> {
  const WaitingLeaderboardCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return _CarouselContent();
  }
}

class _CarouselContent extends StatefulWidget {
  @override
  State<_CarouselContent> createState() => _CarouselContentState();
}

class _CarouselContentState extends State<_CarouselContent> {
  final controller = Get.find<WaitingController>();
  List<LeaderboardEntryModel> _entries = [];
  StreamSubscription<PlatformLeaderboardData>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = PlatformEventBus.instance.onLeaderboardData.listen((data) {
      if (mounted) setState(() => _entries = data.entries);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: GameScreenBreakpoints.waitingLeaderboardPadding(),
        vertical: GameScreenBreakpoints.waitingLeaderboardPadding() * 0.2
      ),
      decoration: BoxDecoration(
        color: ThemeColors.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ThemeColors.primary.withOpacity(0.3)),
        boxShadow: ThemeColors.useGlow
            ? [
          BoxShadow(
            color: ThemeColors.primary.withOpacity(0.15),
            blurRadius: 20,
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          // ===== HEADER =====
          Obx(() {
            final mode = controller.currentMode;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: controller.previousLeaderboardMode,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: ThemeColors.primary,
                    size: GameScreenBreakpoints.waitingLeaderboardNavIconSize(),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: ThemeColors.warning,
                      size: GameScreenBreakpoints.waitingLeaderboardTitleSize() * 0.8,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'TOP 10',
                      style: TextStyle(
                        fontFamily: AppStyles.defaultFontFamily2,
                        fontSize: GameScreenBreakpoints.waitingLeaderboardTitleSize() * 1.2,
                        fontWeight: FontWeight.w900,
                        color: ThemeColors.warning,
                        shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: controller.nextLeaderboardMode,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: ThemeColors.primary,
                    size: GameScreenBreakpoints.waitingLeaderboardNavIconSize(),
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 2.h),

          // ===== MODE NAME =====
          Obx(() {
            final mode = controller.currentMode;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: ThemeColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    mode.icon,
                    style: TextStyle(
                      fontSize: GameScreenBreakpoints.waitingLeaderboardModeFontSize() * 0.95,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    mode.translationKey.tr.toUpperCase(),
                    style: TextStyle(
                      fontFamily: AppStyles.defaultFontFamily2,
                      fontSize: GameScreenBreakpoints.waitingLeaderboardModeFontSize() * 1.1,
                      fontWeight: FontWeight.w800,
                      color: ThemeColors.primary,
                      shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 10.h),

          // ===== ENTRIES =====
          Expanded(
            child: _entries.isEmpty
                ? Center(
              child: Text(
                'leaderboard_empty'.tr,
                style: TextStyle(
                  fontFamily: AppStyles.defaultFontFamily2,
                  fontSize: GameScreenBreakpoints.waitingLeaderboardNameFontSize()*1.5,
                  fontWeight: FontWeight.w900,
                  color: ThemeColors.textSecondary,
                  shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                ),
              ),
            )
                : ListView.builder(
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                return _EntryRow(
                  entry: _entries[index],
                  rank: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  final LeaderboardEntryModel entry;
  final int rank;

  const _EntryRow({required this.entry, required this.rank});

  String _rankEmoji() {
    switch (rank) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }

  Color _rankColor() {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return ThemeColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;
    final color = _rankColor();

    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isTop3
            ? color.withOpacity(0.1)
            : ThemeColors.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: isTop3
            ? Border.all(color: color.withOpacity(0.5), width: 1)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 70.w,
            child: isTop3
                ? Text(
              _rankEmoji(),
              style: TextStyle(
                fontSize: GameScreenBreakpoints.waitingLeaderboardRankEmojiSize()*1.8,
              ),
            )
                : Text(
              '$rank',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppStyles.defaultFontFamily2,
                fontSize: GameScreenBreakpoints.waitingLeaderboardRankFontSize()*1.8,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                color: ThemeColors.textSecondary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              entry.playerName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppStyles.defaultFontFamily2,
                fontSize: GameScreenBreakpoints.waitingLeaderboardNameFontSize()*1.3,
                fontWeight: FontWeight.w700,
                color: isTop3 ? color : ThemeColors.textPrimary,
                shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
                letterSpacing: 1,
              ),
            ),
          ),
          Text(
            entry.timeFormatted,
            style: TextStyle(
              fontFamily: AppStyles.defaultFontFamily2,
              fontSize: GameScreenBreakpoints.waitingLeaderboardTimeFontSize()*1.3,
              fontWeight: FontWeight.w900,
              color: isTop3 ? color : ThemeColors.primary,
              shadows: [Shadow(color: Color(0xff0b0302), offset: Offset(0, 6), blurRadius: 12)],
              letterSpacing: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
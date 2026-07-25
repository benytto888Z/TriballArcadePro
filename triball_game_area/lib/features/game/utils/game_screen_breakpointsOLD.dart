// triball_game_area/lib/core/utils/game_screen_breakpoints.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

enum GameScreenDevice {
  mobile,    // Téléphones landscape : < 900px
  tablet,    // Tablettes 7-10" : 900-1200px
  iPad,      // iPad Pro 12.9" : 1200-1400px
  tv32,      // TV 32" : 1400-1920px
  tv45,      // TV 45"+ : ≥ 1920px
}

/// Utilitaire pour adapter les tailles du Game Area à l'écran.
/// Utilisé par WaitingScreen, GameScreen et LeaderboardScreen.
class GameScreenBreakpoints {
  GameScreenBreakpoints._();

  // ============================================
  // DÉTECTION DU TYPE D'ÉCRAN
  // ============================================
  static GameScreenDevice get device {
    final ctx = Get.context;
    if (ctx == null) return GameScreenDevice.tv32;

    final width = MediaQuery.of(ctx).size.width;

    if (width < 900) return GameScreenDevice.mobile;
    if (width < 1200) return GameScreenDevice.tablet;
    if (width < 1400) return GameScreenDevice.iPad;
    if (width < 1920) return GameScreenDevice.tv32;
    return GameScreenDevice.tv45;
  }

  static bool get isMobile => device == GameScreenDevice.mobile;
  static bool get isTablet => device == GameScreenDevice.tablet;
  static bool get isIPad => device == GameScreenDevice.iPad;
  static bool get isTV32 => device == GameScreenDevice.tv32;
  static bool get isTV45 => device == GameScreenDevice.tv45;
  static bool get isTVOrLarger =>
      device == GameScreenDevice.tv32 || device == GameScreenDevice.tv45;

  // ============================================
  // HELPER GÉNÉRIQUE
  // ============================================
  static T value<T>({
    required T mobile,
    T? tablet,
    T? iPad,
    T? tv32,
    T? tv45,
  }) {
    switch (device) {
      case GameScreenDevice.mobile: return mobile;
      case GameScreenDevice.tablet: return tablet ?? mobile;
      case GameScreenDevice.iPad:   return iPad ?? tablet ?? mobile;
      case GameScreenDevice.tv32:   return tv32 ?? iPad ?? tablet ?? mobile;
      case GameScreenDevice.tv45:   return tv45 ?? tv32 ?? iPad ?? tablet ?? mobile;
    }
  }

  // ============================================
  // ============================================
  //     🎮 GAME SCREEN BREAKPOINTS
  // ============================================
  // ============================================

  // --- TOP BAR ---
  static double topBarFontSize() => value(
    mobile: 10.sp, tablet: 14.sp, iPad: 60.sp, tv32: 60.sp, tv45: 60.sp,
  );

  static double topBarTimeFontSize() => value(
    mobile: 17.sp, tablet: 22.sp, iPad: 80.sp, tv32: 80.sp, tv45: 80.sp,
  );

  // --- TURN TIMER ---
  static double turnTimerSize() => value(
    mobile: 40, tablet: 60, iPad: 220, tv32: 220, tv45: 220,
  );

  static double turnTimerFontSize() => value(
    mobile: 40.sp, tablet: 60.sp, iPad: 145.sp, tv32: 145.sp, tv45: 145.sp,
  );

  static double turnTimerSecFontSize() => value(
    mobile: 40.sp, tablet: 60.sp, iPad: 50.sp, tv32: 50.sp, tv45: 50.sp,
  );

  static double turnTimerTop() => value(
    mobile: 8.h, tablet: 12.h, iPad: 16.h, tv32: 130.h, tv45: 130.h,
  );

  // --- PLAYER GRID ---
  static double playerCardHeight(int playerCount) {
    if (playerCount > 3) {
      return value(
        mobile: 125.h, tablet: 180.h, iPad: 310.h, tv32: 290.h, tv45: 290.h,
      );
    }
    return value(
      mobile: 170.h, tablet: 240.h, iPad: 310.h, tv32: 310.h, tv45: 310.h,
    );
  }

  static double playerCardHSpacing() => value(
    mobile: 2.w, tablet: 8.w, iPad: 12.w, tv32: 16.w, tv45: 20.w,
  );

  static double playerCardVSpacing() => value(
    mobile: 10.h, tablet: 14.h, iPad: 40.h, tv32: 40.h, tv45: 40.h,
  );

  // --- PLAYER SCORE CARD ---
  static double playerCardPadding(bool isCompact) => value(
    mobile: isCompact ? 3.w : 4.w,
    tablet: isCompact ? 8.w : 10.w,
    iPad: isCompact ? 12.w : 14.w,
    tv32: isCompact ? 16.w : 20.w,
    tv45: isCompact ? 20.w : 24.w,
  );

  static double playerCardPaddingBootom(bool isCompact) => value(
    mobile: isCompact ? 3.w : 4.w,
    tablet: isCompact ? 8.w : 10.w,
    iPad: isCompact ? 4.w : 4.w,
    tv32: isCompact ? 4.w : 4.w,
    tv45: isCompact ? 4.w : 4.w,
  );

  static double playerBadgeSize() => value(
    mobile: 16.w, tablet: 22.w, iPad: 70.w, tv32: 70.w, tv45: 70.w,
  );

  static double playerBadgeFontSize() => value(
    mobile: 10.sp, tablet: 13.sp, iPad: 50.sp, tv32: 50.sp, tv45: 50.sp,
  );

  static double playerNameFontSize(bool isCompact) => value(
    mobile: isCompact ? 6.sp : 8.sp,
    tablet: isCompact ? 10.sp : 13.sp,
    iPad: isCompact ? 60.sp : 60.sp,
    tv32: isCompact ? 60.sp : 60.sp,
    tv45: isCompact ?  60.sp : 60.sp,
  );

  static double playerScoreFontSize(bool isCompact, double h) {
    if (isMobile) {
      return isCompact
          ? (h < 130 ? 20.w : 22.w)
          : (h < 180 ? 22.w : 26.w);
    }
    return value(
      mobile: 22.w,
      tablet: isCompact ? 32.sp : 42.sp,
      iPad: isCompact ? 125.sp : 125.sp,
      tv32: isCompact ? 125.sp : 125.sp,
      tv45: isCompact ? 125.sp : 125.sp,
    );
  }

  static double playerTurnBadgeFontSize() => value(
    mobile: 6.w, tablet: 9.sp, iPad: 50.sp, tv32: 50.sp, tv45: 50.sp,
  );

  static double playerStarSize() => value(
    mobile: 13.w, tablet: 18.w, iPad: 50.w, tv32: 50.w, tv45: 50.w,
  );

  static double playerProgressHeight() => value(
    mobile: 4.0, tablet: 6.0, iPad: 12.0, tv32: 12.0, tv45: 12.0,
  );

  static double playerBorderWidthActive() => value(
    mobile: 3, tablet: 4, iPad: 5, tv32: 6, tv45: 7,
  );

  // --- EVENT CHIPS ---
  static double eventChipFontSize(bool isCompact) => value(
    mobile: isCompact ? 5.w : 6.w,
    tablet: isCompact ? 8.sp : 10.sp,
    iPad: isCompact ? 55.sp : 55.sp,
    tv32: isCompact ? 55.sp : 55.sp,
    tv45: isCompact ? 55.sp : 55.sp,
  );

  static double eventChipPadding() => value(
    mobile: 2.w, tablet: 6.w, iPad: 15.w, tv32: 15.w, tv45: 15.w,
  );

  static double eventEmptyFontSize() => value(
    mobile: 10.w, tablet: 14.sp, iPad: 86.sp, tv32: 86.sp, tv45: 86.sp,
  );

  // --- SCREEN PADDING ---
  static EdgeInsets screenPadding() => value(
    mobile: EdgeInsets.only(left: 6.w, right: 6.w, top: 4.h, bottom: 12.h),
    tablet: EdgeInsets.only(left: 20.w, right: 20.w, top: 12.h, bottom: 20.h),
    iPad: EdgeInsets.only(left: 30.w, right: 30.w, top: 16.h, bottom: 24.h),
    tv32: EdgeInsets.only(left: 40.w, right: 40.w, top: 24.h, bottom: 32.h),
    tv45: EdgeInsets.only(left: 60.w, right: 60.w, top: 32.h, bottom: 40.h),
  );

  static double topBarBottomSpacing(int playerCount) {
    if (playerCount > 3) {
      return value(
        mobile: 35.h, tablet: 40.h, iPad: 100.h, tv32: 100.h, tv45: 100.h,
      );
    }
    return value(
      mobile: 73.h, tablet: 80.h, iPad: 150.h, tv32: 150.h, tv45: 150.h,
    );
  }

  // --- BOTTOM CONTROLS ---
  static double controlsButtonBottom() => value(
    mobile: 25.h, tablet: 30.h, iPad: 40.h, tv32: 50.h, tv45: 60.h,
  );

  static double controlsButtonLeft() => value(
    mobile: 4.w, tablet: 16.w, iPad: 24.w, tv32: 32.w, tv45: 48.w,
  );

  static double controlsPanelBottom() => value(
    mobile: 76.h, tablet: 90.h, iPad: 110.h, tv32: 130.h, tv45: 160.h,
  );

  // --- COMBO INDICATOR ---
  static double comboBannerTop() => value(
    mobile: 70.h, tablet: 90.h, iPad: 110.h, tv32: 130.h, tv45: 160.h,
  );

  // --- PARTICLES ---
  static int particlesCount() => value(
    mobile: 15, tablet: 20, iPad: 90, tv32: 90, tv45: 90,
  );

  // ============================================
  // ============================================
  //     ⏳ WAITING SCREEN BREAKPOINTS
  // ============================================
  // ============================================

  // --- WAITING LOGO ---
  static double waitingLogoFontSize() => value(
    //mobile: 40, tablet: 56, iPad: 64, tv32: 72, tv45: 90,
    mobile: 40, tablet: 56, iPad: 92, tv32: 100, tv45: 100,
  );

  static double waitingSubtitleFontSize() => value(
    mobile: 12, tablet: 16, iPad: 78, tv32: 78, tv45: 78,
  );

  static double waitingBadgeFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 65.sp, tv32: 65.sp, tv45: 65.sp,
  );

  // --- WAITING STATUS BAR ---
  static double waitingStatusBarPaddingH() => value(
    mobile: 12.w, tablet: 20.w, iPad: 28.w, tv32: 36.w, tv45: 36.w,
  );

  static double waitingStatusBarPaddingV() => value(
    mobile: 8.h, tablet: 10.h, iPad: 12.h, tv32: 14.h, tv45: 18.h,
  );

  static double waitingStatusIconSize() => value(
    mobile: 16.sp, tablet: 18.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  static double waitingStatusLabelSize() => value(
    mobile: 9.sp, tablet: 10.sp, iPad: 32.sp, tv32: 34.sp, tv45: 34.sp,
  );

  static double waitingStatusValueSize() => value(
    mobile: 11.sp, tablet: 12.sp, iPad: 34.sp, tv32: 36.sp, tv45: 36.sp,
  );

  static double waitingClockFontSize() => value(
    mobile: 18.sp, tablet: 22.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  // --- WAITING INSTRUCTIONS ---
  static double waitingMessageFontSize() => value(
    mobile: 12.sp, tablet: 14.sp, iPad: 45.sp, tv32: 45.sp, tv45: 45.sp,
  );

  static double waitingDetailFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  static double waitingWinnerNameFontSize() => value(
    mobile: 16.sp, tablet: 20.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  static double waitingWinnerTrophySize() => value(
    mobile: 22.sp, tablet: 28.sp, iPad: 45.sp, tv32: 45.sp, tv45: 45.sp,
  );

  // --- WAITING LEADERBOARD CAROUSEL ---
  static double waitingLeaderboardPadding() => value(
    mobile: 12.w, tablet: 16.w, iPad: 20.w, tv32: 26.w, tv45: 32.w,
  );

  static double waitingLeaderboardTitleSize() => value(
    mobile: 12.sp, tablet: 14.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  static double waitingLeaderboardModeFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 40.sp, tv32: 40.sp, tv45: 40.sp,
  );

  static double waitingLeaderboardNameFontSize() => value(
    mobile: 11.sp, tablet: 13.sp, iPad: 30.sp, tv32: 30.sp, tv45: 30.sp,
  );

  static double waitingLeaderboardTimeFontSize() => value(
    mobile: 12.sp, tablet: 14.sp, iPad: 30.sp, tv32: 30.sp, tv45: 30.sp,
  );

  static double waitingLeaderboardRankEmojiSize() => value(
    mobile: 14.sp, tablet: 16.sp, iPad: 30.sp, tv32: 30.sp, tv45: 30.sp,
  );

  static double waitingLeaderboardRankFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 23.sp, tv32: 23.sp, tv45: 23.sp,
  );

  static double waitingLeaderboardNavIconSize() => value(
    mobile: 14.sp, tablet: 16.sp, iPad: 18.sp, tv32: 22.sp, tv45: 22.sp,
  );

  // --- WAITING LAYOUT (flex ratios) ---
  static int waitingLeftFlex() => value(
    mobile: 5, tablet: 5, iPad: 4, tv32: 4, tv45: 4,
  );

  static int waitingRightFlex() => value(
    mobile: 4, tablet: 3, iPad: 3, tv32: 3, tv45: 3,
  );

  static double waitingContentSpacing() => value(
    mobile: 16.w, tablet: 24.w, iPad: 30.w, tv32: 40.w, tv45: 50.w,
  );

  static double waitingScreenPaddingH() => value(
    mobile: 16.w, tablet: 28.w, iPad: 36.w, tv32: 48.w, tv45: 64.w,
  );

  static double waitingScreenPaddingV() => value(
    mobile: 12.h, tablet: 16.h, iPad: 20.h, tv32: 24.h, tv45: 32.h,
  );

  static int waitingParticlesCount() => value(
    mobile: 20, tablet: 30, iPad: 55, tv32: 75, tv45: 90,
  );

  // ============================================
  // ============================================
  //     🏆 LEADERBOARD SCREEN BREAKPOINTS
  // ============================================
  // ============================================

  // --- LEADERBOARD HEADER ---
  static double lbHeaderFontSize() => value(
    mobile: 18.sp, tablet: 22.sp, iPad: 55.sp, tv32: 32.sp, tv45: 40.sp,
  );

  static double lbHeaderIconSize() => value(
    mobile: 22.sp, tablet: 26.sp, iPad: 50.sp, tv32: 36.sp, tv45: 44.sp,
  );

  // --- LEADERBOARD TABS ---
  static double lbTabFontSize() => value(
    mobile: 11.sp, tablet: 13.sp, iPad: 14.sp, tv32: 17.sp, tv45: 22.sp,
  );

  static double lbTabIconSize() => value(
    mobile: 16.sp, tablet: 18.sp, iPad: 20.sp, tv32: 24.sp, tv45: 30.sp,
  );

  static double lbTabHeight() => value(
    mobile: 44.h, tablet: 50.h, iPad: 56.h, tv32: 64.h, tv45: 76.h,
  );

  static double lbTabPaddingH() => value(
    mobile: 14.w, tablet: 18.w, iPad: 22.w, tv32: 28.w, tv45: 36.w,
  );

  static double lbTabPaddingV() => value(
    mobile: 8.h, tablet: 10.h, iPad: 12.h, tv32: 14.h, tv45: 18.h,
  );

  // --- LEADERBOARD PODIUM ---
  static double lbPodiumHeight() => value(
    mobile: 220.h, tablet: 280.h, iPad: 340.h, tv32: 400.h, tv45: 480.h,
  );

  static double lbPodiumPillar1Height() => value(
    mobile: 120.h, tablet: 160.h, iPad: 200.h, tv32: 240.h, tv45: 300.h,
  );

  static double lbPodiumPillar2Height() => value(
    mobile: 90.h, tablet: 120.h, iPad: 150.h, tv32: 180.h, tv45: 220.h,
  );

  static double lbPodiumPillar3Height() => value(
    mobile: 70.h, tablet: 96.h, iPad: 120.h, tv32: 150.h, tv45: 180.h,
  );

  static double lbPodiumCardWidth() => value(
    mobile: 90.w, tablet: 110.w, iPad: 130.w, tv32: 160.w, tv45: 200.w,
  );

  static double lbPodiumEmojiSize() => value(
    mobile: 24.sp, tablet: 28.sp, iPad: 32.sp, tv32: 40.sp, tv45: 50.sp,
  );

  static double lbPodiumNameFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 14.sp, tv32: 18.sp, tv45: 22.sp,
  );

  static double lbPodiumTimeFontSize() => value(
    mobile: 8.sp, tablet: 10.sp, iPad: 12.sp, tv32: 15.sp, tv45: 18.sp,
  );

  static double lbPodiumRankFontSize() => value(
    mobile: 28.sp, tablet: 36.sp, iPad: 42.sp, tv32: 52.sp, tv45: 64.sp,
  );

  // --- LEADERBOARD ENTRY TILE ---
  static double lbEntryNameFontSize() => value(
    mobile: 13.sp, tablet: 15.sp, iPad: 17.sp, tv32: 22.sp, tv45: 28.sp,
  );

  static double lbEntryTimeFontSize() => value(
    mobile: 14.sp, tablet: 16.sp, iPad: 18.sp, tv32: 24.sp, tv45: 30.sp,
  );

  static double lbEntryDateFontSize() => value(
    mobile: 9.sp, tablet: 10.sp, iPad: 11.sp, tv32: 14.sp, tv45: 17.sp,
  );

  static double lbEntryRankBadgeSize() => value(
    mobile: 32.w, tablet: 40.w, iPad: 48.w, tv32: 56.w, tv45: 68.w,
  );

  static double lbEntryRankEmojiSize() => value(
    mobile: 20.sp, tablet: 24.sp, iPad: 28.sp, tv32: 34.sp, tv45: 42.sp,
  );

  static double lbEntryRankSize() => value(
    mobile: 32.w, tablet: 40.w, iPad: 50.w, tv32: 50.w, tv45: 50.w,
  );

  static double lbEntryRankFontSize() => value(
    mobile: 20.sp, tablet: 24.sp, iPad: 65.sp, tv32: 65.sp, tv45: 65.sp,
  );

  static double lbEntryPaddingH() => value(
    mobile: 10.w, tablet: 14.w, iPad: 18.w, tv32: 24.w, tv45: 30.w,
  );

  static double lbEntryPaddingV() => value(
    mobile: 8.h, tablet: 10.h, iPad: 12.h, tv32: 16.h, tv45: 20.h,
  );

  static double lbEntrySpacing() => value(
    mobile: 6.h, tablet: 8.h, iPad: 10.h, tv32: 12.h, tv45: 16.h,
  );

  // --- LEADERBOARD STATS SUMMARY ---
  static double lbStatValueFontSize() => value(
    mobile: 13.sp, tablet: 16.sp, iPad: 30.sp, tv32: 24.sp, tv45: 30.sp,
  );

  static double lbStatLabelFontSize() => value(
    mobile: 7.sp, tablet: 9.sp, iPad: 25.sp, tv32: 13.sp, tv45: 16.sp,
  );

  static double lbStatIconSize() => value(
    mobile: 12.sp, tablet: 14.sp, iPad: 35.sp, tv32: 20.sp, tv45: 24.sp,
  );

  // --- LEADERBOARD FILTER CHIPS ---
  static double lbFilterFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 13.sp, tv32: 16.sp, tv45: 20.sp,
  );

  static double lbFilterPaddingH() => value(
    mobile: 12.w, tablet: 14.w, iPad: 16.w, tv32: 20.w, tv45: 26.w,
  );

  static double lbFilterPaddingV() => value(
    mobile: 6.h, tablet: 8.h, iPad: 10.h, tv32: 12.h, tv45: 16.h,
  );

  // --- LEADERBOARD SCREEN PADDING ---
  static double lbScreenPaddingH() => value(
    mobile: 16.w, tablet: 24.w, iPad: 32.w, tv32: 48.w, tv45: 64.w,
  );

  // --- LEADERBOARD DISCONNECTED ---
  static double lbDisconnectedIconSize() => value(
    mobile: 80.sp, tablet: 100.sp, iPad: 120.sp, tv32: 140.sp, tv45: 180.sp,
  );

  static double lbDisconnectedTitleSize() => value(
    mobile: 16.sp, tablet: 20.sp, iPad: 24.sp, tv32: 30.sp, tv45: 38.sp,
  );

  static double lbDisconnectedDescSize() => value(
    mobile: 11.sp, tablet: 13.sp, iPad: 15.sp, tv32: 18.sp, tv45: 22.sp,
  );

  // ============================================
  // ============================================
  //     🎯 COMMON / SHARED BREAKPOINTS
  // ============================================
  // ============================================

  // --- VICTORY DIALOG ---
  static double victoryDialogWidth() => value(
    mobile: 520.w, tablet: 500.w, iPad: 700.h, tv32: 700.h, tv45: 700.h,
  );

  static double victoryTrophySize() => value(
    mobile: 80.sp, tablet: 100.sp, iPad: 180.sp, tv32: 180.sp, tv45: 180.sp,
  );

  static double victoryTitleFontSize() => value(
    mobile: 32.sp, tablet: 40.sp, iPad: 72.sp, tv32: 72.sp, tv45: 72.sp,
  );

  static double victoryNameFontSize() => value(
    mobile: 20.sp, tablet: 26.sp, iPad: 60.sp, tv32: 60.sp, tv45: 60.sp,
  );

  static double victoryStatFontSize() => value(
    mobile: 14.sp, tablet: 18.sp, iPad: 80.sp, tv32: 80.sp, tv45: 80.sp,
  );

  static double victoryButtonWidth() => value(
    mobile: 130.w, tablet: 140.w, iPad: 220.w, tv32: 220.w, tv45: 220.w,
  );

  // --- COUNTDOWN OVERLAY ---
  static double countdownNumberSize() => value(
    mobile: 130.sp, tablet: 160.sp, iPad: 350.sp, tv32: 350.sp, tv45: 350.sp,
  );

  static double countdownGoSize() => value(
    mobile: 90.sp, tablet: 120.sp, iPad: 280.sp, tv32: 280.sp, tv45: 280.sp,
  );

  static double countdownNameSize() => value(
    mobile: 26.sp, tablet: 34.sp, iPad: 130.sp, tv32: 130.sp, tv45: 130.sp,
  );

  static double countdownSubtitleSize() => value(
    mobile: 12.sp, tablet: 16.sp, iPad: 90.sp, tv32: 90.sp, tv45: 90.sp,
  );

  // --- SCORE POPUP ---
  static double scorePopupFontSize() => value(
    mobile: 56.sp, tablet: 72.sp, iPad: 150.sp, tv32: 150.sp, tv45: 150.sp,
  );

  static double scorePopupPaddingH() => value(
    mobile: 30.w, tablet: 40.w, iPad: 80.w, tv32: 80.w, tv45: 80.w,
  );

  static double scorePopupPaddingV() => value(
    mobile: 14.h, tablet: 18.h, iPad: 36.h, tv32: 36.h, tv45: 36.h,
  );

  // --- COMBO INDICATOR ---
  static double comboEmojiFontSize() => value(
    mobile: 36.sp, tablet: 48.sp, iPad: 56.sp, tv32: 64.sp, tv45: 80.sp,
  );

  static double comboTitleFontSize() => value(
    mobile: 22.sp, tablet: 30.sp, iPad: 36.sp, tv32: 44.sp, tv45: 56.sp,
  );

  static double comboMultiplierFontSize() => value(
    mobile: 12.sp, tablet: 16.sp, iPad: 18.sp, tv32: 22.sp, tv45: 28.sp,
  );

  // --- STATS PANEL ---
  static double statsPanelLabelSize() => value(
    mobile: 6.w, tablet: 9.sp, iPad: 45.sp, tv32: 13.sp, tv45: 16.sp,
  );

  static double statsPanelValueSize() => value(
    mobile: 11.w, tablet: 14.sp, iPad: 52.sp, tv32: 20.sp, tv45: 26.sp,
  );

  static double statsPanelIconSize() => value(
    mobile: 12.w, tablet: 16.sp, iPad: 55.sp, tv32: 22.sp, tv45: 28.sp,
  );

  static double statsPanelDividerHeight() => value(
    mobile: 28.h, tablet: 34.h, iPad: 65.h, tv32: 48.h, tv45: 56.h,
  );

  // --- CONTROLS BUTTON ---
  static double controlsButtonSize() => value(
    mobile: 55.h, tablet: 60.h, iPad: 68.h, tv32: 76.h, tv45: 90.h,
  );

  static double controlsButtonIconSize() => value(
    mobile: 30.h, tablet: 34.h, iPad: 38.h, tv32: 44.h, tv45: 52.h,
  );

  // --- SCORE VIEWING PAUSE OVERLAY ---
  static double scoreViewingScoreFontSize() => value(
    mobile: 60.sp, tablet: 80.sp, iPad: 150.sp, tv32: 120.sp, tv45: 150.sp,
  );

  static double scoreViewingNameFontSize() => value(
    mobile: 24.sp, tablet: 32.sp, iPad: 60.sp, tv32: 46.sp, tv45: 58.sp,
  );

  static double scoreViewingLabelFontSize() => value(
    mobile: 14.sp, tablet: 18.sp, iPad: 45.sp, tv32: 24.sp, tv45: 30.sp,
  );

  static double scoreViewingCountdownFontSize() => value(
    mobile: 18.sp, tablet: 22.sp, iPad: 45.sp, tv32: 32.sp, tv45: 40.sp,
  );

  // ============================================
// GAME SCREEN — TURN TIMER LEFT (centrage)
// ============================================
  /// ✅ Utilise Positioned(left: 0, right: 0) + Align au lieu de left fixe
  /// Mais si tu veux un left calculé :
  static double turnTimerLeft() {
    final ctx = Get.context;
    if (ctx == null) return 0;
    final screenWidth = MediaQuery.of(ctx).size.width;
    final timerSize = turnTimerSize();
    return (screenWidth / 2) - (timerSize / 2);
  }

// ============================================
// PLAYER SCORE CARD — Spacing entre progress et recent events
// ============================================
  static double sizeboxBetweenProEvents() => value(
    mobile: 1.h,
    tablet: 4.h,
    iPad: 6.h,
    tv32: 8.h,
    tv45: 12.h,
  );

  // ============================================
  // 🏆 TOURNAMENT / BRACKET SCREEN
  // ============================================
  static EdgeInsets tournamentScreenPadding() => value(
    mobile: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    tablet: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
    iPad: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
    tv32: EdgeInsets.symmetric(horizontal: 34.w, vertical: 18.h),
    tv45: EdgeInsets.symmetric(horizontal: 48.w, vertical: 22.h),
  );

  static double tournamentStatsPaddingH() => value(
    mobile: 10.w, tablet: 14.w, iPad: 18.w, tv32: 24.w, tv45: 30.w,
  );
  static double tournamentStatsPaddingV() => value(
    mobile: 7.h, tablet: 9.h, iPad: 11.h, tv32: 13.h, tv45: 16.h,
  );
  static double tournamentStatsTitleSize() => value(
    mobile: 10.sp, tablet: 13.sp, iPad: 37.sp, tv32: 21.sp, tv45: 25.sp,
  );
  static double tournamentStatsSubtitleSize() => value(
    mobile: 8.sp, tablet: 10.sp, iPad: 33.sp, tv32: 16.sp, tv45: 19.sp,
  );
  static double tournamentStatsIconSize() => value(
    mobile: 16.sp, tablet: 20.sp, iPad: 46.sp, tv32: 32.sp, tv45: 38.sp,
  );
  static double tournamentProgressWidth() => value(
    mobile: 80.w, tablet: 105.w, iPad: 240.w, tv32: 190.w, tv45: 240.w,
  );
  static double tournamentProgressHeight() => value(
    mobile: 5, tablet: 7, iPad: 15, tv32: 11, tv45: 13,
  );

  static double tournamentBracketPaddingH() => value(
    mobile: 10.w, tablet: 16.w, iPad: 22.w, tv32: 30.w, tv45: 40.w,
  );
  static double tournamentBracketPaddingV() => value(
    mobile: 6.h, tablet: 8.h, iPad: 10.h, tv32: 14.h, tv45: 18.h,
  );
  static double tournamentRoundWidth() => value(
    mobile: 180.w, tablet: 225.w, iPad: 400.w, tv32: 330.w, tv45: 400.w,
  );
  static double tournamentRoundSpacing() => value(
    mobile: 12.w, tablet: 18.w, iPad: 24.w, tv32: 32.w, tv45: 42.w,
  );
  static double tournamentRoundHeaderSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 35.sp, tv32: 19.sp, tv45: 23.sp,
  );
  static double tournamentRoundHeaderPaddingH() => value(
    mobile: 10.w, tablet: 13.w, iPad: 16.w, tv32: 20.w, tv45: 26.w,
  );
  static double tournamentRoundHeaderPaddingV() => value(
    mobile: 5.h, tablet: 6.h, iPad: 8.h, tv32: 10.h, tv45: 12.h,
  );
  static double tournamentRoundHeaderBottom() => value(
    mobile: 7.h, tablet: 9.h, iPad: 12.h, tv32: 16.h, tv45: 20.h,
  );

  static double tournamentMatchCardWidth() => tournamentRoundWidth();
  static double tournamentMatchSpacingV() => value(
    mobile: 3.h, tablet: 5.h, iPad: 7.h, tv32: 9.h, tv45: 12.h,
  );
  static double tournamentMatchHeaderFontSize() => value(
    mobile: 8.sp, tablet: 10.sp, iPad: 32.sp, tv32: 15.sp, tv45: 18.sp,
  );
  static double tournamentMatchStatusFontSize() => value(
    mobile: 7.sp, tablet: 9.sp, iPad: 31.sp, tv32: 13.sp, tv45: 16.sp,
  );
  static double tournamentMatchIconSize() => value(
    mobile: 11.sp, tablet: 14.sp, iPad: 38.sp, tv32: 22.sp, tv45: 27.sp,
  );
  static double tournamentPlayerFontSize() => value(
    mobile: 10.sp, tablet: 12.sp, iPad: 35.sp, tv32: 18.sp, tv45: 22.sp,
  );
  static double tournamentPlayerSlotPaddingH() => value(
    mobile: 7.w, tablet: 9.w, iPad: 12.w, tv32: 15.w, tv45: 19.w,
  );
  static double tournamentPlayerSlotPaddingV() => value(
    mobile: 6.h, tablet: 8.h, iPad: 10.h, tv32: 13.h, tv45: 16.h,
  );
  static double tournamentPlayerColorBarWidth() => value(
    mobile: 4.w, tablet: 5.w, iPad: 17.w, tv32: 9.w, tv45: 11.w,
  );
  static double tournamentPlayerColorBarHeight() => value(
    mobile: 15.h, tablet: 19.h, iPad: 40.h, tv32: 30.h, tv45: 36.h,
  );
  static double tournamentStartButtonFontSize() => value(
    mobile: 9.sp, tablet: 11.sp, iPad: 34.sp, tv32: 17.sp, tv45: 20.sp,
  );
  static double tournamentStartButtonIconSize() => value(
    mobile: 14.sp, tablet: 17.sp, iPad: 41.sp, tv32: 26.sp, tv45: 31.sp,
  );

  static double tournamentChampionDialogWidth() => value(
    mobile: 500.w, tablet: 620.w, iPad: 760.w, tv32: 900.w, tv45: 1080.w,
  );
  static double tournamentChampionDialogMaxHeight() => value(
    mobile: 0.88, tablet: 0.88, iPad: 0.86, tv32: 0.84, tv45: 0.82,
  );
  static double tournamentChampionPadding() => value(
    mobile: 20.w, tablet: 24.w, iPad: 30.w, tv32: 38.w, tv45: 46.w,
  );
  static double tournamentChampionTrophySize() => value(
    mobile: 72.sp, tablet: 90.sp, iPad: 150.sp, tv32: 145.sp, tv45: 175.sp,
  );
  static double tournamentChampionTitleSize() => value(
    mobile: 15.sp, tablet: 18.sp, iPad: 43.sp, tv32: 29.sp, tv45: 35.sp,
  );
  static double tournamentChampionNameSize() => value(
    mobile: 30.sp, tablet: 38.sp, iPad: 50.sp, tv32: 50.sp, tv45: 50.sp,
  );
  static double tournamentChampionStatLabelSize() => value(
    mobile: 8.sp, tablet: 10.sp, iPad: 33.sp, tv32: 33.sp, tv45: 33.sp,
  );
  static double tournamentChampionStatValueSize() => value(
    mobile: 14.sp, tablet: 17.sp, iPad: 42.sp, tv32: 42.sp, tv45: 42.sp,
  );

  // ============================================
  // DEBUG
  // ============================================
  static void debugPrintDevice() {
    final ctx = Get.context;
    if (ctx == null) return;
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;
    debugPrint('📱 Screen: ${w.toInt()}x${h.toInt()} → device=${device.name}');
  }
}
// lib/core/constants/asset_paths.dart

class AssetPaths {
  // ==========================================
  // LOTTIE ANIMATIONS
  // ==========================================
  static const String _lottieBase = 'assets/lottie';

 /* static const String lottieVictory = '$_lottieBase/victory.json';
  static const String lottieConfetti = '$_lottieBase/confetti.json';
  static const String lottieExplosion = '$_lottieBase/explosion.json';
  static const String lottieFire = '$_lottieBase/fire.json';
  static const String lottieStars = '$_lottieBase/stars.json';
  static const String lottieTrophy = '$_lottieBase/trophy.json';
  static const String lottieCountdown = '$_lottieBase/countdown.json';
  static const String lottieLoading = '$_lottieBase/loading.json';
  static const String lottieGameOver = '$_lottieBase/game_over.json';
  static const String lottieCombo = '$_lottieBase/combo.json';
  static const String lottieNeonGlow = '$_lottieBase/neon_glow.json';
  static const String lottieBallThrow = '$_lottieBase/ball_throw.json';*/

  // ==========================================
  // AUDIO
  // ==========================================
  static const String _audioBase = 'assets/audio';

  // ✅ NEW : sons distincts pour chaque valeur
  static const String audioScorePlus5   = '$_audioBase/score_plus_5.mp3';
  static const String audioScorePlus10  = '$_audioBase/score_plus_10.mp3';
  static const String audioScorePlus30  = '$_audioBase/score_plus_30.mp3';
  static const String audioScoreMinus5  = '$_audioBase/score_minus_5.mp3';
  static const String audioScoreMinus10 = '$_audioBase/score_minus_10.mp3';
  static const String audioScoreX2      = '$_audioBase/score_x2.mp3';
  static const String audioScoreX0      = '$_audioBase/score_x0.mp3';

  // Legacy (gardés pour fallback ou compat)
  static const String audioScorePositive = '$_audioBase/score_positive.mp3';
  static const String audioScoreNegative = '$_audioBase/score_negative.mp3';
  static const String audioScoreBonus    = '$_audioBase/score_bonus.mp3';

  // Autres sons (inchangés)
  static const String audioVictory       = '$_audioBase/victory.mp3';
  static const String audioGameOver      = '$_audioBase/game_over.mp3';
  static const String audioCountdown     = '$_audioBase/countdown.mp3';
  static const String audioCoinInsert    = '$_audioBase/coin_insert.mp3';
  static const String audioButtonPress   = '$_audioBase/button_press.mp3';
  static const String audioCombo         = '$_audioBase/combo.mp3';
  static const String audioOvershoot     = '$_audioBase/overshoot.mp3';
  static const String audioBgmNeon       = '$_audioBase/bgm_neon.mp3';
  static const String audioBgmEsports    = '$_audioBase/bgm_esports.mp3';
  static const String audioBgmCarnival   = '$_audioBase/bgm_carnival.mp3';
  static const String audioTurnChange    = '$_audioBase/turn_change.mp3';
  static const String audioCrowdCheer    = '$_audioBase/crowd_cheer.mp3';

  // ==========================================
  // IMAGES
  // ==========================================
  static const String _imgBase = 'assets/images';

  /*static const String imgLogo = '$_imgBase/triball_logo.png';
  static const String imgBoard = '$_imgBase/triball_board.png';
  static const String imgBgNeon = '$_imgBase/bg_neon.png';
  static const String imgBgEsports = '$_imgBase/bg_esports.png';
  static const String imgBgCarnival = '$_imgBase/bg_carnival.png';
  static const String imgBall = '$_imgBase/ball.png';*/

  // ==========================================
  // FONTS
  // ==========================================
  static const String fontPressStart = 'PressStart2P';
  static const String fontOrbitron = 'Orbitron';
  /*static const String fontRajdhani = 'Rajdhani';
  static const String fontExo2 = 'Exo2';
  static const String fontFredoka = 'FredokaOne';
  static const String fontBaloo = 'Baloo2';*/
  static const String fontPowerGrotesk = 'Power Grotesk';
}
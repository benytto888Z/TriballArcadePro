// lib/core/services/game_settings_service.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/game_constants.dart';

class GameSettingsService extends GetxService {
  final _storage = GetStorage();
  static const _keyTurnDuration = 'settings_turn_duration';
  static const _keyTurnWarning = 'settings_turn_warning';
  static const _keyTransitionDelay = 'settings_transition_delay';
  static const _keyLeaderboardDisplay = 'settings_leaderboard_display';

  static const _keyVictoryDisplay = 'settings_victory_display';

  final RxInt victoryDisplaySeconds =
      GameConstants.victoryDialogDisplaySeconds.obs;

  // ============================================
  // OBSERVABLES
  // ============================================
  final RxInt turnDurationSeconds = GameConstants.turnDurationSeconds.obs;
  final RxInt turnWarningSeconds = GameConstants.turnWarningSeconds.obs;
  final RxInt transitionDelaySeconds = 5.obs;

  // ✅ NEW : Durée d'affichage du leaderboard après victoire
  final RxInt leaderboardDisplaySeconds =
      GameConstants.defaultLeaderboardDisplaySeconds.obs;


  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    turnDurationSeconds.value =
        _storage.read(_keyTurnDuration) ?? GameConstants.turnDurationSeconds;
    turnWarningSeconds.value =
        _storage.read(_keyTurnWarning) ?? GameConstants.turnWarningSeconds;
    transitionDelaySeconds.value =
        _storage.read(_keyTransitionDelay) ?? 5;
    leaderboardDisplaySeconds.value =
        _storage.read(_keyLeaderboardDisplay) ??
            GameConstants.defaultLeaderboardDisplaySeconds;   // ✅ NEW

    victoryDisplaySeconds.value =
        _storage.read(_keyVictoryDisplay) ??
            GameConstants.victoryDialogDisplaySeconds;
  }

  Future<void> setVictoryDisplaySeconds(int seconds) async {
    final clamped = seconds.clamp(5, 60);
    victoryDisplaySeconds.value = clamped;
    await _storage.write(_keyVictoryDisplay, clamped);
  }

  // ✅ NEW
  Future<void> setLeaderboardDisplaySeconds(int seconds) async {
    final clamped = seconds.clamp(10, 120);
    leaderboardDisplaySeconds.value = clamped;
    await _storage.write(_keyLeaderboardDisplay, clamped);
  }

  // ============================================
  // SETTERS
  // ============================================
  Future<void> setTurnDuration(int seconds) async {
    final clamped = seconds.clamp(10, 120);
    turnDurationSeconds.value = clamped;
    await _storage.write(_keyTurnDuration, clamped);
  }

  Future<void> setTurnWarning(int seconds) async {
    final clamped = seconds.clamp(3, 30);
    turnWarningSeconds.value = clamped;
    await _storage.write(_keyTurnWarning, clamped);
  }

  Future<void> setTransitionDelay(int seconds) async {
    final clamped = seconds.clamp(2, 15);
    transitionDelaySeconds.value = clamped;
    await _storage.write(_keyTransitionDelay, clamped);
  }

  Future<void> resetToDefaults() async {
    await setTurnDuration(GameConstants.turnDurationSeconds);
    await setTurnWarning(GameConstants.turnWarningSeconds);
    await setTransitionDelay(5);
    await setLeaderboardDisplaySeconds(
        GameConstants.defaultLeaderboardDisplaySeconds);   // ✅ NEW
    await setVictoryDisplaySeconds(GameConstants.victoryDialogDisplaySeconds);

  }
}
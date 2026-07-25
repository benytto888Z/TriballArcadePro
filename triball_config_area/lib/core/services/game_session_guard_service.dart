import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../controllers/config_broadcaster_controller.dart';

/// Verrou global de Config Area pendant une session de jeu.
/// Fail-closed : une perte réseau ne déverrouille jamais l'interface.
class GameSessionGuardService extends GetxService {
  static const _storageKey = 'config_area_game_session_locked';
  static const adminSessionDuration = Duration(minutes: 2);

  final RxBool gameSessionActive = false.obs;
  final RxBool adminOverrideActive = false.obs;
  final RxString remoteState = 'unknown'.obs;
  final RxInt failedAttempts = 0.obs;
  final Rx<DateTime?> blockedUntil = Rx<DateTime?>(null);

  final GetStorage _storage = GetStorage();
  Worker? _statusWorker;
  Timer? _adminTimer;

  bool get isLocked =>
      gameSessionActive.value && !adminOverrideActive.value;
  bool get canConfigureGame => !gameSessionActive.value;
  bool get canUseAdminCommands =>
      !gameSessionActive.value || adminOverrideActive.value;

  @override
  void onInit() {
    super.onInit();
    gameSessionActive.value = _storage.read<bool>(_storageKey) ?? false;

    final broadcaster = Get.find<ConfigBroadcasterController>();
    _statusWorker = ever(broadcaster.remoteGameStatus, (status) {
      if (status != null) updateFromRemoteState(status.state);
    });
  }

  void updateFromRemoteState(String state) {
    remoteState.value = state;
    if (state == 'waiting') {
      unlockFromWaiting();
      return;
    }

    const activeStates = {
      'countdown',
      'playing',
      'paused',
      'turnTransition',
      'turn_transition',
      'victory',
      'leaderboard',
      'game_over',
    };
    if (activeStates.contains(state)) lockForGame(state);
  }

  void lockForGame([String state = 'countdown']) {
    remoteState.value = state;

    final wasAlreadyActive = gameSessionActive.value;
    gameSessionActive.value = true;
    _storage.write(_storageKey, true);

    // Une nouvelle partie démarre verrouillée. En revanche, les statuts
    // périodiques playing/paused/victory ne doivent jamais annuler une
    // session administrateur temporaire déjà accordée.
    if (!wasAlreadyActive) {
      adminOverrideActive.value = false;
      _adminTimer?.cancel();
    }

    if (kDebugMode) {
      print('🔒 Game state: $state | adminOverride=${adminOverrideActive.value}');
    }
  }

  void unlockFromWaiting() {
    _adminTimer?.cancel();
    adminOverrideActive.value = false;
    gameSessionActive.value = false;
    remoteState.value = 'waiting';
    failedAttempts.value = 0;
    blockedUntil.value = null;
    _storage.write(_storageKey, false);
    if (kDebugMode) print('🔓 Config Area unlocked (waiting confirmed)');
  }

  bool verifyAndGrantAdmin(String code, String expectedCode) {
    final blocked = blockedUntil.value;
    if (blocked != null && DateTime.now().isBefore(blocked)) return false;

    if (code != expectedCode) {
      failedAttempts.value++;
      if (failedAttempts.value >= 5) {
        blockedUntil.value = DateTime.now().add(const Duration(minutes: 1));
        failedAttempts.value = 0;
      }
      return false;
    }

    failedAttempts.value = 0;
    blockedUntil.value = null;
    adminOverrideActive.value = true;
    _adminTimer?.cancel();
    _adminTimer = Timer(adminSessionDuration, revokeAdminOverride);
    return true;
  }

  void revokeAdminOverride() {
    _adminTimer?.cancel();
    adminOverrideActive.value = false;
  }

  @override
  void onClose() {
    _statusWorker?.dispose();
    _adminTimer?.cancel();
    super.onClose();
  }
}

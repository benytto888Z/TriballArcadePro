// triball_game_area/lib/features/leaderboard/leaderboard_controller.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/asset_paths.dart';
import '../../core/constants/game_constants.dart';
import '../../core/controllers/platform_event_bus.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/avatar_storage_service.dart';
import '../../core/services/game_settings_service.dart';
import '../../core/theme/theme_colors.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../../data/models/platform_leaderboard_model.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../routes/app_routes.dart';

class LeaderboardController extends GetxController {
  final AudioService _audio = Get.find<AudioService>();
  final WebSocketController _ws = Get.find<WebSocketController>();
  final GameSettingsService _settings = Get.find<GameSettingsService>();
  late final LeaderboardRepository _repo;

  StreamSubscription<PlatformLeaderboardData>? _dataSub;
  StreamSubscription<Map<String, dynamic>>? _showLbSub;
  StreamSubscription<Map<String, dynamic>>? _changeFilterSub;
  StreamSubscription<void>? _showWaitingSub;

  // ============================================
  // OBSERVABLES
  // ============================================
  final Rx<GameMode> selectedMode = GameMode.classic.obs;
  final Rx<LeaderboardFilter> selectedFilter = LeaderboardFilter.all.obs;
  final RxList<LeaderboardEntryModel> allEntries =
      <LeaderboardEntryModel>[].obs;
  final RxList<LeaderboardEntryModel> filteredEntries =
      <LeaderboardEntryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isConnected = false.obs;
  final RxMap<String, dynamic> stats = <String, dynamic>{}.obs;

  late final AvatarStorageService _avatarStorage;

  // ✅ NEW : Auto-return timer
  Timer? _autoReturnTimer;
  final RxInt autoReturnCountdown = 0.obs;
  final RxBool autoReturnActive = false.obs;

  // ============================================
  // GETTERS
  // ============================================
  List<GameMode> get availableModes => [
    GameMode.classic,
    GameMode.hardcore,
    GameMode.champion,
    GameMode.combo,
  ];

  bool get isEmpty => filteredEntries.isEmpty;
  int get totalEntries => stats['totalEntries'] ?? 0;
  Duration? get bestTime => stats['bestTime'] as Duration?;
  int get avgBalls => stats['avgBalls'] ?? 0;
  int get uniquePlayers => stats['uniquePlayers'] ?? 0;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _repo = LeaderboardRepository();
    _avatarStorage = Get.find<AvatarStorageService>();
    _readInitialMode();

    ever(_ws.connectionState, (_) {
      isConnected.value = _ws.isConnected;
      if (_ws.isConnected) _loadCurrentMode();
    });
    isConnected.value = _ws.isConnected;

    // Écouter les données leaderboard
    _dataSub = PlatformEventBus.instance.onLeaderboardData.listen((data) {
      if (data.mode == selectedMode.value) {
        allEntries.value = data.entries;
        _applyFilter();
        _refreshStats();
        isLoading.value = false;
      }
    });

    // ✅ Écouter show_leaderboard (change de mode à distance)
    _showLbSub = PlatformEventBus.instance.onShowLeaderboard.listen((data) {
      final modeKey = data['mode'] as String? ?? 'classic';
      final mode = _resolveMode(modeKey);
      if (mode != selectedMode.value) {
        selectedMode.value = mode;
        _loadCurrentMode();
      }
      // ✅ Reset le auto-return quand on change de mode manuellement
      _cancelAutoReturn();
    });

    // ✅ Écouter change_filter (change le filtre date à distance)
    _changeFilterSub = PlatformEventBus.instance.onChangeFilter.listen((data) {
      final filterKey = data['filter'] as String? ?? 'all';
      final filter = _resolveFilter(filterKey);
      selectedFilter.value = filter;
      _applyFilter();
    });

    // ✅ Écouter show_waiting (retour)
    _showWaitingSub = PlatformEventBus.instance.onShowWaiting.listen((_) {
      _cancelAutoReturn();
      Get.offAllNamed(AppRoutes.waiting);
    });

    // ✅ Démarrer l'auto-return si demandé par les arguments
    _checkAutoReturn();

    if (_ws.isConnected) _loadCurrentMode();
  }

  @override
  void onClose() {
    _dataSub?.cancel();
    _showLbSub?.cancel();
    _changeFilterSub?.cancel();
    _showWaitingSub?.cancel();
    _autoReturnTimer?.cancel();
    super.onClose();
  }

  // ============================================
  // ✅ LIRE LE MODE INITIAL + AUTO-RETURN
  // ============================================
  void _readInitialMode() {
    final args = Get.arguments;

    if (args is GameMode) {
      selectedMode.value = args;
    } else if (args is String) {
      selectedMode.value = _resolveMode(args);
    } else if (args is Map) {
      // Mode + autoReturn (vient de la victoire)
      if (args['mode'] is GameMode) {
        selectedMode.value = args['mode'] as GameMode;
      } else if (args['mode'] is String) {
        selectedMode.value = _resolveMode(args['mode'] as String);
      }
    }
  }

  void _checkAutoReturn() {
    final args = Get.arguments;
    if (args is Map && args['autoReturn'] == true) {
      final duration = _settings.leaderboardDisplaySeconds.value;
      _startAutoReturn(duration);
    }
  }

  // ============================================
  // ✅ AUTO-RETURN TO WAITING
  // ============================================
  void _startAutoReturn(int seconds) {
    autoReturnActive.value = true;
    autoReturnCountdown.value = seconds;

    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      autoReturnCountdown.value--;
      if (autoReturnCountdown.value <= 0) {
        timer.cancel();
        autoReturnActive.value = false;
        Get.offAllNamed(AppRoutes.waiting);
      }
    });
  }

  void _cancelAutoReturn() {
    _autoReturnTimer?.cancel();
    autoReturnActive.value = false;
    autoReturnCountdown.value = 0;
  }

  // ============================================
  // HELPERS
  // ============================================
  GameMode _resolveMode(String key) {
    switch (key) {
      case 'classic':  return GameMode.classic;
      case 'hardcore': return GameMode.hardcore;
      case 'champion': return GameMode.champion;
      case 'combo':    return GameMode.combo;
      default:         return GameMode.classic;
    }
  }

  LeaderboardFilter _resolveFilter(String key) {
    switch (key) {
      case 'all':        return LeaderboardFilter.all;
      case 'today':      return LeaderboardFilter.today;
      case 'this_week':  return LeaderboardFilter.thisWeek;
      case 'this_month': return LeaderboardFilter.thisMonth;
      default:           return LeaderboardFilter.all;
    }
  }

  // ============================================
  // LOAD DATA
  // ============================================
  Future<void> _loadCurrentMode() async {
    isLoading.value = true;
    final entries = await _repo.fetchLeaderboard(
      selectedMode.value,
      forceRefresh: true,
    );
    allEntries.value = entries;
    _applyFilter();
    _refreshStats();
    isLoading.value = false;

    // ✅ Sync les avatars top 10 (supprime ceux qui ne sont plus dans le top)
    _syncTop10Avatars(entries);
  }

  void _syncTop10Avatars(List<LeaderboardEntryModel> entries) {
    try {
      final top10AvatarIds = entries
          .map((e) => e.avatarId ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      // ✅ Utilise le mode actuel
      final modeKey = selectedMode.value.key;
      _avatarStorage.syncTop10WithLeaderboard(
        gameMode: modeKey,
        top10AvatarIds: top10AvatarIds,
      );
    } catch (e) {
      if (kDebugMode) print('⚠️ Sync top 10 avatars error: $e');
    }
  }

  void _applyFilter() {
    filteredEntries.value = _repo.filterByDate(
      allEntries.toList(),
      selectedFilter.value,
    );
  }

  void _refreshStats() {
    stats.value = _repo.getStats(selectedMode.value);
  }

  // ============================================
  // ACTIONS
  // ============================================
  void selectMode(GameMode mode) {
    _audio.playSfx(AssetPaths.audioButtonPress);
    selectedMode.value = mode;
    _loadCurrentMode();
  }

  void selectFilter(LeaderboardFilter filter) {
    _audio.playSfx(AssetPaths.audioButtonPress);
    selectedFilter.value = filter;
    _applyFilter();
  }

  Future<void> refresh() async {
    _audio.playSfx(AssetPaths.audioButtonPress);
    await _loadCurrentMode();
  }

  Future<void> clearCurrentMode() async {
    _audio.playSfx(AssetPaths.audioButtonPress);
    await _repo.clearMode(selectedMode.value);
  }

  void reconnect() {
    _audio.playSfx(AssetPaths.audioButtonPress);
    _ws.reconnect();
  }

  void onBackPressed() {
    _cancelAutoReturn();
    _audio.playSfx(AssetPaths.audioButtonPress);
    Get.offAllNamed(AppRoutes.waiting);
  }

  Color rankColor(int position) {
    switch (position) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return ThemeColors.textSecondary;
    }
  }

  String rankEmoji(int position) {
    switch (position) {
      case 1: return '🥇';
      case 2: return '🥈';
      case 3: return '🥉';
      default: return '';
    }
  }
}
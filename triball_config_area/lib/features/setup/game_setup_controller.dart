// triball_config_area/lib/features/setup/game_setup_controller.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/constants/asset_paths.dart';
import '../../core/controllers/config_broadcaster_controller.dart';
import '../../core/controllers/websocket_controller.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/avatar_capture_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/theme_colors.dart';
import '../../core/utils/helpers.dart';
import '../../data/models/game_config_model.dart';
import '../../data/models/game_state_model.dart';
import '../../data/models/match_type_model.dart';
import '../../routes/app_routes.dart';

class GameSetupController extends GetxController {
  // ============================================
  // DEPENDENCIES
  // ============================================
  final AudioService _audio = Get.find<AudioService>();
  final StorageService _storage = Get.find<StorageService>();
  final ConfigBroadcasterController _broadcaster =
  Get.find<ConfigBroadcasterController>();

  // ============================================
  // NAVIGATION (PageView)
  // ============================================
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxInt totalPages = 3.obs;
  final RxBool matchTypePreselected = false.obs;

  /// ✅ Avatars capturés (index joueur → base64)
  final RxMap<int, String> playerAvatars = <int, String>{}.obs;

  // ============================================
  // OBSERVABLE STATE
  // ============================================
  final Rx<MatchType> selectedMatchType = MatchType.competition.obs;
  final Rx<GameMode> selectedMode = GameMode.classic.obs;
  final RxList<String> playerNames = <String>['Player 1', 'Player 2'].obs;
  final RxList<String> recentPlayerNames = <String>[].obs;
  final RxBool ttsEnabled = true.obs;
  final RxBool soundEnabled = true.obs;
  final RxBool overshootBounce = false.obs;

  // ✅ NEW : État d'envoi
  final RxBool isSending = false.obs;
  final RxBool sendSuccess = false.obs;
  final RxString sendError = ''.obs;

  // Text controllers per player slot
  final List<TextEditingController> _textControllers = [];

  // ============================================
  // GETTERS
  // ============================================
  int get playerCount => playerNames.length;
  int get maxPlayers => selectedMatchType.value.maxPlayers;
  int get minPlayers => selectedMatchType.value.minPlayers;
  int get targetScore => selectedMode.value.targetScore;

  bool get isSoloMode => selectedMatchType.value == MatchType.soloChrono;
  bool get isCompetitionMode =>
      selectedMatchType.value == MatchType.competition;
  bool get isTournamentMode =>
      selectedMatchType.value == MatchType.tournament;

  bool get canStart {
    if (playerNames.isEmpty) return false;
    if (playerNames.length < minPlayers) return false;
    if (playerNames.length > maxPlayers) return false;
    if (isTournamentMode) {
      if (!selectedMatchType.value.allowedSizes
          .contains(playerNames.length)) {
        return false;
      }
    }
    return playerNames.every((n) => n.trim().isNotEmpty);
  }

  /// ✅ Peut-on envoyer ? (config valide + Game Area connectée)
  bool get canSendToGameArea =>
      canStart && _broadcaster.hasGameAreaConnected;

  /// ✅ Raison si on ne peut pas envoyer
  String get cannotSendReason {
    if (!canStart) return 'error_invalid_name'.tr;
    if (!_broadcaster.hasGameAreaConnected) {
      return 'no_game_area_connected'.tr;
    }
    return '';
  }

  List<GameMode> get availableModes => [
    GameMode.classic,
    GameMode.hardcore,
    GameMode.champion,
    GameMode.combo,
  ];

  List<MatchType> get availableMatchTypes => [
    MatchType.competition,
    MatchType.soloChrono,
    MatchType.tournament,
  ];

  int get displayPageNumber {
    if (matchTypePreselected.value) return currentPage.value;
    return currentPage.value + 1;
  }

  int get displayTotalPages {
    return matchTypePreselected.value ? 2 : 3;
  }

  bool get isFirstPage => currentPage.value == 0;
  bool get isLastPage => currentPage.value == totalPages.value - 1;

  bool get canGoNext {
    switch (currentPage.value) {
      case 0: return true;
      case 1: return true;
      case 2: return canStart;
      default: return false;
    }
  }

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _loadRecentPlayers();
    _readArgumentsFromHome();
    _adjustPlayerNamesForMatchType();
    _ensureTextControllers();
    _setupInitialPage();
  }

  @override
  void onClose() {
    pageController.dispose();
    for (final c in _textControllers) {
      c.dispose();
    }
    super.onClose();
  }

  void _loadRecentPlayers() {
    recentPlayerNames.value = _storage.getRecentPlayerNames();
  }

  void _readArgumentsFromHome() {
    final args = Get.arguments;
    if (args is MatchType) {
      selectedMatchType.value = args;
      matchTypePreselected.value = true;
    } else if (args is Map && args['matchType'] is MatchType) {
      selectedMatchType.value = args['matchType'] as MatchType;
      matchTypePreselected.value = true;
      if (args['mode'] is GameMode) {
        selectedMode.value = args['mode'] as GameMode;
      }
    }
  }

  void _setupInitialPage() {
    if (matchTypePreselected.value) {
      currentPage.value = 1;
      totalPages.value = 3;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(1);
        }
      });
    }
  }

  // ============================================
  // NAVIGATION
  // ============================================
  void nextPage() {
    _audio.playSfx(AssetPaths.audioButtonPress);

    if (isLastPage) {
      // ✅ Dernière page → envoi au lieu de démarrer
      sendToGameArea();
      return;
    }

    if (!canGoNext) return;

    pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void previousPage() {
    _audio.playSfx(AssetPaths.audioButtonPress);

    if (matchTypePreselected.value && currentPage.value <= 1) {
      Get.back();
      return;
    }

    if (isFirstPage) {
      Get.back();
      return;
    }

    pageController.previousPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int page) {
    currentPage.value = page;
  }

  // ============================================
  // PLAYER MANAGEMENT
  // ============================================
  void _adjustPlayerNamesForMatchType() {
    final min = selectedMatchType.value.minPlayers;
    final max = selectedMatchType.value.maxPlayers;

    if (playerNames.length > max) {
      playerNames.value = playerNames.take(max).toList();
    }

    while (playerNames.length < min) {
      playerNames.add('Player ${playerNames.length + 1}');
    }

    if (isTournamentMode) {
      final currentSize = playerNames.length;
      final allowed = selectedMatchType.value.allowedSizes;
      if (!allowed.contains(currentSize)) {
        final target = allowed.firstWhere(
              (s) => s >= currentSize,
          orElse: () => allowed.first,
        );
        setPlayerCount(target);
      }
    }
  }

  void _ensureTextControllers() {
    while (_textControllers.length < playerNames.length) {
      final idx = _textControllers.length;
      final ctrl = TextEditingController(text: playerNames[idx]);
      ctrl.addListener(() {
        if (idx < playerNames.length) {
          playerNames[idx] = ctrl.text;
        }
      });
      _textControllers.add(ctrl);
    }
    while (_textControllers.length > playerNames.length) {
      _textControllers.removeLast().dispose();
    }
  }

  TextEditingController getTextControllerFor(int index) {
    _ensureTextControllers();
    return _textControllers[index];
  }

  void selectMatchType(MatchType type) {
    _audio.playSfx(AssetPaths.audioButtonPress);
    selectedMatchType.value = type;
    _adjustPlayerNamesForMatchType();
    _ensureTextControllers();
  }

  void selectMode(GameMode mode) {
    _audio.playSfx(AssetPaths.audioButtonPress);
    selectedMode.value = mode;
  }

  void addPlayer() {
    if (playerNames.length >= maxPlayers) {
      Helpers.showSnackbar(
        'warning'.tr,
        'error_too_many_players'.tr,
        color: Colors.orange,
      );
      return;
    }
    _audio.playSfx(AssetPaths.audioButtonPress);
    playerNames.add('Player ${playerNames.length + 1}');
    _ensureTextControllers();
  }

  void removePlayer(int index) {
    if (playerNames.length <= minPlayers) return;
    _audio.playSfx(AssetPaths.audioButtonPress);
    playerNames.removeAt(index);
    _ensureTextControllers();
  }

  void updatePlayerName(int index, String name) {
    if (index >= 0 && index < playerNames.length) {
      playerNames[index] = name;
    }
  }

  void setPlayerCount(int count) {
    final target = count.clamp(minPlayers, maxPlayers);
    if (target == playerNames.length) return;
    _audio.playSfx(AssetPaths.audioButtonPress);

    if (target > playerNames.length) {
      while (playerNames.length < target) {
        playerNames.add('Player ${playerNames.length + 1}');
      }
    } else {
      playerNames.removeRange(target, playerNames.length);
    }
    _ensureTextControllers();
  }

  void applyRecentName(int slotIndex, String name) {
    if (slotIndex < 0 || slotIndex >= playerNames.length) return;
    _audio.playSfx(AssetPaths.audioButtonPress);
    playerNames[slotIndex] = name;
    _textControllers[slotIndex].text = name;
  }

  // ============================================
  // OPTIONS
  // ============================================
  void toggleTts() {
    _audio.playSfx(AssetPaths.audioButtonPress);
    ttsEnabled.toggle();
  }

  void toggleSound() {
    _audio.playSfx(AssetPaths.audioButtonPress);
    soundEnabled.toggle();
  }

  void toggleOvershootBounce() {
    _audio.playSfx(AssetPaths.audioButtonPress);
    overshootBounce.toggle();
  }

  // ============================================
  // ✅ SEND TO GAME AREA (au lieu de startGame)
  // ============================================
  Future<void> sendToGameArea() async {
    // Guard 1 : Config valide
    if (!canStart) {
      Helpers.showSnackbar(
        'error'.tr,
        'error_invalid_name'.tr,
        color: Colors.red,
      );
      return;
    }

    // Guard 2 : Game Area connectée
    if (!_broadcaster.hasGameAreaConnected) {
      _showNoGameAreaDialog();
      return;
    }

    isSending.value = true;
    sendSuccess.value = false;
    sendError.value = '';

    _audio.playSfx(AssetPaths.audioCoinInsert);

    // Save player names to recents
    for (final name in playerNames) {
      await _storage.addRecentPlayerName(name.trim());
    }

    // Build config
    final trimmedNames = playerNames.map((n) => n.trim()).toList();
    late GameConfig config;

    switch (selectedMatchType.value) {
      case MatchType.competition:
        config = GameConfig.competition(
          mode: selectedMode.value,
          players: trimmedNames,
          overshootRule: overshootBounce.value
              ? OvershootRule.bounce
              : (selectedMode.value == GameMode.hardcore
              ? OvershootRule.hardcoreOvershoot
              : OvershootRule.refuse),
          ttsEnabled: ttsEnabled.value,
          soundEnabled: soundEnabled.value,
        );
        break;

      case MatchType.soloChrono:
        config = GameConfig.soloChrono(
          mode: selectedMode.value,
          playerName: trimmedNames.first,
          overshootRule: overshootBounce.value
              ? OvershootRule.bounce
              : (selectedMode.value == GameMode.hardcore
              ? OvershootRule.hardcoreOvershoot
              : OvershootRule.refuse),
          ttsEnabled: ttsEnabled.value,
          soundEnabled: soundEnabled.value,
        );
        break;

      case MatchType.tournament:
        config = GameConfig.tournament(
          mode: selectedMode.value,
          players: trimmedNames,
          overshootRule: overshootBounce.value
              ? OvershootRule.bounce
              : (selectedMode.value == GameMode.hardcore
              ? OvershootRule.hardcoreOvershoot
              : OvershootRule.refuse),
          ttsEnabled: ttsEnabled.value,
          soundEnabled: soundEnabled.value,
        );
        break;
    }

    // ✅ Envoi via broadcaster
    final success = await _broadcaster.sendGameConfig(config);

    isSending.value = false;

    if (success) {
      sendSuccess.value = true;
      _audio.playSfx(AssetPaths.audioVictory);
      _showSendConfirmationDialog(config);
      // ✅ Envoie les avatars après la config
      _sendAvatars();
    } else {
      sendError.value = 'config_send_failed'.tr;
      Helpers.showSnackbar(
        'error'.tr,
        'config_send_failed'.tr,
        color: Colors.red,
      );
    }
  }

  void _sendAvatars() {
    final ws = Get.find<WebSocketController>();
    final avatarService = Get.find<AvatarCaptureService>();
    final trimmedNames = playerNames.map((n) => n.trim()).toList();

    for (int i = 0; i < trimmedNames.length; i++) {
      final url = avatarService.getAvatarUrl(i);
      if (url != null) {
        ws.sendPlayerAvatar(
          playerName: trimmedNames[i],
          avatarUrl: url,           // ✅ URL au lieu de base64
          playerIndex: i,
        );
      }
    }

    if (kDebugMode) {
      print('📸 Avatar URLs sent to Game Area');
    }
  }

  // ============================================
  // ✅ DIALOGS
  // ============================================

  /// Dialog quand pas de Game Area connectée
  void _showNoGameAreaDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.tv_off, color: ThemeColors.warning),
            const SizedBox(width: 8),
            Text(
              'no_game_area_title'.tr,
              style: TextStyle(color: ThemeColors.warning),
            ),
          ],
        ),
        content: Text(
          'no_game_area_message'.tr,
          style: TextStyle(color: ThemeColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  /// ✅ Définit l'avatar d'un joueur
  void setPlayerAvatar(int index, String base64) {
    playerAvatars[index] = base64;
    if (kDebugMode) {
      print('📸 Avatar set for player $index (${base64.length} chars)');
    }
  }

  /// ✅ Supprime l'avatar d'un joueur
  void removePlayerAvatar(int index) {
    playerAvatars.remove(index);
  }

  /// ✅ Vérifie si un joueur a un avatar
  bool hasAvatar(int index) => playerAvatars.containsKey(index);

  /// Dialog de confirmation après envoi réussi
  void _showSendConfirmationDialog(GameConfig config) {
    Get.dialog(
      AlertDialog(
        backgroundColor: ThemeColors.surface,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: ThemeColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'config_sent_title'.tr,
                style: TextStyle(color: ThemeColors.success),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'config_sent_message'.tr,
              style: TextStyle(color: ThemeColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _ConfigSummaryRow(
              icon: Icons.category,
              label: 'match_type'.tr,
              value: config.matchType.translationKey.tr,
            ),
            const SizedBox(height: 4),
            _ConfigSummaryRow(
              icon: Icons.videogame_asset,
              label: 'game_mode'.tr,
              value: '${config.mode.icon} ${config.mode.translationKey.tr}',
            ),
            const SizedBox(height: 4),
            _ConfigSummaryRow(
              icon: Icons.group,
              label: 'players'.tr,
              value: config.playerNames.join(', '),
            ),
            const SizedBox(height: 4),
            _ConfigSummaryRow(
              icon: Icons.flag,
              label: 'target'.tr,
              value: '${config.targetScore} pts',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              // Retour au home pour pouvoir envoyer une autre config
              Get.offAllNamed(AppRoutes.home);
            },
            child: Text(
              'back_to_menu'.tr,
              style: TextStyle(color: ThemeColors.textSecondary),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back();
              // Reste sur le setup pour renvoyer une config
            },
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('send_another'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void onBackPressed() {
    _audio.playSfx(AssetPaths.audioButtonPress);
    Get.back();
  }
}

// ============================================================
// CONFIG SUMMARY ROW (pour le dialog de confirmation)
// ============================================================
class _ConfigSummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfigSummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ThemeColors.primary, size: 14),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 11,
            color: ThemeColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: ThemeColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
// lib/core/services/audio_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import '../constants/audio_constants.dart';

/// Service audio professionnel avec pool de players SFX
/// pour permettre plusieurs sons simultanés sans coupure
class AudioService extends GetxService {
  // ============================================
  // POOL DE SFX PLAYERS
  // ============================================
  late final List<AudioPlayer> _sfxPool;
  int _nextSfxIndex = 0;

  // BGM dédié
  late final AudioPlayer _bgmPlayer;

  // Storage
  final _storage = GetStorage();

  // ============================================
  // OBSERVABLES — Volumes et toggles
  // ============================================
  final RxBool soundEnabled = true.obs;
  final RxBool musicEnabled = true.obs;
  final RxDouble sfxVolume = AudioConstants.defaultSfxVolume.obs;
  final RxDouble musicVolume = AudioConstants.defaultBgmVolume.obs;

  // État interne BGM
  String? _currentBgmPath;
  bool _bgmIsPlaying = false;

  // ============================================
  // STATIC INIT (à appeler avant runApp)
  // ============================================
  static void registerWith() {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      JustAudioMediaKit.ensureInitialized(
        windows: true,
        linux: true,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initPool();
    _initBgmPlayer();
    _loadSettings();
  }

  void _initPool() {
    _sfxPool = List.generate(
      AudioConstants.sfxPoolSize,
          (_) => AudioPlayer(),
    );
  }

  void _initBgmPlayer() {
    _bgmPlayer = AudioPlayer();
    _bgmPlayer.setLoopMode(LoopMode.all);
  }

  void _loadSettings() {
    soundEnabled.value = _storage.read('sound_enabled') ?? true;
    musicEnabled.value = _storage.read('music_enabled') ?? true;
    sfxVolume.value =
        (_storage.read('sfx_volume') ?? AudioConstants.defaultSfxVolume)
            .toDouble();
    musicVolume.value =
        (_storage.read('music_volume') ?? AudioConstants.defaultBgmVolume)
            .toDouble();
  }

  final Map<String, bool> _assetAvailability = {};

  /// Vérifie l'existence avant de transmettre le chemin à MediaKit.
  /// Cela évite l'erreur native peu explicite "Failed to recognize file format"
  /// lorsqu'un asset déclaré dans AssetPaths n'existe pas dans le bundle.
  Future<bool> _assetExists(String path) async {
    final cached = _assetAvailability[path];
    if (cached != null) return cached;
    try {
      await rootBundle.load(path);
      _assetAvailability[path] = true;
      return true;
    } catch (_) {
      _assetAvailability[path] = false;
      if (kDebugMode) print('🔇 Audio asset missing: $path');
      return false;
    }
  }

  // ============================================
  // SFX — Pool round-robin
  // ============================================
  /// Joue un SFX en utilisant le pool (permet plusieurs sons simultanés)
  Future<void> playSfx(String assetPath, {double? volumeOverride}) async {
    if (!soundEnabled.value) return;
    if (!await _assetExists(assetPath)) return;

    try {
      final player = _sfxPool[_nextSfxIndex];
      _nextSfxIndex = (_nextSfxIndex + 1) % AudioConstants.sfxPoolSize;

      await player.stop();
      await player.setAsset(assetPath);
      await player.setVolume(volumeOverride ?? sfxVolume.value);
      await player.play();
    } catch (e) {
      if (kDebugMode) print('🔇 SFX error ($assetPath): $e');
    }
  }

  /// Joue plusieurs SFX en parallèle avec délais
  Future<void> playSfxSequence(List<String> assetPaths,
      {Duration interval = const Duration(milliseconds: 100)}) async {
    for (final path in assetPaths) {
      playSfx(path);
      await Future.delayed(interval);
    }
  }

  // ============================================
  // BGM (Background Music)
  // ============================================
  Future<void> playBgm(String assetPath) async {
    if (!musicEnabled.value) {
      _currentBgmPath = assetPath; // Mémorise pour resume
      return;
    }
    if (_currentBgmPath == assetPath && _bgmIsPlaying) return;
    if (!await _assetExists(assetPath)) return;

    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.setAsset(assetPath);
      await _bgmPlayer.setLoopMode(LoopMode.all);
      await _bgmPlayer.setVolume(musicVolume.value);
      await _bgmPlayer.play();
      _currentBgmPath = assetPath;
      _bgmIsPlaying = true;
    } catch (e) {
      if (kDebugMode) print('🔇 BGM error ($assetPath): $e');
    }
  }

  Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      _bgmIsPlaying = false;
    } catch (_) {}
  }

  Future<void> pauseBgm() async {
    try {
      await _bgmPlayer.pause();
      _bgmIsPlaying = false;
    } catch (_) {}
  }

  Future<void> resumeBgm() async {
    if (!musicEnabled.value) return;
    try {
      if (_currentBgmPath != null) {
        await _bgmPlayer.play();
        _bgmIsPlaying = true;
      }
    } catch (_) {}
  }

  // ============================================
  // TOGGLES
  // ============================================
  void toggleSound() {
    soundEnabled.value = !soundEnabled.value;
    _storage.write('sound_enabled', soundEnabled.value);
    if (!soundEnabled.value) {
      _stopAllSfx();
    }
  }

  void toggleMusic() {
    musicEnabled.value = !musicEnabled.value;
    _storage.write('music_enabled', musicEnabled.value);
    if (!musicEnabled.value) {
      stopBgm();
    } else if (_currentBgmPath != null) {
      playBgm(_currentBgmPath!);
    }
  }

  Future<void> _stopAllSfx() async {
    for (final player in _sfxPool) {
      try {
        await player.stop();
      } catch (_) {}
    }
  }

  // ============================================
  // VOLUMES
  // ============================================
  Future<void> setSfxVolume(double v) async {
    sfxVolume.value = v.clamp(
      AudioConstants.minVolume,
      AudioConstants.maxVolume,
    );
    await _storage.write('sfx_volume', sfxVolume.value);
  }

  Future<void> setMusicVolume(double v) async {
    musicVolume.value = v.clamp(
      AudioConstants.minVolume,
      AudioConstants.maxVolume,
    );
    await _storage.write('music_volume', musicVolume.value);
    try {
      await _bgmPlayer.setVolume(musicVolume.value);
    } catch (_) {}
  }

  // ============================================
  // CLEANUP
  // ============================================
  @override
  void onClose() {
    for (final player in _sfxPool) {
      try {
        player.dispose();
      } catch (_) {}
    }
    try {
      _bgmPlayer.dispose();
    } catch (_) {}
    super.onClose();
  }
}
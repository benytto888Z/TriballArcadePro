// lib/core/services/storage_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../data/models/leaderboard_entry_model.dart';
import '../constants/game_constants.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  // ============================================
  // ✅ VERSION MIGRATION
  // ============================================
  static const String _storageVersionKey = 'storage_version';
  static const int _currentStorageVersion = 2;   // ✅ Bumped

  @override
  void onInit() {
    super.onInit();
    _migrate();
  }

  void _migrate() {
    final currentVersion = _box.read<int>(_storageVersionKey) ?? 1;

    if (currentVersion < 2) {
      // ✅ MIGRATION v1 → v2 : nouveau format leaderboard avec matchType
      // Option A retenue : on efface simplement les anciennes données
      if (kDebugMode) {
        print('📦 Migrating storage from v$currentVersion to v$_currentStorageVersion');
      }
      _clearOldLeaderboard();
      _box.write(_storageVersionKey, _currentStorageVersion);
    }
  }

  void _clearOldLeaderboard() {
    // Efface l'ancien leaderboard local (sans matchType)
    _box.remove(GameConstants.leaderboardStorageKey);
    // ✅ Note: le nouveau top 10 est stocké sur ESP32 via Preferences.h
    if (kDebugMode) {
      print('📦 Old leaderboard cleared. New top 10 will be stored on ESP32.');
    }
  }

  // ============================================
  // GENERIC
  // ============================================
  T? read<T>(String key) => _box.read<T>(key);
  Future<void> write(String key, dynamic value) => _box.write(key, value);
  Future<void> remove(String key) => _box.remove(key);
  Future<void> clearAll() => _box.erase();

  // ============================================
  // ⚠️ LEADERBOARD LOCAL (DEPRECATED)
  // Les nouveaux top 10 sont stockés sur ESP32.
  // Ces méthodes restent pour compat backward mais ne sont plus utilisées.
  // ============================================
  @Deprecated('Leaderboard is now stored on ESP32 via Preferences.h')
  List<LeaderboardEntryModel> getLeaderboard() {
    final raw = _box.read<String>(GameConstants.leaderboardStorageKey);
    if (raw == null) return [];
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => LeaderboardEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) print('💾 Leaderboard parse error: $e');
      return [];
    }
  }

  @Deprecated('Leaderboard is now stored on ESP32 via Preferences.h')
  Future<void> saveLeaderboard(List<LeaderboardEntryModel> entries) async {
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await _box.write(GameConstants.leaderboardStorageKey, raw);
  }

  @Deprecated('Leaderboard is now stored on ESP32 via Preferences.h')
  Future<bool> addLeaderboardEntry(LeaderboardEntryModel entry) async {
    final list = getLeaderboard();
    list.add(entry);
    list.sort((a, b) => a.completionTime.compareTo(b.completionTime));
    final top = list.take(GameConstants.topLeaderboardSize).toList();
    await saveLeaderboard(top);
    return top.contains(entry);
  }

  Future<void> clearLeaderboard() async {
    await _box.remove(GameConstants.leaderboardStorageKey);
  }

  // ============================================
  // PLAYER NAMES (history) — INCHANGÉ
  // ============================================
  List<String> getRecentPlayerNames() {
    final list = _box.read<List>('recent_player_names');
    if (list == null) return [];
    return list.cast<String>();
  }

  Future<void> addRecentPlayerName(String name) async {
    if (name.trim().isEmpty) return;
    final list = getRecentPlayerNames();
    list.remove(name);
    list.insert(0, name);
    final trimmed = list.take(20).toList();
    await _box.write('recent_player_names', trimmed);
  }
}
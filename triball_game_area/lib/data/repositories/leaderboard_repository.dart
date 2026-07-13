// lib/data/repositories/leaderboard_repository.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/controllers/platform_event_bus.dart';
import '../../core/controllers/websocket_controller.dart';
import '../models/game_state_model.dart';
import '../models/leaderboard_entry_model.dart';
import '../models/platform_leaderboard_model.dart';

enum LeaderboardFilter {
  all,
  today,
  thisWeek,
  thisMonth,
}

extension LeaderboardFilterX on LeaderboardFilter {
  String get translationKey {
    switch (this) {
      case LeaderboardFilter.all:       return 'filter_all_time';
      case LeaderboardFilter.today:     return 'filter_today';
      case LeaderboardFilter.thisWeek:  return 'filter_this_week';
      case LeaderboardFilter.thisMonth: return 'filter_this_month';
    }
  }
}

/// Repository qui communique avec le leaderboard ESP32 via WebSocket.
/// Les données sont récupérées à la demande et cachées en mémoire.
class LeaderboardRepository {
  final WebSocketController _ws = Get.find<WebSocketController>();
  final PlatformEventBus _bus = PlatformEventBus.instance;

  // Cache en mémoire par mode
  final Map<GameMode, List<LeaderboardEntryModel>> _cache = {};
  final Map<GameMode, DateTime> _cacheTimestamp = {};

  // Timeout pour la réponse WebSocket
  static const Duration _responseTimeout = Duration(seconds: 3);

  // ============================================
  // ✅ REQUEST LEADERBOARD (async avec timeout)
  // ============================================
  Future<List<LeaderboardEntryModel>> fetchLeaderboard(
      GameMode mode, {
        bool forceRefresh = false,
      }) async {
    // Retourne le cache si récent (< 30s)
    if (!forceRefresh &&
        _cache.containsKey(mode) &&
        _cacheTimestamp[mode] != null &&
        DateTime.now().difference(_cacheTimestamp[mode]!).inSeconds < 30) {
      return _cache[mode]!;
    }

    // Si pas connecté, retourne le cache ou vide
    if (!_ws.isConnected) {
      return _cache[mode] ?? [];
    }

    // Demande à l'ESP32 et attend la réponse via le bus
    final completer = Completer<List<LeaderboardEntryModel>>();
    late StreamSubscription sub;

    sub = _bus.onLeaderboardData.listen((data) {
      if (data.mode == mode) {
        _cache[mode] = data.entries;
        _cacheTimestamp[mode] = DateTime.now();
        if (!completer.isCompleted) {
          completer.complete(data.entries);
        }
        sub.cancel();
      }
    });

    // Envoie la requête
    _ws.requestLeaderboard(mode);

    // Timeout
    try {
      return await completer.future.timeout(_responseTimeout);
    } catch (e) {
      sub.cancel();
      if (kDebugMode) print('⚠️ Leaderboard fetch timeout: $e');
      return _cache[mode] ?? [];
    }
  }

  // ============================================
  // FILTER BY DATE (sur les données déjà en cache)
  // ============================================
  List<LeaderboardEntryModel> filterByDate(
      List<LeaderboardEntryModel> entries,
      LeaderboardFilter filter,
      ) {
    final now = DateTime.now();
    DateTime? cutoff;

    switch (filter) {
      case LeaderboardFilter.all:
        return entries;
      case LeaderboardFilter.today:
        cutoff = DateTime(now.year, now.month, now.day);
        break;
      case LeaderboardFilter.thisWeek:
        final weekday = now.weekday;
        cutoff = DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: weekday - 1));
        break;
      case LeaderboardFilter.thisMonth:
        cutoff = DateTime(now.year, now.month, 1);
        break;
    }

    return entries.where((e) => e.date.isAfter(cutoff!)).toList();
  }

  // ============================================
  // SUBMIT SCORE (via WebSocket)
  // ============================================

  Future<bool> submitScore({
    required String playerName,
    required Duration completionTime,
    required int totalBalls,
    required GameMode gameMode,
  }) async {
    if (!_ws.isConnected) {
      if (kDebugMode) print('❌ LeaderboardRepo.submitScore: not connected');
      return false;
    }

    if (kDebugMode) {
      print('📤 LeaderboardRepo.submitScore:');
      print('   player=$playerName');
      print('   time=${completionTime.inMilliseconds}ms');
      print('   balls=$totalBalls');
      print('   mode=${gameMode.key}');
    }

    _ws.submitScore(
      mode: gameMode,
      playerName: playerName,
      timeMs: completionTime.inMilliseconds,
      balls: totalBalls,
      date: DateTime.now(),
    );

    // Invalide le cache
    _cache.remove(gameMode);
    _cacheTimestamp.remove(gameMode);

    return true;
  }

  // ============================================
  // WOULD QUALIFY (sur cache local)
  // ============================================
  bool wouldQualify(GameMode mode, Duration time) {
    final cached = _cache[mode];
    if (cached == null || cached.length < 10) return true;
    return time < cached.last.completionTime;
  }

  // ============================================
  // CLEAR
  // ============================================
  Future<bool> clearMode(GameMode mode) async {
    if (!_ws.isConnected) return false;
    _ws.clearLeaderboard(mode);
    _cache.remove(mode);
    _cacheTimestamp.remove(mode);
    return true;
  }

  Future<bool> clearAll() async {
    if (!_ws.isConnected) return false;
    _ws.clearAllLeaderboards();
    _cache.clear();
    _cacheTimestamp.clear();
    return true;
  }

  // ============================================
  // STATS (calculées sur cache local)
  // ============================================
  Map<String, dynamic> getStats(GameMode mode) {
    final entries = _cache[mode] ?? [];
    if (entries.isEmpty) {
      return {
        'totalEntries': 0,
        'bestTime': null,
        'avgBalls': 0,
        'uniquePlayers': 0,
      };
    }

    final players = entries.map((e) => e.playerName).toSet();
    final totalBalls = entries.fold<int>(0, (sum, e) => sum + e.totalBalls);
    final avgBalls = (totalBalls / entries.length).round();

    return {
      'totalEntries': entries.length,
      'bestTime': entries.first.completionTime,
      'avgBalls': avgBalls,
      'uniquePlayers': players.length,
    };
  }
}
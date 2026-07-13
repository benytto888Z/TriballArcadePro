// triball_game_area/lib/core/services/avatar_storage_service.dart

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/platform_event_bus.dart';

class AvatarStorageService extends GetxService {
  // ============================================
  // MÉMOIRE — Avatars de la partie en cours
  // ============================================
  final RxMap<String, String> currentAvatarUrls = <String, String>{}.obs;
  final RxMap<int, String> currentAvatarUrlsByIndex = <int, String>{}.obs;
  final Map<String, Uint8List> _cachedBytes = {};

  // ============================================
  // DISQUE — Dossier avatars
  // ============================================
  String? _avatarsDir;

  StreamSubscription<Map<String, dynamic>>? _avatarSub;
  StreamSubscription<void>? _clearSub;

  // ============================================
  // LIFECYCLE
  // ============================================
  @override
  void onInit() {
    super.onInit();
    _cleanOldGetStorageAvatars();
    _initAvatarsDir();
    _listenToAvatars();
  }

  @override
  void onClose() {
    _avatarSub?.cancel();
    _clearSub?.cancel();
    super.onClose();
  }

  // ============================================
  // ✅ NETTOYAGE ANCIEN SYSTÈME (GetStorage Base64)
  // ============================================
  void _cleanOldGetStorageAvatars() {
    try {
      final storage = GetStorage();
      const oldKey = 'top10_avatars';
      if (storage.read(oldKey) != null) {
        storage.remove(oldKey);
        if (kDebugMode) print('🧹 Old Base64 avatars removed from GetStorage');
      }
    } catch (_) {}
  }

  // ============================================
  // ✅ INIT DOSSIER AVATARS — À côté de l'exe
  // ============================================
  Future<void> _initAvatarsDir() async {
    try {
      String avatarsPath;

      // ✅ Stratégie multi-niveaux
      if (Platform.isWindows) {
        // Niveau 1 : À côté de l'exe
        try {
          final exeDir = File(Platform.resolvedExecutable).parent.path;
          avatarsPath = '$exeDir\\avatars';
          final testFile = File('$avatarsPath\\.test');
          await Directory(avatarsPath).create(recursive: true);
          await testFile.writeAsString('test');
          await testFile.delete();
          // ✅ Écriture possible
        } catch (_) {
          // Niveau 2 : Dossier courant
          try {
            avatarsPath = '${Directory.current.path}\\avatars';
            await Directory(avatarsPath).create(recursive: true);
          } catch (_) {
            // Niveau 3 : Documents utilisateur
            final appDir = await getApplicationDocumentsDirectory();
            avatarsPath = '${appDir.path}\\triball_avatars';
            await Directory(avatarsPath).create(recursive: true);
          }
        }
      } else {
        // Linux/Mac
        avatarsPath = '${Directory.current.path}/avatars';
        await Directory(avatarsPath).create(recursive: true);
      }

      _avatarsDir = avatarsPath;

      if (kDebugMode) {
        print('📸 ✅ Avatars directory ready: $_avatarsDir');
        final files = await listAvatarFiles();
        print('   Existing files: ${files.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ CRITICAL: Cannot create avatars directory');
        print('   Error: $e');
      }
    }
  }

  /// ✅ Fallback si le chemin principal échoue
  Future<void> _tryFallbackDir() async {
    try {
      // Option 1 : Dossier courant
      final currentDir = Directory.current.path;
      final fallbackPath = '$currentDir/avatars';

      if (kDebugMode) {
        print('📸 Trying fallback dir: $fallbackPath');
      }

      final dir = Directory(fallbackPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      _avatarsDir = fallbackPath;

      if (kDebugMode) {
        print('   ✅ Fallback dir created: $_avatarsDir');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Fallback dir also failed: $e');
    }
  }

  // ============================================
  // ÉCOUTE WEBSOCKET
  // ============================================
  void _listenToAvatars() {
    _avatarSub = PlatformEventBus.instance.onPlayerAvatar.listen((data) {
      final playerName = data['player'] as String? ?? '';
      final playerIndex = (data['playerIndex'] as num?)?.toInt() ?? 0;
      final avatarUrl = data['avatarUrl'] as String? ?? '';

      if (playerName.isEmpty || avatarUrl.isEmpty) return;

      currentAvatarUrls[playerName] = avatarUrl;
      currentAvatarUrlsByIndex[playerIndex] = avatarUrl;

      _preloadAvatar(playerName, avatarUrl);
    });

    _clearSub = PlatformEventBus.instance.onClearAvatars.listen((_) {
      clearCurrentGameAvatars();
    });
  }

  // ============================================
  // PRÉ-TÉLÉCHARGEMENT
  // ============================================
  Future<void> _preloadAvatar(String playerName, String url) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close()
          .timeout(const Duration(seconds: 5));

      final bytes = <int>[];
      await for (final chunk in response) {
        bytes.addAll(chunk);
      }
      _cachedBytes[playerName] = Uint8List.fromList(bytes);

      if (kDebugMode) {
        print('📸 Avatar preloaded: $playerName (${bytes.length} bytes)');
      }
    } catch (e) {
      if (kDebugMode) print('📸 Preload error for $playerName: $e');
    }
  }

  // ============================================
  // GET AVATAR — Partie en cours (mémoire)
  // ============================================
  String? getAvatarUrl(String playerName) => currentAvatarUrls[playerName];
  String? getAvatarUrlByIndex(int index) => currentAvatarUrlsByIndex[index];

  Uint8List? getCachedBytes(String playerName) => _cachedBytes[playerName];

  Uint8List? getCachedBytesByIndex(int index) {
    for (final entry in currentAvatarUrls.entries) {
      if (currentAvatarUrlsByIndex[index] == entry.value) {
        return _cachedBytes[entry.key];
      }
    }
    return null;
  }

  bool hasAvatar(String playerName) =>
      currentAvatarUrls.containsKey(playerName);
  bool hasAvatarByIndex(int index) =>
      currentAvatarUrlsByIndex.containsKey(index);

  // ============================================
  // CLEAR — Partie en cours
  // ============================================
  void clearCurrentGameAvatars() {
    currentAvatarUrls.clear();
    currentAvatarUrlsByIndex.clear();
    _cachedBytes.clear();
    if (kDebugMode) print('🗑 Current game avatars cleared');
  }

  // ============================================
  // ✅ TOP 10 — Fichiers JPEG dans assets/avatars
  // ============================================

  /// Nom de fichier sécurisé
  String _safeFileName(String gameMode, String playerName) {
    final safeName = playerName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase()
        .trim();
    return '${gameMode}_$safeName.jpg';
  }

  /// Chemin complet du fichier
  String _avatarFilePath(String gameMode, String playerName) {
    return '$_avatarsDir/${_safeFileName(gameMode, playerName)}';
  }

  /// ✅ Sauvegarde l'avatar sur le disque
  Future<void> saveTop10Avatar({
    required String gameMode,
    required String playerName,
    required Uint8List bytes,
  }) async {
    if (_avatarsDir == null) {
      if (kDebugMode) print('❌ Cannot save avatar: dir not initialized');
      return;
    }

    try {
      final filePath = _avatarFilePath(gameMode, playerName);
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      if (kDebugMode) {
        print('💾 Top 10 avatar saved:');
        print('   File: $filePath');
        print('   Size: ${bytes.length} bytes');
      }

      await _cleanOldAvatarsForMode(gameMode);
    } catch (e) {
      if (kDebugMode) print('📸 Save avatar error: $e');
    }
  }

  /// ✅ Récupère l'avatar top 10
  Future<Uint8List?> getTop10AvatarBytes({
    required String gameMode,
    required String playerName,
  }) async {
    if (_avatarsDir == null) return null;

    try {
      final file = File(_avatarFilePath(gameMode, playerName));
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (kDebugMode) {
          print('📸 Top 10 avatar loaded: ${file.path} (${bytes.length} bytes)');
        }
        return bytes;
      }
    } catch (e) {
      if (kDebugMode) print('📸 Read avatar error: $e');
    }
    return null;
  }

  /// ✅ Vérifie si un avatar top 10 existe
  Future<bool> hasTop10Avatar({
    required String gameMode,
    required String playerName,
  }) async {
    if (_avatarsDir == null) return false;
    try {
      final file = File(_avatarFilePath(gameMode, playerName));
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  /// ✅ Supprime les joueurs qui ne sont plus dans le top 10
  Future<void> syncTop10WithLeaderboard({
    required String gameMode,
    required List<String> top10Names,
  }) async {
    if (_avatarsDir == null) return;

    try {
      final dir = Directory(_avatarsDir!);
      if (!await dir.exists()) return;

      final prefix = '${gameMode}_';

      await for (final entity in dir.list()) {
        if (entity is File) {
          final filename = entity.uri.pathSegments.last;
          if (filename.startsWith(prefix) && filename.endsWith('.jpg')) {
            final namepart = filename
                .replaceFirst(prefix, '')
                .replaceAll('.jpg', '');

            final isInTop10 = top10Names.any((name) {
              final safeName = name
                  .replaceAll(RegExp(r'[^\w\s-]'), '')
                  .replaceAll(RegExp(r'\s+'), '_')
                  .toLowerCase()
                  .trim();
              return safeName == namepart;
            });

            if (!isInTop10) {
              await entity.delete();
              if (kDebugMode) print('🗑 Removed old avatar: $filename');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) print('📸 Sync avatars error: $e');
    }
  }

  /// Nettoie les avatars en trop (max 10 par mode)
  Future<void> _cleanOldAvatarsForMode(String gameMode) async {
    if (_avatarsDir == null) return;

    try {
      final dir = Directory(_avatarsDir!);
      if (!await dir.exists()) return;

      final prefix = '${gameMode}_';
      final files = <File>[];

      await for (final entity in dir.list()) {
        if (entity is File) {
          final filename = entity.uri.pathSegments.last;
          if (filename.startsWith(prefix) && filename.endsWith('.jpg')) {
            files.add(entity);
          }
        }
      }

      if (files.length > 10) {
        files.sort((a, b) =>
            a.lastModifiedSync().compareTo(b.lastModifiedSync()));

        final toRemove = files.length - 10;
        for (int i = 0; i < toRemove; i++) {
          await files[i].delete();
          if (kDebugMode) print('🗑 Cleaned old avatar: ${files[i].path}');
        }
      }
    } catch (e) {
      if (kDebugMode) print('📸 Clean avatars error: $e');
    }
  }

  /// ✅ Supprime tous les avatars top 10
  Future<void> clearAllTop10Avatars() async {
    if (_avatarsDir == null) return;

    try {
      final dir = Directory(_avatarsDir!);
      if (!await dir.exists()) return;

      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          await entity.delete();
        }
      }
      if (kDebugMode) print('🗑 All top 10 avatars cleared');
    } catch (e) {
      if (kDebugMode) print('📸 Clear all avatars error: $e');
    }
  }

  /// ✅ Nombre d'avatars stockés
  Future<int> getTop10AvatarCount() async {
    if (_avatarsDir == null) return 0;
    try {
      final dir = Directory(_avatarsDir!);
      if (!await dir.exists()) return 0;

      int count = 0;
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          count++;
        }
      }
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// ✅ Liste les fichiers avatars (debug)
  Future<List<String>> listAvatarFiles() async {
    if (_avatarsDir == null) return [];
    try {
      final dir = Directory(_avatarsDir!);
      if (!await dir.exists()) return [];

      final files = <String>[];
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.jpg')) {
          files.add(entity.uri.pathSegments.last);
        }
      }
      return files;
    } catch (_) {
      return [];
    }
  }
}
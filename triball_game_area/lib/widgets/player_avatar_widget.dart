// triball_game_area/lib/widgets/player_avatar_widget.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/services/avatar_storage_service.dart';
import '../core/theme/theme_colors.dart';
import '../core/utils/helpers.dart';

class PlayerAvatarWidget extends StatelessWidget {
  final String playerName;
  final int playerIndex;
  final double size;
  final double borderWidth;
  final String? gameMode;

  const PlayerAvatarWidget({
    super.key,
    required this.playerName,
    required this.playerIndex,
    this.size = 32,
    this.borderWidth = 2,
    this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    final avatarService = Get.find<AvatarStorageService>();
    final color = Helpers.playerColor(playerIndex);

    return Obx(() {
      // LEADERBOARD : l'index représente le rang, pas l'index du joueur de la
      // dernière partie. Il faut donc chercher l'avatar persistant par
      // (mode + nom) avant de consulter le cache temporaire par index.
      if (gameMode != null) {
        return _Top10Avatar(
          key: ValueKey('${gameMode!}:${playerName.toLowerCase()}'),
          playerName: playerName,
          gameMode: gameMode!,
          size: size,
          borderWidth: borderWidth,
          color: color,
          playerIndex: playerIndex,
        );
      }

      // GAME SCREEN : bytes pré-téléchargés de la partie en cours.
      final cachedBytes = avatarService.getCachedBytesByIndex(playerIndex);
      if (cachedBytes != null) {
        return _PhotoAvatar(
          bytes: cachedBytes,
          size: size,
          borderWidth: borderWidth,
          color: color,
          playerIndex: playerIndex,
        );
      }

      // 2. URL réseau
      final url = avatarService.getAvatarUrlByIndex(playerIndex);
      if (url != null && url.isNotEmpty) {
        return _NetworkAvatar(
          url: url,
          size: size,
          borderWidth: borderWidth,
          color: color,
          playerIndex: playerIndex,
        );
      }

      // 3. Fallback badge
      return _FallbackBadge(
        index: playerIndex,
        size: size,
        color: color,
      );
    });
  }
}

class _Top10Avatar extends StatefulWidget {
  final String playerName;
  final String gameMode;
  final double size;
  final double borderWidth;
  final Color color;
  final int playerIndex;

  const _Top10Avatar({
    super.key,
    required this.playerName,
    required this.gameMode,
    required this.size,
    required this.borderWidth,
    required this.color,
    required this.playerIndex,
  });

  @override
  State<_Top10Avatar> createState() => _Top10AvatarState();
}

class _Top10AvatarState extends State<_Top10Avatar> {
  Uint8List? _bytes;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  @override
  void didUpdateWidget(covariant _Top10Avatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playerName != widget.playerName ||
        oldWidget.gameMode != widget.gameMode) {
      _bytes = null;
      _loaded = false;
      _loadAvatar();
    }
  }

  Future<void> _loadAvatar() async {
    try {
      final service = Get.find<AvatarStorageService>();
      final bytes = await service.getTop10AvatarBytes(
        gameMode: widget.gameMode,
        playerName: widget.playerName,
      );
      if (mounted) {
        setState(() {
          _bytes = bytes;
          _loaded = true;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return _FallbackBadge(
        index: widget.playerIndex,
        size: widget.size,
        color: widget.color,
      );
    }

    if (_bytes != null) {
      return _PhotoAvatar(
        bytes: _bytes!,
        size: widget.size,
        borderWidth: widget.borderWidth,
        color: widget.color,
        playerIndex: widget.playerIndex,
      );
    }

    return _FallbackBadge(
      index: widget.playerIndex,
      size: widget.size,
      color: widget.color,
    );
  }
}

class _PhotoAvatar extends StatelessWidget {
  final Uint8List bytes;
  final double size;
  final double borderWidth;
  final Color color;
  final int playerIndex;

  const _PhotoAvatar({
    required this.bytes,
    required this.size,
    required this.borderWidth,
    required this.color,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: borderWidth),
        boxShadow: ThemeColors.useGlow
            ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)]
            : null,
      ),
      child: ClipOval(
        child: Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) {
            return _FallbackBadge(
                index: playerIndex, size: size, color: color);
          },
        ),
      ),
    );
  }
}

class _NetworkAvatar extends StatelessWidget {
  final String url;
  final double size;
  final double borderWidth;
  final Color color;
  final int playerIndex;

  const _NetworkAvatar({
    required this.url,
    required this.size,
    required this.borderWidth,
    required this.color,
    required this.playerIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: borderWidth),
      ),
      child: ClipOval(
        child: Image.network(
          url,
          fit: BoxFit.cover,
          width: size,
          height: size,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: color.withOpacity(0.1),
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: color),
                ),
              ),
            );
          },
          errorBuilder: (_, __, ___) {
            return _FallbackBadge(
                index: playerIndex, size: size, color: color);
          },
        ),
      ),
    );
  }
}

class _FallbackBadge extends StatelessWidget {
  final int index;
  final double size;
  final Color color;

  const _FallbackBadge({
    required this.index,
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: size * 0.5,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
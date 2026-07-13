// lib/data/models/platform_status_model.dart

/// Statut périodique envoyé par l'ESP32 (toutes les 5s)
class PlatformStatusModel {
  final bool gameActive;
  final int uptimeSeconds;
  final int clientsCount;
  final int freeHeap;
  final DateTime receivedAt;

  PlatformStatusModel({
    required this.gameActive,
    required this.uptimeSeconds,
    required this.clientsCount,
    required this.freeHeap,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory PlatformStatusModel.fromJson(Map<String, dynamic> json) {
    return PlatformStatusModel(
      gameActive: json['game_active'] ?? false,
      uptimeSeconds: _toInt(json['uptime']),
      clientsCount: _toInt(json['clients']),
      freeHeap: _toInt(json['free_heap']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String get uptimeFormatted {
    final h = uptimeSeconds ~/ 3600;
    final m = (uptimeSeconds % 3600) ~/ 60;
    final s = uptimeSeconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  String get freeHeapFormatted {
    if (freeHeap >= 1024) {
      return '${(freeHeap / 1024).toStringAsFixed(1)} KB';
    }
    return '$freeHeap B';
  }

  @override
  String toString() =>
      'PlatformStatus(active=$gameActive, uptime=${uptimeFormatted}, '
          'clients=$clientsCount, heap=$freeHeapFormatted)';
}
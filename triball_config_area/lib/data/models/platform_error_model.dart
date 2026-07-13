// lib/data/models/platform_error_model.dart

/// Message d'erreur depuis l'ESP32
class PlatformErrorModel {
  final String message;
  final DateTime receivedAt;

  PlatformErrorModel({
    required this.message,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory PlatformErrorModel.fromJson(Map<String, dynamic> json) {
    return PlatformErrorModel(
      message: (json['message'] ?? 'Unknown error').toString(),
    );
  }

  @override
  String toString() => 'PlatformError($message)';
}
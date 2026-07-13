// lib/data/models/score_event_model.dart

class ScoreEventModel {
  final String hole;
  final int value;
  final String effect; // 'positive', 'negative', 'x0', 'x2', 'neutral'
  final int sensor;
  final int distance;
  final int timestamp;
  final DateTime receivedAt;

  ScoreEventModel({
    required this.hole,
    required this.value,
    required this.effect,
    required this.sensor,
    required this.distance,
    required this.timestamp,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  factory ScoreEventModel.fromJson(Map<String, dynamic> json) {
    return ScoreEventModel(
      hole: (json['hole'] ?? '').toString(),
      value: _toInt(json['value']),
      effect: (json['effect'] ?? 'neutral').toString(),
      sensor: _toInt(json['sensor']),
      distance: _toInt(json['distance']),
      timestamp: _toInt(json['ts']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  Map<String, dynamic> toJson() => {
    'hole': hole,
    'value': value,
    'effect': effect,
    'sensor': sensor,
    'distance': distance,
    'ts': timestamp,
  };

  bool get isPositive => effect == 'positive';
  bool get isNegative => effect == 'negative';
  bool get isX0       => effect == 'x0';
  bool get isX2       => effect == 'x2';
  bool get isSpecial  => isX0 || isX2;
  bool get isNeutral  => effect == 'neutral';

  String get displayValue {
    if (isX0) return '×0';
    if (isX2) return '×2';
    return value >= 0 ? '+$value' : '$value';
  }

  /// Position dans la grille 3×3 (0..8) — utile pour LED & UI
  int get gridIndex {
    switch (hole) {
      case 'LEFT_TOP':    return 0;
      case 'CENTER_TOP':  return 1;
      case 'RIGHT_TOP':   return 2;
      case 'LEFT_MID':    return 3;
      case 'CENTER_MID':  return 4;
      case 'RIGHT_MID':   return 5;
      case 'LEFT_LOW':    return 6;
      case 'CENTER_LOW':  return 7;
      case 'RIGHT_LOW':   return 8;
    }
    return -1;
  }

  @override
  String toString() => 'ScoreEvent($hole: $displayValue)';
}
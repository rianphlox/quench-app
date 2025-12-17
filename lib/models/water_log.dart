class WaterLog {
  final String id;
  final double volume; // in ml
  final DateTime timestamp;

  const WaterLog({
    required this.id,
    required this.volume,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'volume': volume,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WaterLog.fromMap(Map<String, dynamic> map) {
    return WaterLog(
      id: map['id'] ?? '',
      volume: (map['volume'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'volume': volume,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory WaterLog.fromJson(Map<String, dynamic> json) {
    return WaterLog(
      id: json['id'] ?? '',
      volume: (json['volume'] ?? 0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? 0),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WaterLog &&
        other.id == id &&
        other.volume == volume &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => id.hashCode ^ volume.hashCode ^ timestamp.hashCode;

  @override
  String toString() => 'WaterLog(id: $id, volume: $volume, timestamp: $timestamp)';

  WaterLog copyWith({
    String? id,
    double? volume,
    DateTime? timestamp,
  }) {
    return WaterLog(
      id: id ?? this.id,
      volume: volume ?? this.volume,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
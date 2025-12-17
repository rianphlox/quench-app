import 'water_log.dart';

class Badge {
  final String id;
  final String label;
  final String description;
  final String icon;
  final bool isUnlocked;

  const Badge({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'description': description,
      'icon': icon,
      'isUnlocked': isUnlocked,
    };
  }

  factory Badge.fromMap(Map<String, dynamic> map) {
    return Badge(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      description: map['description'] ?? '',
      icon: map['icon'] ?? '',
      isUnlocked: map['isUnlocked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory Badge.fromJson(Map<String, dynamic> json) => Badge.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Badge &&
        other.id == id &&
        other.label == label &&
        other.description == description &&
        other.icon == icon &&
        other.isUnlocked == isUnlocked;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        label.hashCode ^
        description.hashCode ^
        icon.hashCode ^
        isUnlocked.hashCode;
  }

  @override
  String toString() {
    return 'Badge(id: $id, label: $label, description: $description, icon: $icon, isUnlocked: $isUnlocked)';
  }

  Badge copyWith({
    String? id,
    String? label,
    String? description,
    String? icon,
    bool? isUnlocked,
  }) {
    return Badge(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}

class HydrationStats {
  final double totalToday;
  final double percentage;
  final List<WaterLog> logsToday;

  const HydrationStats({
    required this.totalToday,
    required this.percentage,
    required this.logsToday,
  });
}


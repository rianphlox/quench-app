class UserSettings {
  final double dailyGoal; // in ml
  final bool darkMode;
  final String themeColor;
  final bool reminderEnabled;
  final int reminderInterval; // in minutes
  final String reminderStartTime; // "HH:MM" 24h format
  final String reminderEndTime; // "HH:MM" 24h format

  const UserSettings({
    this.dailyGoal = 2500,
    this.darkMode = false,
    this.themeColor = 'cyan',
    this.reminderEnabled = false,
    this.reminderInterval = 60,
    this.reminderStartTime = "09:00",
    this.reminderEndTime = "22:00",
  });

  Map<String, dynamic> toMap() {
    return {
      'dailyGoal': dailyGoal,
      'darkMode': darkMode,
      'themeColor': themeColor,
      'reminderEnabled': reminderEnabled,
      'reminderInterval': reminderInterval,
      'reminderStartTime': reminderStartTime,
      'reminderEndTime': reminderEndTime,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      dailyGoal: (map['dailyGoal'] ?? 2500).toDouble(),
      darkMode: map['darkMode'] ?? false,
      themeColor: map['themeColor'] ?? 'cyan',
      reminderEnabled: map['reminderEnabled'] ?? false,
      reminderInterval: map['reminderInterval'] ?? 60,
      reminderStartTime: map['reminderStartTime'] ?? "09:00",
      reminderEndTime: map['reminderEndTime'] ?? "22:00",
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings.fromMap(json);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserSettings &&
        other.dailyGoal == dailyGoal &&
        other.darkMode == darkMode &&
        other.themeColor == themeColor &&
        other.reminderEnabled == reminderEnabled &&
        other.reminderInterval == reminderInterval &&
        other.reminderStartTime == reminderStartTime &&
        other.reminderEndTime == reminderEndTime;
  }

  @override
  int get hashCode {
    return dailyGoal.hashCode ^
        darkMode.hashCode ^
        themeColor.hashCode ^
        reminderEnabled.hashCode ^
        reminderInterval.hashCode ^
        reminderStartTime.hashCode ^
        reminderEndTime.hashCode;
  }

  @override
  String toString() {
    return 'UserSettings(dailyGoal: $dailyGoal, darkMode: $darkMode, themeColor: $themeColor, reminderEnabled: $reminderEnabled, reminderInterval: $reminderInterval, reminderStartTime: $reminderStartTime, reminderEndTime: $reminderEndTime)';
  }

  UserSettings copyWith({
    double? dailyGoal,
    bool? darkMode,
    String? themeColor,
    bool? reminderEnabled,
    int? reminderInterval,
    String? reminderStartTime,
    String? reminderEndTime,
  }) {
    return UserSettings(
      dailyGoal: dailyGoal ?? this.dailyGoal,
      darkMode: darkMode ?? this.darkMode,
      themeColor: themeColor ?? this.themeColor,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderInterval: reminderInterval ?? this.reminderInterval,
      reminderStartTime: reminderStartTime ?? this.reminderStartTime,
      reminderEndTime: reminderEndTime ?? this.reminderEndTime,
    );
  }
}
import 'package:flutter/foundation.dart';
import 'package:confetti/confetti.dart';
import 'package:uuid/uuid.dart';
import '../models/water_log.dart';
import '../models/user_settings.dart';
import '../models/badge.dart' as app_badge;
import '../constants/app_constants.dart';
import '../services/storage_service.dart';
import '../services/audio_service.dart';
import '../services/notification_service.dart';

class AppProvider with ChangeNotifier {
  List<WaterLog> _logs = [];
  UserSettings _settings = defaultSettings;
  late ConfettiController _confettiController;

  // Getters
  List<WaterLog> get logs => _logs;
  UserSettings get settings => _settings;
  ConfettiController get confettiController => _confettiController;

  // Computed properties
  List<WaterLog> get todayLogs {
    final now = DateTime.now();
    return _logs.where((log) {
      final logDate = log.timestamp;
      return logDate.year == now.year &&
             logDate.month == now.month &&
             logDate.day == now.day;
    }).toList();
  }

  double get todayTotal {
    return todayLogs.fold(0.0, (sum, log) => sum + log.volume);
  }

  double get progressPercentage {
    return (todayTotal / _settings.dailyGoal) * 100;
  }

  double get remainingToday {
    return (_settings.dailyGoal - todayTotal).clamp(0.0, double.infinity);
  }

  bool get goalReachedToday {
    return todayTotal >= _settings.dailyGoal;
  }

  int get currentStreak {
    final dailyVolumes = <String, double>{};

    // Calculate daily volumes
    for (final log in _logs) {
      final dayKey = '${log.timestamp.year}-${log.timestamp.month.toString().padLeft(2, '0')}-${log.timestamp.day.toString().padLeft(2, '0')}';
      dailyVolumes[dayKey] = (dailyVolumes[dayKey] ?? 0) + log.volume;
    }

    int streak = 0;
    final today = DateTime.now();
    DateTime checkDate = today;

    // Check if today's goal is met
    final todayKey = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    if ((dailyVolumes[todayKey] ?? 0) >= _settings.dailyGoal) {
      streak++;
      checkDate = DateTime(today.year, today.month, today.day - 1);
    } else {
      checkDate = DateTime(today.year, today.month, today.day - 1);
    }

    // Check previous days
    while (true) {
      final checkKey = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      if ((dailyVolumes[checkKey] ?? 0) >= _settings.dailyGoal) {
        streak++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      } else {
        break;
      }
    }

    return streak;
  }

  List<app_badge.Badge> get unlockedBadges {
    final List<app_badge.Badge> unlocked = [];
    final streak = currentStreak;
    final totalVolume = _logs.fold(0.0, (sum, log) => sum + log.volume);
    final hasEarlyLog = _logs.any((log) => log.timestamp.hour < 7);
    final hasLateLog = _logs.any((log) => log.timestamp.hour >= 22);

    for (final badge in availableBadges) {
      bool shouldUnlock = false;

      switch (badge.id) {
        case 'streak_3':
          shouldUnlock = streak >= 3;
          break;
        case 'streak_7':
          shouldUnlock = streak >= 7;
          break;
        case 'streak_30':
          shouldUnlock = streak >= 30;
          break;
        case 'volume_100l':
          shouldUnlock = totalVolume >= 100000; // 100 liters in ml
          break;
        case 'perfect_week':
          shouldUnlock = streak >= 7;
          break;
        case 'early_bird':
          shouldUnlock = hasEarlyLog;
          break;
        case 'night_owl':
          shouldUnlock = hasLateLog;
          break;
      }

      if (shouldUnlock) {
        unlocked.add(badge.copyWith(isUnlocked: true));
      }
    }

    return unlocked;
  }

  AppProvider() {
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _loadData();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await NotificationService.initialize();
      await NotificationService.requestPermissions();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  // Initialize data
  Future<void> _loadData() async {
    try {
      _logs = StorageService.getWaterLogs();
      _settings = StorageService.getUserSettings();

      // Set up notifications with loaded settings
      await _updateNotificationReminders();

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading data: $e');
    }
  }

  // Add water log
  Future<void> addWater(double amount) async {
    try {
      // Play droplet sound
      await AudioService.playDropletSound();

      final wasGoalReached = goalReachedToday;
      final oldBadges = unlockedBadges.map((b) => b.id).toSet();

      final newLog = WaterLog(
        id: const Uuid().v4(),
        volume: amount,
        timestamp: DateTime.now(),
      );

      _logs.add(newLog);
      await StorageService.saveWaterLogs(_logs);

      // Check for new badges
      final newBadges = unlockedBadges.map((b) => b.id).toSet();
      final unlockedNewBadges = newBadges.difference(oldBadges);

      // Check if goal just reached
      if (!wasGoalReached && goalReachedToday) {
        await AudioService.playSuccessSound();
        _confettiController.play();
      }

      // Animate new badge unlocks
      if (unlockedNewBadges.isNotEmpty) {
        debugPrint('🏆 New badges unlocked: ${unlockedNewBadges.join(', ')}');
        // Additional celebration for new badges
        Future.delayed(const Duration(milliseconds: 500), () {
          _confettiController.play();
        });
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding water: $e');
    }
  }

  // Remove water log
  Future<void> removeWaterLog(String id) async {
    try {
      _logs.removeWhere((log) => log.id == id);
      await StorageService.saveWaterLogs(_logs);
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing water log: $e');
    }
  }

  // Update settings
  Future<void> updateSettings(UserSettings newSettings) async {
    try {
      _settings = newSettings;
      await StorageService.saveUserSettings(_settings);

      // Update notification reminders
      await _updateNotificationReminders();

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating settings: $e');
    }
  }

  Future<void> _updateNotificationReminders() async {
    try {
      await NotificationService.scheduleWaterReminders(
        enabled: _settings.reminderEnabled,
        intervalMinutes: _settings.reminderInterval,
        startTime: _settings.reminderStartTime,
        endTime: _settings.reminderEndTime,
      );

      if (_settings.reminderEnabled) {
        debugPrint('✅ Water reminders scheduled: every ${_settings.reminderInterval} min, ${_settings.reminderStartTime}-${_settings.reminderEndTime}');
      } else {
        debugPrint('🔕 Water reminders disabled');
      }
    } catch (e) {
      debugPrint('Error updating notification reminders: $e');
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    try {
      _logs.clear();
      _settings = defaultSettings;
      await StorageService.clearAllData();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing data: $e');
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }
}
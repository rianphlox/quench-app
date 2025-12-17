import '../models/water_log.dart';
import '../models/user_settings.dart';
import '../models/badge.dart' as app_badge;
import '../constants/app_constants.dart';

class BadgeCalculator {
  static List<app_badge.Badge> calculateUnlockedBadges(
    List<WaterLog> logs,
    UserSettings settings,
    int currentStreak,
  ) {
    final Set<String> unlockedIds = <String>{};

    // 1. Streak Badges
    if (currentStreak >= 3) unlockedIds.add('streak_3');
    if (currentStreak >= 7) unlockedIds.add('streak_7');
    if (currentStreak >= 30) unlockedIds.add('streak_30');

    // 2. Volume Badges
    final totalVolume = logs.fold(0.0, (sum, log) => sum + log.volume);
    if (totalVolume >= 100000) unlockedIds.add('volume_100l'); // 100L in ml

    // 3. Time-based Badges
    final hasEarlyBird = logs.any((log) => log.timestamp.hour < 7);
    if (hasEarlyBird) unlockedIds.add('early_bird');

    final hasNightOwl = logs.any((log) => log.timestamp.hour >= 22);
    if (hasNightOwl) unlockedIds.add('night_owl');

    // 4. Perfect Week Badge
    final perfectWeekStreak = _calculatePerfectWeekStreak(logs, settings);
    if (perfectWeekStreak >= 7) unlockedIds.add('perfect_week');

    // Return unlocked badges
    return availableBadges.where((badge) {
      return unlockedIds.contains(badge.id);
    }).map((badge) => badge.copyWith(isUnlocked: true)).toList();
  }

  static int _calculatePerfectWeekStreak(List<WaterLog> logs, UserSettings settings) {
    // Create a map of daily volumes
    final Map<String, double> dailyVolumes = {};

    for (final log in logs) {
      final dayKey = _formatDateKey(log.timestamp);
      dailyVolumes[dayKey] = (dailyVolumes[dayKey] ?? 0) + log.volume;
    }

    // Count consecutive days with goal met, starting from today or yesterday
    final today = DateTime.now();
    final todayKey = _formatDateKey(today);

    // Start from today if goal is met, otherwise start from yesterday
    DateTime checkDate = (dailyVolumes[todayKey] ?? 0) >= settings.dailyGoal
        ? today
        : DateTime(today.year, today.month, today.day - 1);

    int consecutiveDays = 0;

    while (consecutiveDays < 30) { // Prevent infinite loop
      final checkKey = _formatDateKey(checkDate);
      final dayVolume = dailyVolumes[checkKey] ?? 0;

      if (dayVolume >= settings.dailyGoal) {
        consecutiveDays++;
        checkDate = DateTime(checkDate.year, checkDate.month, checkDate.day - 1);
      } else {
        break;
      }
    }

    return consecutiveDays;
  }

  static String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get personalized achievement message
  static String getAchievementMessage(String badgeId) {
    switch (badgeId) {
      case 'streak_3':
        return '🔥 3 days strong! You\'re building a healthy habit!';
      case 'streak_7':
        return '⚡ One week of hydration excellence! You\'re unstoppable!';
      case 'streak_30':
        return '👑 30 days of perfect hydration! You\'re a true champion!';
      case 'volume_100l':
        return '💧 100 liters logged! Your dedication is inspiring!';
      case 'perfect_week':
        return '⭐ Perfect week achieved! Consistency is your superpower!';
      case 'early_bird':
        return '🌅 Early bird hydrator! Great way to start the day!';
      case 'night_owl':
        return '🌙 Late night hydration warrior! Every drop counts!';
      default:
        return '🎉 Achievement unlocked! Keep up the great work!';
    }
  }

  // Get progress towards next badge
  static Map<String, dynamic> getNextBadgeProgress(
    List<WaterLog> logs,
    UserSettings settings,
    int currentStreak,
  ) {
    final totalVolume = logs.fold(0.0, (sum, log) => sum + log.volume);

    // Check which badges are not yet unlocked and closest to achieving
    if (currentStreak < 3) {
      return {
        'badge': 'streak_3',
        'name': 'Good Start',
        'progress': currentStreak / 3,
        'description': '${3 - currentStreak} more days to unlock!',
      };
    } else if (currentStreak < 7) {
      return {
        'badge': 'streak_7',
        'name': 'Week Warrior',
        'progress': currentStreak / 7,
        'description': '${7 - currentStreak} more days to unlock!',
      };
    } else if (totalVolume < 100000) {
      return {
        'badge': 'volume_100l',
        'name': '100L Club',
        'progress': totalVolume / 100000,
        'description': '${((100000 - totalVolume) / 1000).toStringAsFixed(1)}L more to unlock!',
      };
    } else if (currentStreak < 30) {
      return {
        'badge': 'streak_30',
        'name': 'Monthly Master',
        'progress': currentStreak / 30,
        'description': '${30 - currentStreak} more days to unlock!',
      };
    }

    return {
      'badge': null,
      'name': 'All badges unlocked!',
      'progress': 1.0,
      'description': 'You\'ve achieved everything! Keep staying hydrated!',
    };
  }
}
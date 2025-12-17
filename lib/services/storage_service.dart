import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_log.dart';
import '../models/user_settings.dart';
import '../constants/app_constants.dart';

class StorageService {
  static const String _waterLogsKey = 'hydroflow_logs';
  static const String _userSettingsKey = 'hydroflow_settings';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get _instance {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Water Logs
  static Future<void> saveWaterLogs(List<WaterLog> logs) async {
    final jsonList = logs.map((log) => log.toJson()).toList();
    await _instance.setString(_waterLogsKey, jsonEncode(jsonList));
  }

  static List<WaterLog> getWaterLogs() {
    final String? jsonString = _instance.getString(_waterLogsKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => WaterLog.fromJson(json)).toList();
    } catch (e) {
      print('Error loading water logs: $e');
      return [];
    }
  }

  static Future<void> addWaterLog(WaterLog log) async {
    final logs = getWaterLogs();
    logs.add(log);
    await saveWaterLogs(logs);
  }

  static Future<void> removeWaterLog(String id) async {
    final logs = getWaterLogs();
    logs.removeWhere((log) => log.id == id);
    await saveWaterLogs(logs);
  }

  static Future<void> clearWaterLogs() async {
    await _instance.remove(_waterLogsKey);
  }

  // User Settings
  static Future<void> saveUserSettings(UserSettings settings) async {
    await _instance.setString(_userSettingsKey, jsonEncode(settings.toJson()));
  }

  static UserSettings getUserSettings() {
    final String? jsonString = _instance.getString(_userSettingsKey);
    if (jsonString == null) return defaultSettings;

    try {
      final Map<String, dynamic> json = jsonDecode(jsonString);
      return UserSettings.fromJson(json);
    } catch (e) {
      print('Error loading user settings: $e');
      return defaultSettings;
    }
  }

  static Future<void> clearUserSettings() async {
    await _instance.remove(_userSettingsKey);
  }

  // Helper methods
  static Future<void> clearAllData() async {
    await clearWaterLogs();
    await clearUserSettings();
  }

  // Generic methods for storing simple values
  static Future<bool> setBool(String key, bool value) async {
    return await _instance.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _instance.getBool(key);
  }

  static Future<bool> setString(String key, String value) async {
    return await _instance.setString(key, value);
  }

  static String? getString(String key) {
    return _instance.getString(key);
  }

  // Get today's water logs
  static List<WaterLog> getTodayWaterLogs() {
    final logs = getWaterLogs();
    final today = DateTime.now();

    return logs.where((log) {
      final logDate = log.timestamp;
      return logDate.year == today.year &&
             logDate.month == today.month &&
             logDate.day == today.day;
    }).toList();
  }

  // Get total volume for today
  static double getTodayTotalVolume() {
    final todayLogs = getTodayWaterLogs();
    return todayLogs.fold(0.0, (sum, log) => sum + log.volume);
  }

  // Get logs for a specific date range
  static List<WaterLog> getWaterLogsForDateRange(DateTime start, DateTime end) {
    final logs = getWaterLogs();
    return logs.where((log) {
      return log.timestamp.isAfter(start) && log.timestamp.isBefore(end);
    }).toList();
  }

  // Get total volume all time
  static double getTotalVolumeAllTime() {
    final logs = getWaterLogs();
    return logs.fold(0.0, (sum, log) => sum + log.volume);
  }
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
      );

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
        macOS: initializationSettingsIOS,
      );

      final initialized = await _notifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        _initialized = true;
        if (kDebugMode) {
          print('✅ Notification service initialized successfully');
        }
      } else {
        if (kDebugMode) {
          print('⚠️ Notification service initialization returned false');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to initialize notification service: $e');
      }
      // Don't throw - let app continue without notifications
    }
  }

  static void _onNotificationTapped(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('Notification tapped: ${notificationResponse.payload}');
    }
  }

  static Future<bool> requestPermissions() async {
    if (!_initialized) {
      await initialize();
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ Cannot request permissions - notification service not initialized');
      }
      return false;
    }

    try {
      if (Platform.isAndroid) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _notifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool? granted = await androidImplementation.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS || Platform.isMacOS) {
        final bool? result = await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
        return result ?? false;
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to request permissions: $e');
      }
      return false;
    }

    return true;
  }

  static Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ Cannot show notification - service not initialized');
      }
      return;
    }

    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'quench_reminders',
        'Water Reminders',
        channelDescription: 'Notifications to remind you to drink water',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: Color(0xFF06b6d4), // Cyan-500
      );

      const DarwinNotificationDetails iosPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iosPlatformChannelSpecifics,
        macOS: iosPlatformChannelSpecifics,
      );

      await _notifications.show(
        0,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to show notification: $e');
      }
    }
  }

  static Future<void> scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required Duration interval,
    String? payload,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quench_reminders',
      'Water Reminders',
      channelDescription: 'Notifications to remind you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF06b6d4), // Cyan-500
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
      macOS: iosPlatformChannelSpecifics,
    );

    // Schedule the first notification
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.now(tz.local).add(interval),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  static Future<void> scheduleWaterReminders({
    required bool enabled,
    required int intervalMinutes,
    required String startTime, // "09:00"
    required String endTime,   // "22:00"
  }) async {
    if (!enabled) {
      await cancelAllNotifications();
      return;
    }

    if (!_initialized) {
      await initialize();
    }

    if (!_initialized) {
      if (kDebugMode) {
        print('⚠️ Cannot schedule reminders - service not initialized');
      }
      return;
    }

    try {
      // Cancel existing reminders
      await cancelAllNotifications();

    // Parse start and end times
    final startHour = int.parse(startTime.split(':')[0]);
    final startMinute = int.parse(startTime.split(':')[1]);
    final endHour = int.parse(endTime.split(':')[0]);
    final endMinute = int.parse(endTime.split(':')[1]);

    final now = tz.TZDateTime.now(tz.local);

    // Calculate next reminder time
    var nextReminder = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      startHour,
      startMinute,
    );

    // If start time has passed today, start tomorrow
    if (nextReminder.isBefore(now)) {
      nextReminder = nextReminder.add(const Duration(days: 1));
    }

    final endDateTime = tz.TZDateTime(
      tz.local,
      nextReminder.year,
      nextReminder.month,
      nextReminder.day,
      endHour,
      endMinute,
    );

    int notificationId = 1000;

    // Schedule notifications within the time window
    while (nextReminder.isBefore(endDateTime)) {
      await _scheduleWaterReminder(
        id: notificationId++,
        scheduledDate: nextReminder,
      );

      nextReminder = nextReminder.add(Duration(minutes: intervalMinutes));
    }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to schedule water reminders: $e');
      }
    }
  }

  static Future<void> _scheduleWaterReminder({
    required int id,
    required tz.TZDateTime scheduledDate,
  }) async {
    const List<String> messages = [
      "Time to hydrate! 💧",
      "Don't forget to drink water! 🌊",
      "Stay hydrated, stay healthy! 💙",
      "Your body needs water! 💧",
      "Hydration reminder! 🌟",
      "Time for a water break! 💧",
    ];

    const List<String> bodies = [
      "Keep your hydration on track with Quench",
      "Your daily water goal is waiting for you",
      "Stay refreshed and energized",
      "Your health depends on proper hydration",
      "Take a moment to drink some water",
      "Every sip counts towards your goal",
    ];

    final title = messages[id % messages.length];
    final body = bodies[id % bodies.length];

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'quench_reminders',
      'Water Reminders',
      channelDescription: 'Notifications to remind you to drink water',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      color: Color(0xFF06b6d4), // Cyan-500
      playSound: true,
      enableVibration: true,
      autoCancel: true,
    );

    const DarwinNotificationDetails iosPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
      macOS: iosPlatformChannelSpecifics,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'water_reminder',
    );
  }

  static Future<void> cancelAllNotifications() async {
    if (!_initialized) return;

    try {
      await _notifications.cancelAll();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel notifications: $e');
      }
    }
  }

  static Future<void> cancelNotification(int id) async {
    if (!_initialized) return;

    try {
      await _notifications.cancel(id);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to cancel notification $id: $e');
      }
    }
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized) return [];

    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to get pending notifications: $e');
      }
      return [];
    }
  }
}
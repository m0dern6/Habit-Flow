import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _notifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap - navigate to habit detail
    if (kDebugMode) {
      print('Notification tapped: ${response.payload}');
    }
  }

  Future<void> scheduleHabitReminders({
    required String habitId,
    required String habitTitle,
    required DateTime reminderTime,
    required List<int> weekdays, // 1 = Monday, 7 = Sunday
  }) async {
    // Cancel existing reminders for this habit
    await cancelHabitReminders(habitId);

    final now = DateTime.now();
    final baseId = habitId.hashCode;

    // Schedule reminders for each weekday
    for (final weekday in weekdays) {
      // 2 hours before
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 1,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: 120,
        message: 'Reminder: $habitTitle in 2 hours',
      );

      // 1 hour before
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 2,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: 60,
        message: 'Reminder: $habitTitle in 1 hour',
      );

      // 30 minutes before
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 3,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: 30,
        message: 'Reminder: $habitTitle in 30 minutes',
      );

      // 10 minutes before
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 4,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: 10,
        message: 'Reminder: $habitTitle in 10 minutes',
      );

      // At reminder time
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 5,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: 0,
        message: 'Time to complete: $habitTitle',
      );

      // 1 hour after (missed notification)
      await _scheduleReminderForWeekday(
        id: baseId + (weekday * 10) + 6,
        habitId: habitId,
        habitTitle: habitTitle,
        reminderTime: reminderTime,
        weekday: weekday,
        minutesBefore: -60,
        message: 'You missed: $habitTitle (1 hour ago)',
      );
    }
  }

  Future<void> _scheduleReminderForWeekday({
    required int id,
    required String habitId,
    required String habitTitle,
    required DateTime reminderTime,
    required int weekday,
    required int minutesBefore,
    required String message,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    // Adjust for minutes before/after
    scheduledDate = scheduledDate.subtract(Duration(minutes: minutesBefore));

    // Find next occurrence of this weekday
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      'HabitFlow',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_reminders',
          'Habit Reminders',
          channelDescription: 'Reminders for your daily habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: habitId,
    );
  }

  Future<void> scheduleDailyEndOfDayCheck({
    required String userId,
    required DateTime checkTime, // e.g., 23:00
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      checkTime.hour,
      checkTime.minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      'daily_check'.hashCode,
      'HabitFlow Daily Summary',
      'Check your habit completion for today',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_summary',
          'Daily Summary',
          channelDescription: 'Daily habit completion summary',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'daily_check',
    );
  }

  Future<void> showStreakWarning({
    required String habitTitle,
    required int currentStreak,
  }) async {
    await _notifications.show(
      'streak_warning'.hashCode,
      'Streak Warning! 🔥',
      'Your $currentStreak-day streak for "$habitTitle" is at risk! Complete it today to keep going.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_warnings',
          'Streak Warnings',
          channelDescription: 'Warnings when your streak is at risk',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showStreakLost({
    required String habitTitle,
    required int lostStreak,
  }) async {
    await _notifications.show(
      'streak_lost_${habitTitle.hashCode}'.hashCode,
      'Streak Reset 😢',
      'Your $lostStreak-day streak for "$habitTitle" has been reset. Start fresh today!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_lost',
          'Streak Lost',
          channelDescription: 'Notification when a streak is lost',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> showHabitCompletionFailed({
    required String habitTitle,
  }) async {
    await _notifications.show(
      'habit_failed_${habitTitle.hashCode}'.hashCode,
      'Habit Incomplete',
      'You didn\'t complete "$habitTitle" today. There\'s still time!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_incomplete',
          'Habit Incomplete',
          channelDescription: 'Notifications for incomplete habits',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> cancelHabitReminders(String habitId) async {
    final baseId = habitId.hashCode;
    // Cancel all 42 possible notification IDs for this habit (7 weekdays * 6 notifications each)
    for (int weekday = 1; weekday <= 7; weekday++) {
      for (int notifType = 1; notifType <= 6; notifType++) {
        await _notifications.cancel(baseId + (weekday * 10) + notifType);
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

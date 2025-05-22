import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../model/daily_goal.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tapped
      },
    );

    // Request permission for Android 13+
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // Request notification permissions for Android
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminder_channel',
          'Goal Reminders',
          channelDescription: 'Daily goal reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  Future<void> scheduleDailyGoalReminder(DailyGoal goal) async {
    // Cancel any existing reminders first
    await cancelNotification(0);

    // Get the notification time from the goal
    final now = DateTime.now();

    // Create a DateTime for today with the notification time
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      goal.notifyTime.hour,
      goal.notifyTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    final effectiveDate =
        scheduledDate.isBefore(now)
            ? scheduledDate.add(const Duration(days: 1))
            : scheduledDate;

    final goalJson = goal.toJson();

    print("goalJson: $goalJson");
    // Schedule the notification
    await _notificationsPlugin.zonedSchedule(
      0, // Notification ID
      'Günlük Hedef Hatırlatıcısı',
      'Bugün ${goalJson['solvedQuestions']}/${goalJson['dailyQuestionGoal']} soru çözdünüz. Hedefinize ulaşmak için çalışmaya devam edin!',
      tz.TZDateTime.from(effectiveDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_reminder_channel',
          'Goal Reminders',
          channelDescription: 'Daily goal reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents:
          DateTimeComponents.time, // Daily recurring at the same time
    );
  }
}

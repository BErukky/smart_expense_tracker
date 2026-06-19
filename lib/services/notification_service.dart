import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/wish_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Initialize timezone database for scheduling
    tz.initializeTimeZones();

    // Android Initialization
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        debugPrint('Notification tapped: ${details.payload}');
      },
    );

    _isInitialized = true;
  }

  // Helper to convert string ID to integer ID for notifications
  int _generateNotificationId(String uuid) {
    return uuid.hashCode.abs();
  }

  Future<void> scheduleWishNotifications(WishItem item) async {
    if (!_isInitialized) await init();

    final unlockTime = item.createdAt.add(const Duration(hours: 48));
    final halfWayTime = item.createdAt.add(const Duration(hours: 24));
    final oneHourLeftTime = unlockTime.subtract(const Duration(hours: 1));

    final baseId = _generateNotificationId(item.id);

    // Notification Details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'impulse_control_channel',
      'Impulse Control Alerts',
      channelDescription: 'Notifications for cooling off periods',
      importance: Importance.max,
      priority: Priority.high,
    );
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // 1. Halfway Reminder (24h left)
    if (halfWayTime.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: baseId + 1,
        title: 'Halfway there! 🕰️',
        body: 'You have 24 hours left before you can decide on "${item.title}".',
        scheduledDate: tz.TZDateTime.from(halfWayTime, tz.local),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 2. Final Hour Reminder (1h left)
    if (oneHourLeftTime.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: baseId + 2,
        title: 'Almost time! ⏳',
        body: 'Only 1 hour left until your "${item.title}" unlocks.',
        scheduledDate: tz.TZDateTime.from(oneHourLeftTime, tz.local),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }

    // 3. Unlock Notification (0h left)
    if (unlockTime.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: baseId + 3,
        title: 'Unlocked! 🔓',
        body: 'Your "${item.title}" is ready. Will you buy it, or pass and save money?',
        scheduledDate: tz.TZDateTime.from(unlockTime, tz.local),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelNotifications(WishItem item) async {
    final baseId = _generateNotificationId(item.id);
    await _flutterLocalNotificationsPlugin.cancel(id: baseId + 1);
    await _flutterLocalNotificationsPlugin.cancel(id: baseId + 2);
    await _flutterLocalNotificationsPlugin.cancel(id: baseId + 3);
  }
}

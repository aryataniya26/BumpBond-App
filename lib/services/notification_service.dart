import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ✅ Initialize Notifications
  static Future<void> initialize() async {
    // Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ User granted notification permission');
    } else {
      print('❌ User declined or has not accepted notification permission');
    }

    // Get FCM Token
    String? token = await _firebaseMessaging.getToken();
    print('📱 FCM Token: $token');

    // Save token to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token ?? '');

    // Initialize Local Notifications (for foreground)
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        print('Notification tapped: ${details.payload}');
      },
    );

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message tap
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
  }

  // ✅ Handle Foreground Messages (App is open)
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('📩 Foreground Notification: ${message.notification?.title}');

    // Save to local storage
    await _saveNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? '',
    );

    // Show local notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'Bump Bond',
      body: message.notification?.body ?? 'You have a new notification',
    );
  }

  // ✅ Handle Background Message Tap
  static void _handleBackgroundMessageTap(RemoteMessage message) {
    print('📬 Background Notification Tapped: ${message.notification?.title}');
  }

  // ✅ Show Local Notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'bump_bond_channel',
      'Bump Bond Notifications',
      channelDescription: 'Pregnancy tracking notifications',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      // color: Color(0xFFB794F4),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  // ✅ Save Notification to Local Storage
  static Future<void> _saveNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    final notification = {
      'title': title,
      'body': body,
      'time': DateTime.now().toIso8601String(),
    };

    notifications.insert(0, notification.toString());

    // Keep only last 50 notifications
    if (notifications.length > 50) {
      notifications = notifications.sublist(0, 50);
    }

    await prefs.setStringList('notifications', notifications);
  }

  // ✅ Get All Notifications
  static Future<List<Map<String, String>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    return notifications.map((n) {
      // Parse string back to map
      final parts = n.replaceAll('{', '').replaceAll('}', '').split(', ');
      final map = <String, String>{};
      for (var part in parts) {
        final keyValue = part.split(': ');
        if (keyValue.length == 2) {
          map[keyValue[0]] = keyValue[1];
        }
      }
      return map;
    }).toList();
  }

  // ✅ Clear All Notifications
  static Future<void> clearAllNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notifications');
  }

  // ✅ Send Test Notification (For Testing)
  static Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification 🎉',
      body: 'Your notifications are working perfectly!',
    );

    await _saveNotification(
      title: 'Test Notification 🎉',
      body: 'Your notifications are working perfectly!',
    );
  }

  // ✅ Schedule Daily Reminder (Example)
  static Future<void> scheduleDailyReminder() async {
    // This would use flutter_local_notifications scheduling
    print('📅 Daily reminders scheduled');
  }
}

// ✅ Background Message Handler (Must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('🔔 Background Message: ${message.notification?.title}');
}
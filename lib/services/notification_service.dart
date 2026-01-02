import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ✅ FIXED: Single background handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService._handleBackgroundMessage(message);
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;
  static String? _lastNotificationId;
  static DateTime? _lastNotificationTime;

  // ✅ FIXED: Single callback
  static Function(Map<String, dynamic>)? _onNotificationTapCallback;
  static void setNotificationTapCallback(Function(Map<String, dynamic>) callback) {
    _onNotificationTapCallback = callback;
  }

  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? true;
    } catch (e) {
      print('❌ Error checking notification status: $e');
      return true;
    }
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications_enabled', enabled);

      if (enabled) {
        await _subscribeToTopics();
      } else {
        await _unsubscribeFromTopics();
      }
    } catch (e) {
      print('❌ Error setting notification preference: $e');
    }
  }

  static Future<void> _subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('all_users');
      print('✅ Subscribed to all notification topics');
    } catch (e) {
      print('❌ Error subscribing to topics: $e');
    }
  }

  static Future<void> _unsubscribeFromTopics() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
      print('✅ Unsubscribed from all notification topics');
    } catch (e) {
      print('❌ Error unsubscribing from topics: $e');
    }
  }

  // ✅ FIXED: Initialize only once
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ Notification service already initialized');
      return;
    }

    try {
      // Request permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');
        final notificationsEnabled = await areNotificationsEnabled();
        if (notificationsEnabled) {
          await _subscribeToTopics();
        }
      } else {
        print('❌ User declined notification permission');
        await setNotificationsEnabled(false);
      }

      // Get and save token
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token ?? '');

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
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
        onDidReceiveNotificationResponse: _handleNotificationTap,
      );

      await _createNotificationChannels();

      // ✅ FIXED: Single stream listeners
      _setupMessageListeners();

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Notification initialization error: $e');
    }
  }

  static void _setupMessageListeners() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground Message: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📬 App opened from background: ${message.notification?.title}');
      _handleNotificationTapFromData(message.data);
    });

    // App opened from terminated state
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('🚀 App opened from terminated state');
        _handleNotificationTapFromData(message.data);
      }
    });

    // Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    print('📢 Background Message: ${message.notification?.title}');

    // Prevent duplicate processing
    final messageId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
    if (_lastNotificationId == messageId) {
      print('⚠️ Duplicate background message ignored: $messageId');
      return;
    }

    _lastNotificationId = messageId;

    // Save notification
    await _saveNotification(
      title: message.notification?.title ?? 'Bump Bond',
      body: message.notification?.body ?? '',
      data: message.data,
    );

    // Show notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'Bump Bond',
      body: message.notification?.body ?? 'New notification',
      data: message.data,
    );
  }

  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final messageId = message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();

    // Prevent duplicate processing within 2 seconds
    if (_lastNotificationId == messageId ||
        (_lastNotificationTime != null &&
            DateTime.now().difference(_lastNotificationTime!).inSeconds < 2)) {
      print('⚠️ Duplicate foreground message ignored: $messageId');
      return;
    }

    _lastNotificationId = messageId;
    _lastNotificationTime = DateTime.now();

    // Save notification
    await _saveNotification(
      title: message.notification?.title ?? 'Bump Bond',
      body: message.notification?.body ?? '',
      data: message.data,
    );

    // Show notification
    await _showLocalNotification(
      title: message.notification?.title ?? 'Bump Bond',
      body: message.notification?.body ?? 'New notification',
      data: message.data,
    );
  }

  static void _handleNotificationTap(NotificationResponse response) {
    print('🔔 Notification Tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        _handleNotificationTapFromData(data);
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  static void _handleNotificationTapFromData(Map<String, dynamic> data) {
    print('📍 Handling notification tap data: $data');

    // Save for navigation
    _saveNotificationTapData(data);

    // Trigger callback
    if (_onNotificationTapCallback != null) {
      _onNotificationTapCallback!(data);
    }
  }

  static Future<void> _saveNotificationTapData(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_notification_data', json.encode(data));
      print('💾 Notification tap data saved');
    } catch (e) {
      print('❌ Error saving notification tap data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getLastNotificationData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('last_notification_data');
      if (data != null) {
        return json.decode(data) as Map<String, dynamic>;
      }
    } catch (e) {
      print('❌ Error getting last notification data: $e');
    }
    return null;
  }

  static Future<void> _createNotificationChannels() async {
    try {
      // Main channel
      const AndroidNotificationChannel mainChannel = AndroidNotificationChannel(
        'bump_bond_channel',
        'Bump Bond Notifications',
        description: 'Pregnancy tracking notifications',
        importance: Importance.high,
      );

      // Medication channel
      const AndroidNotificationChannel medicationChannel = AndroidNotificationChannel(
        'medication_reminders',
        'Medication Reminders',
        description: 'Daily medication reminder notifications',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color(0xFFB794F4),
      );

      // Baby chat channel
      const AndroidNotificationChannel babyChannel = AndroidNotificationChannel(
        'baby_chat_channel',
        'Baby Messages',
        description: 'Messages from your baby',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(mainChannel);
        await androidPlugin.createNotificationChannel(medicationChannel);
        await androidPlugin.createNotificationChannel(babyChannel);
        print('✅ All notification channels created');
      }
    } catch (e) {
      print('❌ Error creating notification channels: $e');
    }
  }

  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      // Determine channel
      String channelId = 'bump_bond_channel';
      String channelName = 'Bump Bond Notifications';

      if (data['feature'] == 'medication_reminder') {
        channelId = 'medication_reminders';
        channelName = 'Medication Reminders';
      } else if (data['feature'] == 'baby_chat' || data['screen'] == 'baby_chat') {
        channelId = 'baby_chat_channel';
        channelName = 'Baby Messages';
      }

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Pregnancy tracking notifications',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Generate unique ID
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      await _localNotifications.show(
        notificationId,
        title,
        body,
        notificationDetails,
        payload: json.encode(data),
      );

      print('✅ Local notification shown: $title');
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  static Future<void> _saveNotification({
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      // Check for duplicates (same title + body within last 5 minutes)
      final now = DateTime.now();
      final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));

      for (String n in notifications) {
        try {
          final existing = json.decode(n) as Map<String, dynamic>;
          final existingTime = DateTime.parse(existing['time'] ?? now.toString());
          if (existing['title'] == title &&
              existing['body'] == body &&
              existingTime.isAfter(fiveMinutesAgo)) {
            print('⚠️ Duplicate notification ignored: $title');
            return;
          }
        } catch (e) {
          continue;
        }
      }

      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title,
        'body': body,
        'time': now.toIso8601String(),
        'screen': data['screen'] ?? 'home',
        'feature': data['feature'] ?? 'general',
        'data': data,
        'isRead': false,
      };

      notifications.insert(0, json.encode(notification));

      // Keep only last 100 notifications
      if (notifications.length > 100) {
        notifications = notifications.sublist(0, 100);
      }

      await prefs.setStringList('notifications', notifications);
      print('✅ Notification saved: $title');
    } catch (e) {
      print('❌ Error saving notification: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      List<Map<String, dynamic>> result = [];

      for (String n in notifications) {
        try {
          final data = json.decode(n) as Map<String, dynamic>;
          result.add({
            'id': data['id']?.toString() ?? '',
            'title': data['title']?.toString() ?? 'Notification',
            'body': data['body']?.toString() ?? '',
            'time': data['time']?.toString() ?? DateTime.now().toIso8601String(),
            'screen': data['screen']?.toString() ?? 'home',
            'feature': data['feature']?.toString() ?? 'general',
            'data': data['data'] ?? {},
            'isRead': data['isRead'] == true,
          });
        } catch (e) {
          continue;
        }
      }

      return result;
    } catch (e) {
      print('❌ Error getting notifications: $e');
      return [];
    }
  }

  static Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      for (int i = 0; i < notifications.length; i++) {
        try {
          final data = json.decode(notifications[i]) as Map<String, dynamic>;
          if (data['id'] == notificationId) {
            data['isRead'] = true;
            notifications[i] = json.encode(data);
            break;
          }
        } catch (e) {
          continue;
        }
      }

      await prefs.setStringList('notifications', notifications);
      print('✅ Notification marked as read: $notificationId');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
      print('✅ All notifications cleared');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  static Future<void> deleteNotification(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      notifications.removeWhere((n) {
        try {
          final data = json.decode(n) as Map<String, dynamic>;
          return data['id'] == notificationId;
        } catch (e) {
          return false;
        }
      });

      await prefs.setStringList('notifications', notifications);
      print('✅ Notification deleted: $notificationId');
    } catch (e) {
      print('❌ Error deleting notification: $e');
    }
  }

  // ✅ FIXED: Water reminder with proper data
  static Future<void> sendWaterReminder() async {
    try {
      final data = {
        'screen': 'baby_chat',
        'feature': 'water_reminder',
        'babyName': 'Baby',
        'initialMessage': 'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙',
        'isWaterReminder': true,
      };

      await _showLocalNotification(
        title: '💧 Water Reminder',
        body: 'Time to hydrate! Drinking water helps both you and your baby stay healthy.',
        data: data,
      );

      await _saveNotification(
        title: '💧 Water Reminder',
        body: 'Time to hydrate! Drinking water helps both you and your baby stay healthy.',
        data: data,
      );

      print('✅ Water reminder notification sent');
    } catch (e) {
      print('❌ Error sending water reminder: $e');
    }
  }

  // Medication reminder
  static Future<void> sendMedicationReminder(String medicationName, String time) async {
    try {
      final data = {
        'screen': 'medications',
        'feature': 'medication_reminder',
        'medication': medicationName,
        'time': time,
      };

      await _showLocalNotification(
        title: '💊 Medication Reminder',
        body: 'Time to take $medicationName',
        data: data,
      );

      await _saveNotification(
        title: '💊 Medication Reminder',
        body: 'Time to take $medicationName',
        data: data,
      );

      print('✅ Medication reminder sent: $medicationName');
    } catch (e) {
      print('❌ Error sending medication reminder: $e');
    }
  }

  // Baby chat message
  static Future<void> sendBabyChatMessage(String message, String babyName) async {
    try {
      final data = {
        'screen': 'baby_chat',
        'feature': 'baby_chat',
        'babyName': babyName,
        'message': message,
      };

      await _showLocalNotification(
        title: '👶 $babyName',
        body: message,
        data: data,
      );

      await _saveNotification(
        title: '👶 $babyName',
        body: message,
        data: data,
      );

      print('✅ Baby chat notification sent');
    } catch (e) {
      print('❌ Error sending baby chat notification: $e');
    }
  }

  static Future<void> sendTestNotification() async {
    try {
      final data = {
        'screen': 'home',
        'feature': 'test',
        'test': true,
      };

      await _showLocalNotification(
        title: 'Test Notification 🎉',
        body: 'Your notifications are working perfectly!',
        data: data,
      );

      await _saveNotification(
        title: 'Test Notification 🎉',
        body: 'Your notifications are working perfectly!',
        data: data,
      );

      print('✅ Test notification sent');
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}
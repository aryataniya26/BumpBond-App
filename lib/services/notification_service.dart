import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Background Message Handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase initialize karo
  try {
    // Firebase already initialized hai, direct notification show karo
  } catch (e) {
    print('Background Firebase init error: $e');
  }

  print('🔔 Background Message: ${message.notification?.title}');

  // Background notification show karega
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Initialize local notifications for background
  const AndroidInitializationSettings androidSettings =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings =
  DarwinInitializationSettings();
  const InitializationSettings initSettings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await flutterLocalNotificationsPlugin.initialize(initSettings);

  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'bump_bond_channel',
    'Bump Bond Notifications',
    channelDescription: 'Pregnancy tracking notifications',
    importance: Importance.high,
    priority: Priority.high,
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

  await flutterLocalNotificationsPlugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    message.notification?.title ?? 'Bump Bond',
    message.notification?.body ?? 'New notification',
    notificationDetails,
  );

  // Background mein bhi notification save karo
  await _saveNotificationInBackground(
    title: message.notification?.title ?? 'New Notification',
    body: message.notification?.body ?? '',
  );
}

// Background ke liye alag save function
Future<void> _saveNotificationInBackground({
  required String title,
  required String body,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    List<String> notifications = prefs.getStringList('notifications') ?? [];

    final notification = {
      'title': title,
      'body': body,
      'time': DateTime.now().toIso8601String(),
    };

    notifications.insert(0, json.encode(notification));

    if (notifications.length > 50) {
      notifications = notifications.sublist(0, 50);
    }

    await prefs.setStringList('notifications', notifications);
  } catch (e) {
    print('❌ Error saving background notification: $e');
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ✅ Check if user has enabled notifications
  static Future<bool> areNotificationsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('notifications_enabled') ?? true; // Default true
    } catch (e) {
      print('❌ Error checking notification status: $e');
      return true;
    }
  }

  // ✅ Save notification preference
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

  // ✅ Subscribe to topics for automated notifications
  static Future<void> _subscribeToTopics() async {
    try {
      await _firebaseMessaging.subscribeToTopic('all_users');
      print('✅ Subscribed to all notification topics');
    } catch (e) {
      print('❌ Error subscribing to topics: $e');
    }
  }

  // ✅ Unsubscribe from all topics
  static Future<void> _unsubscribeFromTopics() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic('all_users');
      print('✅ Unsubscribed from all notification topics');
    } catch (e) {
      print('❌ Error unsubscribing from topics: $e');
    }
  }

  // ✅ Initialize Notifications
  static Future<void> initialize() async {
    try {
      // Request Permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ User granted notification permission');

        // ✅ AUTOMATICALLY SUBSCRIBE ALL USERS TO TOPICS
        final notificationsEnabled = await areNotificationsEnabled();
        if (notificationsEnabled) {
          await _subscribeToTopics();
        }
      } else {
        print('❌ User declined notification permission');
        await setNotificationsEnabled(false);
      }

      // Get FCM Token
      String? token = await _firebaseMessaging.getToken();
      print('📱 FCM Token: $token');

      // Save token to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token ?? '');

      // Initialize Local Notifications
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

      await _localNotifications.initialize(initSettings);

      // Create notification channel
      await _createNotificationChannel();

      // Listen to foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);

      // Set background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      print('✅ Notification service initialized successfully');

    } catch (e) {
      print('❌ Notification initialization error: $e');
    }
  }

  // ✅ Create Notification Channel
  static Future<void> _createNotificationChannel() async {
    try {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'bump_bond_channel',
        'Bump Bond Notifications',
        description: 'Pregnancy tracking notifications',
        importance: Importance.high,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(channel);
      }
    } catch (e) {
      print('❌ Error creating notification channel: $e');
    }
  }

  // ✅ Handle Foreground Messages
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
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'bump_bond_channel',
        'Bump Bond Notifications',
        channelDescription: 'Pregnancy tracking notifications',
        importance: Importance.high,
        priority: Priority.high,
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
    } catch (e) {
      print('❌ Error showing local notification: $e');
    }
  }

  // ✅ Save Notification to Local Storage
  static Future<void> _saveNotification({
    required String title,
    required String body,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      final notification = {
        'title': title,
        'body': body,
        'time': DateTime.now().toIso8601String(),
      };

      notifications.insert(0, json.encode(notification));

      if (notifications.length > 50) {
        notifications = notifications.sublist(0, 50);
      }

      await prefs.setStringList('notifications', notifications);
    } catch (e) {
      print('❌ Error saving notification: $e');
    }
  }

  // ✅ Get All Notifications
  static Future<List<Map<String, String>>> getNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> notifications = prefs.getStringList('notifications') ?? [];

      List<Map<String, String>> result = [];

      for (String n in notifications) {
        try {
          final Map<String, dynamic> data = json.decode(n);
          result.add({
            'title': data['title']?.toString() ?? 'Notification',
            'body': data['body']?.toString() ?? '',
            'time': data['time']?.toString() ?? DateTime.now().toIso8601String(),
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

  // ✅ Clear All Notifications
  static Future<void> clearAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notifications');
    } catch (e) {
      print('❌ Error clearing notifications: $e');
    }
  }

  // ✅ Send Test Notification
  static Future<void> sendTestNotification() async {
    try {
      await _showLocalNotification(
        title: 'Test Notification 🎉',
        body: 'Your notifications are working perfectly!',
      );

      await _saveNotification(
        title: 'Test Notification 🎉',
        body: 'Your notifications are working perfectly!',
      );
    } catch (e) {
      print('❌ Error sending test notification: $e');
    }
  }

  // ✅ Get FCM Token
  static Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('❌ Error getting FCM token: $e');
      return null;
    }
  }
}


// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// // Background Message Handler
// @pragma('vm:entry-point')
// Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//
//   print('🔔 Background Message: ${message.notification?.title}');
//
//   // Background notification show karega
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   // Initialize local notifications for background
//   const AndroidInitializationSettings androidSettings =
//   AndroidInitializationSettings('@mipmap/ic_launcher');
//   const DarwinInitializationSettings iosSettings =
//   DarwinInitializationSettings();
//   const InitializationSettings initSettings = InitializationSettings(
//     android: androidSettings,
//     iOS: iosSettings,
//   );
//
//   await flutterLocalNotificationsPlugin.initialize(initSettings);
//
//   const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     'bump_bond_channel',
//     'Bump Bond Notifications',
//     channelDescription: 'Pregnancy tracking notifications',
//     importance: Importance.high,
//     priority: Priority.high,
//   );
//
//   const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//     presentAlert: true,
//     presentBadge: true,
//     presentSound: true,
//   );
//
//   const NotificationDetails notificationDetails = NotificationDetails(
//     android: androidDetails,
//     iOS: iosDetails,
//   );
//
//   await flutterLocalNotificationsPlugin.show(
//     DateTime.now().millisecondsSinceEpoch ~/ 1000,
//     message.notification?.title ?? 'Bump Bond',
//     message.notification?.body ?? 'New notification',
//     notificationDetails,
//   );
//
//   // Background mein bhi notification save karo
//   await _saveNotificationInBackground(
//     title: message.notification?.title ?? 'New Notification',
//     body: message.notification?.body ?? '',
//   );
// }
//
// // Background ke liye alag save function
// Future<void> _saveNotificationInBackground({
//   required String title,
//   required String body,
// }) async {
//   final prefs = await SharedPreferences.getInstance();
//   List<String> notifications = prefs.getStringList('notifications') ?? [];
//
//   final notification = {
//     'title': title,
//     'body': body,
//     'time': DateTime.now().toIso8601String(),
//   };
//
//   notifications.insert(0, json.encode(notification));
//
//   if (notifications.length > 50) {
//     notifications = notifications.sublist(0, 50);
//   }
//
//   await prefs.setStringList('notifications', notifications);
// }
//
// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications =
//   FlutterLocalNotificationsPlugin();
//
//   // ✅ Subscribe to topics for automated notifications
//   static Future<void> subscribeToTopics() async {
//     try {
//       await _firebaseMessaging.subscribeToTopic('all_users');
//       print('✅ Subscribed to automated notifications topic');
//     } catch (e) {
//       print('❌ Error subscribing to topics: $e');
//     }
//   }
//
//   // ✅ Initialize Notifications
//   static Future<void> initialize() async {
//     try {
//       // Request Permission
//       NotificationSettings settings = await _firebaseMessaging.requestPermission(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//
//       if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//         print('✅ User granted notification permission');
//       } else {
//         print('❌ User declined notification permission');
//       }
//
//       // Get FCM Token
//       String? token = await _firebaseMessaging.getToken();
//       print('📱 FCM Token: $token');
//
//       // Save token to SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('fcm_token', token ?? '');
//
//       // Initialize Local Notifications
//       const AndroidInitializationSettings androidSettings =
//       AndroidInitializationSettings('@mipmap/ic_launcher');
//
//       const DarwinInitializationSettings iosSettings =
//       DarwinInitializationSettings(
//         requestAlertPermission: true,
//         requestBadgePermission: true,
//         requestSoundPermission: true,
//       );
//
//       const InitializationSettings initSettings = InitializationSettings(
//         android: androidSettings,
//         iOS: iosSettings,
//       );
//
//       await _localNotifications.initialize(
//         initSettings,
//         onDidReceiveNotificationResponse: (details) {
//           // Handle notification tap
//           print('📬 Notification tapped: ${details.payload}');
//         },
//       );
//
//       // Create notification channel
//       await _createNotificationChannel();
//
//       // Listen to foreground messages
//       FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
//
//       // Handle background message tap
//       FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageTap);
//
//       // Set background handler
//       FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//       // ✅ SUBSCRIBE TO TOPICS FOR AUTOMATED NOTIFICATIONS
//       await subscribeToTopics();
//
//       // Get initial notification (app closed state)
//       RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
//       if (initialMessage != null) {
//         _handleBackgroundMessageTap(initialMessage);
//       }
//
//       print('✅ Notification service initialized successfully');
//
//     } catch (e) {
//       print('❌ Notification initialization error: $e');
//     }
//   }
//
//   // ✅ Create Notification Channel
//   static Future<void> _createNotificationChannel() async {
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'bump_bond_channel',
//       'Bump Bond Notifications',
//       description: 'Pregnancy tracking notifications',
//       importance: Importance.high,
//     );
//
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }
//
//   // ✅ Handle Foreground Messages
//   static Future<void> _handleForegroundMessage(RemoteMessage message) async {
//     print('📩 Foreground Notification: ${message.notification?.title}');
//
//     // Save to local storage
//     await _saveNotification(
//       title: message.notification?.title ?? 'New Notification',
//       body: message.notification?.body ?? '',
//     );
//
//     // Show local notification
//     await _showLocalNotification(
//       title: message.notification?.title ?? 'Bump Bond',
//       body: message.notification?.body ?? 'You have a new notification',
//     );
//   }
//
//   // ✅ Handle Background Message Tap
//   static void _handleBackgroundMessageTap(RemoteMessage message) {
//     print('📬 Background Notification Tapped: ${message.notification?.title}');
//   }
//
//   // ✅ Show Local Notification
//   static Future<void> _showLocalNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//       'bump_bond_channel',
//       'Bump Bond Notifications',
//       channelDescription: 'Pregnancy tracking notifications',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
//       presentAlert: true,
//       presentBadge: true,
//       presentSound: true,
//     );
//
//     const NotificationDetails notificationDetails = NotificationDetails(
//       android: androidDetails,
//       iOS: iosDetails,
//     );
//
//     await _localNotifications.show(
//       DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       title,
//       body,
//       notificationDetails,
//     );
//   }
//
//   // ✅ Save Notification to Local Storage
//   static Future<void> _saveNotification({
//     required String title,
//     required String body,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> notifications = prefs.getStringList('notifications') ?? [];
//
//       final notification = {
//         'title': title,
//         'body': body,
//         'time': DateTime.now().toIso8601String(),
//       };
//
//       notifications.insert(0, json.encode(notification));
//
//       if (notifications.length > 50) {
//         notifications = notifications.sublist(0, 50);
//       }
//
//       await prefs.setStringList('notifications', notifications);
//     } catch (e) {
//       print('❌ Error saving notification: $e');
//     }
//   }
//
//   // ✅ Get All Notifications
//   static Future<List<Map<String, String>>> getNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       List<String> notifications = prefs.getStringList('notifications') ?? [];
//
//       List<Map<String, String>> result = [];
//
//       for (String n in notifications) {
//         try {
//           final Map<String, dynamic> data = json.decode(n);
//           result.add({
//             'title': data['title']?.toString() ?? 'Notification',
//             'body': data['body']?.toString() ?? '',
//             'time': data['time']?.toString() ?? DateTime.now().toIso8601String(),
//           });
//         } catch (e) {
//           continue;
//         }
//       }
//
//       return result;
//     } catch (e) {
//       print('❌ Error getting notifications: $e');
//       return [];
//     }
//   }
//
//   // ✅ Clear All Notifications
//   static Future<void> clearAllNotifications() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.remove('notifications');
//     } catch (e) {
//       print('❌ Error clearing notifications: $e');
//     }
//   }
//
//   // ✅ Send Test Notification
//   static Future<void> sendTestNotification() async {
//     try {
//       await _showLocalNotification(
//         title: 'Test Notification 🎉',
//         body: 'Your notifications are working perfectly!',
//       );
//
//       await _saveNotification(
//         title: 'Test Notification 🎉',
//         body: 'Your notifications are working perfectly!',
//       );
//     } catch (e) {
//       print('❌ Error sending test notification: $e');
//     }
//   }
//
//   // ✅ Get FCM Token
//   static Future<String?> getFCMToken() async {
//     return await _firebaseMessaging.getToken();
//   }
//
//   // ✅ Unsubscribe from topics
//   static Future<void> unsubscribeFromTopic(String topic) async {
//     try {
//       await _firebaseMessaging.unsubscribeFromTopic(topic);
//       print('✅ Unsubscribed from topic: $topic');
//     } catch (e) {
//       print('❌ Error unsubscribing from topic: $e');
//     }
//   }
// }

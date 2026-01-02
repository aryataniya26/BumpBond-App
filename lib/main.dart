import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
import 'package:bump_bond_flutter_app/auth/milestones.dart';
import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
import 'package:bump_bond_flutter_app/auth/notification_screen.dart';
import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
import 'package:bump_bond_flutter_app/models/journal_entry.dart';
import 'package:bump_bond_flutter_app/screens/baby_name_screen.dart';
import 'package:bump_bond_flutter_app/screens/book_consultation_screen.dart';
import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
import 'package:bump_bond_flutter_app/screens/education_screen.dart';
import 'package:bump_bond_flutter_app/screens/home_screen.dart';
import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
import 'package:bump_bond_flutter_app/screens/week_development_screen.dart';
import 'package:bump_bond_flutter_app/screens/weekly_quiz_screen.dart';
import 'package:bump_bond_flutter_app/services/ads_service.dart';
import 'package:bump_bond_flutter_app/services/notification_service.dart';
import 'package:bump_bond_flutter_app/services/payment_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// 🔑 GLOBAL NAVIGATOR
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
Map<String, dynamic>? _pendingNotificationData;
const String journalBoxName = 'journal_entries';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());

  final encryptionKey = Hive.generateSecureKey();
  await Hive.openBox<JournalEntry>(
    journalBoxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  await AdsService.initialize();
  PaymentService.initialize();

  await NotificationService.initialize();

  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  /// 🔥 SINGLE SOURCE OF NOTIFICATION NAVIGATION
  static void handleNotificationNavigation(
      BuildContext context, Map<String, dynamic> data) {
    debugPrint('🧭 Notification navigation data: $data');

    final screen = data['screen'] ?? 'home';
    final feature = data['feature'];
    final babyName = data['babyName'] ?? 'Baby';

    Navigator.of(context, rootNavigator: true)
        .popUntil((route) => route.isFirst);

    // 💧 Water Reminder
    if (feature == 'water_reminder') {
      navigatorKey.currentState?.pushNamed(
        '/baby-chat',
        arguments: {
          'babyName': babyName,
          'initialMessage':
          'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙',
          'isWaterReminder': true,
        },
      );
      return;
    }

    // 👶 Baby Chat
    if (screen == 'baby_chat') {
      navigatorKey.currentState?.pushNamed(
        '/baby-chat',
        arguments: {
          'babyName': babyName,
          'initialMessage': data['message'],
        },
      );
      return;
    }

    // 💊 Medication
    if (screen == 'medications') {
      navigatorKey.currentState?.pushNamed('/medication');
      return;
    }

    switch (screen) {
      case 'weekly_update':
        navigatorKey.currentState?.pushNamed('/weekly-development');
        break;
      case 'pregnancy_quiz':
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/pregnancy-quiz',
              (route) => false,
          arguments: data,
        );
        break;



      case 'baby_name':
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/baby-name',
              (route) => false,
          arguments: data,
        );
        break;

      case 'journal':
        navigatorKey.currentState?.pushNamed('/journal');
        break;
      case 'milestones':
        navigatorKey.currentState?.pushNamed('/milestones');
        break;
      case 'mood-tracker':
        navigatorKey.currentState?.pushNamed('/mood-tracker');
        break;
      case 'appointments':
        navigatorKey.currentState?.pushNamed('/appointments');
        break;
      default:
        navigatorKey.currentState?.pushNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🔔 Notification TAP CALLBACK (SAFE PLACE)
    NotificationService.setNotificationTapCallback((data) {
      _pendingNotificationData = data;

      if (navigatorKey.currentState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          handleNotificationNavigation(
              navigatorKey.currentState!.context, data);
          _pendingNotificationData = null;
        });
      }
    });

    return MaterialApp(
      title: "Bump Bond",
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      initialRoute: '/splash',
      routes: {
        '/pregnancy-quiz': (context) => const WeeklyQuizJourneyScreen(),
        '/splash': (_) => const SplashScreen(),
        '/main': (_) => const MainScreen(),
        '/home': (_) => const MainScreen(),
        '/notifications': (_) => const NotificationScreen(),
        '/baby-chat': (_) => const ChatScreen(babyName: 'babyName'),
        '/medication': (_) => const MedicationRemindersScreen(),
        '/weekly-development': (_) => const PregnancyJourneyScreen(),
        '/journal': (_) => const JournalScreen(),
        '/milestones': (_) => const MilestoneScreen(),
        '/mood-tracker': (_) => const MoodSymptomTrackerScreen(),
        '/appointments': (_) => const BookConsultationScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/baby-name': (context) => const BabyNameScreen(),

      },
    );
  }
}


class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthTrackerScreen(),
    const EducationScreen(),
    const JournalScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingNotification();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingNotification();
    }
  }

  void _checkPendingNotification() {
    if (_pendingNotificationData != null && mounted) {
      print('📱 Processing pending notification: $_pendingNotificationData');
      MyApp.handleNotificationNavigation(context, _pendingNotificationData!);
      _pendingNotificationData = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F7),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home, 'Home', 0),
                _buildNavItem(Icons.favorite, 'Tracker', 1),
                _buildNavItem(Icons.school, 'Learn', 2),
                _buildNavItem(Icons.book, 'Journal', 3),
                _buildNavItem(Icons.menu, 'Menu', 4, isMenu: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {bool isMenu = false}) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (isMenu) {
          Navigator.pushNamed(context, '/settings');
        } else {
          setState(() {
            _selectedIndex = index;
          });
          _pageController.jumpToPage(index);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: !isMenu && isSelected ? const Color(0xFFB794F4) : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: !isMenu && isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: !isMenu && isSelected ? Colors.white : Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}












// import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
// import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// import 'package:bump_bond_flutter_app/auth/milestones.dart';
// import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
// import 'package:bump_bond_flutter_app/auth/notification_screen.dart';
// import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// import 'package:bump_bond_flutter_app/models/journal_entry.dart';
// import 'package:bump_bond_flutter_app/screens/book_consultation_screen.dart';
// import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
// import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
// import 'package:bump_bond_flutter_app/screens/week_development_screen.dart';
// import 'package:bump_bond_flutter_app/services/ads_service.dart';
// import 'package:bump_bond_flutter_app/services/notification_service.dart';
// import 'package:bump_bond_flutter_app/services/payment_service.dart';
// import 'package:flutter/material.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
//
// // Global variables
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// Map<String, dynamic>? _pendingNotificationData;
// const String journalBoxName = 'journal_entries';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // ✅ SINGLE NOTIFICATION CALLBACK
//   NotificationService.setNotificationTapCallback((data) {
//     print('🔔 Global notification tap received: $data');
//     _pendingNotificationData = data;
//
//     // Navigate immediately if app is running
//     if (navigatorKey.currentState != null && _pendingNotificationData != null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         MyApp.handleNotificationNavigation(
//           navigatorKey.currentState!.context,
//           _pendingNotificationData!,
//         );
//       });
//     }
//   });
//
//   // Hive initialization
//   try {
//     await Hive.initFlutter();
//     print('Hive initialized successfully');
//
//     Hive.registerAdapter(JournalEntryAdapter());
//     print('Hive adapters registered');
//
//     final encryptionKey = await _getEncryptionKey();
//     print('Encryption key obtained');
//
//     await Hive.openBox<JournalEntry>(
//       journalBoxName,
//       encryptionCipher: HiveAesCipher(encryptionKey),
//     );
//     print('Hive box opened successfully');
//   } catch (e) {
//     print('Hive initialization error: $e');
//   }
//
//   // Initialize ads
//   await AdsService.initialize();
//
//   // Firebase Initialize
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//     print('Firebase initialized successfully');
//   } catch (e) {
//     print('Firebase initialization error: $e');
//   }
//
//   // Payment Service Initialize
//       PaymentService.initialize();
//   print('Payment service initialized');
//
//   // Notification Service Initialize
//   try {
//     await NotificationService.initialize();
//     print('Notification service initialized successfully');
//   } catch (e) {
//     print('Notification service error: $e');
//   }
//
//   runApp(const MyApp());
// }
//
// Future<List<int>> _getEncryptionKey() async {
//   final key = Hive.generateSecureKey();
//   return key;
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   static void handleNotificationNavigation(BuildContext context, Map<String, dynamic> data) {
//     print('🧭 Navigating from notification: $data');
//
//     String screen = data['screen']?.toString() ?? 'home';
//     String feature = data['feature']?.toString() ?? 'general';
//     String babyName = data['babyName']?.toString() ?? 'Baby';
//
//     print('📍 Target screen: $screen, feature: $feature');
//
//     // Close any open dialogs first
//     Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
//
//     // Water reminder special handling
//     if (feature == 'water_reminder') {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         '/baby-chat',
//             (route) => false,
//         arguments: {
//           'babyName': babyName,
//           'initialMessage': 'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙',
//           'isWaterReminder': true,
//         },
//       );
//       return;
//     }
//
//     // Baby chat handling
//     if (screen == 'baby_chat' || feature == 'baby_chat') {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         '/baby-chat',
//             (route) => false,
//         arguments: {
//           'babyName': babyName,
//           'initialMessage': data['message'] ?? 'Hi mumma! I missed you! 💕',
//         },
//       );
//       return;
//     }
//
//     // Medication reminder
//     if (feature == 'medication_reminder' || screen == 'medications') {
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         '/medication',
//             (route) => false,
//         arguments: data,
//       );
//       return;
//     }
//
//     // Other screens
//     switch (screen) {
//       case 'weekly_update':
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/weekly-development',
//               (route) => false,
//           arguments: data,
//         );
//         break;
//       case 'journal':
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/journal',
//               (route) => false,
//           arguments: data,
//         );
//         break;
//       case 'milestones':
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/milestones',
//               (route) => false,
//           arguments: data,
//         );
//         break;
//       case 'mood-tracker':
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/mood-tracker',
//               (route) => false,
//           arguments: data,
//         );
//         break;
//       case 'appointments':
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/appointments',
//               (route) => false,
//           arguments: data,
//         );
//         break;
//       default:
//         Navigator.of(context).pushNamedAndRemoveUntil(
//           '/main',
//               (route) => false,
//         );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Bump Bond",
//       debugShowCheckedModeBanner: false,
//       navigatorKey: navigatorKey,
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         scaffoldBackgroundColor: const Color(0xFFFFF5F7),
//         useMaterial3: true,
//       ),
//       initialRoute: '/splash',
//       routes: {
//         '/splash': (context) => const SplashScreen(),
//         '/main': (context) => const MainScreen(),
//         '/home': (context) => const MainScreen(),
//         '/notifications': (context) => const NotificationScreen(),
//
//         '/baby-chat': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//
//           String babyName = 'Baby';
//           String? initialMessage;
//           bool isWaterReminder = false;
//           Map<String, dynamic>? notificationData;
//
//           if (args != null && args is Map<String, dynamic>) {
//             babyName = args['babyName']?.toString() ?? 'Baby';
//             initialMessage = args['initialMessage']?.toString();
//             isWaterReminder = args['isWaterReminder'] == true;
//             notificationData = args;
//           }
//
//           print('👶 Opening baby chat with name: $babyName');
//           print('💧 Water reminder: $isWaterReminder');
//           print('📱 Initial message: $initialMessage');
//
//           return ChatScreen(
//             babyName: babyName,
//             notificationData: notificationData,
//             initialMessage: initialMessage,
//             isWaterReminder: isWaterReminder,
//           );
//         },
//
//         '/medication': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('💊 Opening medication screen with data: $args');
//           return const MedicationRemindersScreen();
//         },
//
//         '/weekly-development': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('📅 Opening weekly development screen with data: $args');
//           return const PregnancyJourneyScreen();
//         },
//
//         '/journal': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('📝 Opening journal screen with data: $args');
//           return const JournalScreen();
//         },
//
//         '/milestones': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('🎯 Opening milestones screen with data: $args');
//           return const MilestoneScreen();
//         },
//
//         '/mood-tracker': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('😊 Opening mood tracker screen with data: $args');
//           return const MoodSymptomTrackerScreen();
//         },
//
//         '/appointments': (context) {
//           final args = ModalRoute.of(context)?.settings.arguments;
//           print('🏥 Opening appointments screen with data: $args');
//           return const BookConsultationScreen();
//         },
//
//         '/settings': (context) => const SettingsScreen(),
//       },
//       onUnknownRoute: (settings) {
//         return MaterialPageRoute(
//           builder: (context) => const SplashScreen(),
//         );
//       },
//     );
//   }
// }
//
// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
//   int _selectedIndex = 0;
//   final PageController _pageController = PageController();
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const HealthTrackerScreen(),
//     const EducationScreen(),
//     const JournalScreen(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _checkPendingNotification();
//     });
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       _checkPendingNotification();
//     }
//   }
//
//   void _checkPendingNotification() {
//     if (_pendingNotificationData != null && mounted) {
//       print('📱 Processing pending notification: $_pendingNotificationData');
//       MyApp.handleNotificationNavigation(context, _pendingNotificationData!);
//       _pendingNotificationData = null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFFF5F7),
//       body: PageView(
//         controller: _pageController,
//         onPageChanged: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         children: _screens,
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.pink.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(Icons.home, 'Home', 0),
//                 _buildNavItem(Icons.favorite, 'Tracker', 1),
//                 _buildNavItem(Icons.school, 'Learn', 2),
//                 _buildNavItem(Icons.book, 'Journal', 3),
//                 _buildNavItem(Icons.menu, 'Menu', 4, isMenu: true),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavItem(IconData icon, String label, int index, {bool isMenu = false}) {
//     final isSelected = _selectedIndex == index;
//     return GestureDetector(
//       onTap: () {
//         if (isMenu) {
//           Navigator.pushNamed(context, '/settings');
//         } else {
//           setState(() {
//             _selectedIndex = index;
//           });
//           _pageController.jumpToPage(index);
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: !isMenu && isSelected ? const Color(0xFFB794F4) : null,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(
//               icon,
//               color: !isMenu && isSelected ? Colors.white : Colors.grey,
//               size: 20,
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 color: !isMenu && isSelected ? Colors.white : Colors.grey,
//                 fontSize: 10,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// // import 'dart:typed_data';
// // import 'dart:convert';
// // import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
// // import 'package:bump_bond_flutter_app/auth/milestones.dart';
// // import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
// // import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/book_consultation_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// // import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
// // import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// // import 'package:bump_bond_flutter_app/auth/notification_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/week_development_screen.dart';
// // import 'package:bump_bond_flutter_app/services/water_reminder_service.dart';
// // import 'package:flutter/material.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart';
// // import 'package:hive_flutter/hive_flutter.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'models/journal_entry.dart';
// // import 'package:bump_bond_flutter_app/services/notification_service.dart';
// // import 'package:bump_bond_flutter_app/services/payment_service.dart';
// // import 'package:bump_bond_flutter_app/services/ads_service.dart';
// //
// // const String journalBoxName = 'journal_box';
// // const String secureKeyName = 'hive_enc_key';
// //
// // Future<Uint8List> _getEncryptionKey() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   await WaterReminderService.initialize();
// //
// //   final secureStorage = FlutterSecureStorage();
// //   String? existing = await secureStorage.read(key: secureKeyName);
// //
// //   if (existing != null) {
// //     return base64Url.decode(existing);
// //   } else {
// //     final key = Hive.generateSecureKey();
// //     final encoded = base64Url.encode(key);
// //     await secureStorage.write(key: secureKeyName, value: encoded);
// //     return Uint8List.fromList(key);
// //   }
// // }
// //
// // Map<String, dynamic>? _pendingNotificationData;
// // GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //
// //   // ✅ SINGLE NOTIFICATION CALLBACK
// //   NotificationService.setNotificationTapCallback((data) {
// //     print('🔔 Global notification tap received: $data');
// //     _pendingNotificationData = data;
// //
// //     // Navigate immediately if app is running
// //     if (navigatorKey.currentState != null && _pendingNotificationData != null) {
// //       WidgetsBinding.instance.addPostFrameCallback((_) {
// //         MyApp.handleNotificationNavigation(
// //           navigatorKey.currentState!.context,
// //           _pendingNotificationData!,
// //         );
// //       });
// //     }
// //   });
// //
// //   // Hive initialization
// //   try {
// //     await Hive.initFlutter();
// //     print('Hive initialized successfully');
// //
// //     Hive.registerAdapter(JournalEntryAdapter());
// //     print('Hive adapters registered');
// //
// //     final encryptionKey = await _getEncryptionKey();
// //     print('Encryption key obtained');
// //
// //     await Hive.openBox<JournalEntry>(
// //       journalBoxName,
// //       encryptionCipher: HiveAesCipher(encryptionKey),
// //     );
// //     print('Hive box opened successfully');
// //   } catch (e) {
// //     print('Hive initialization error: $e');
// //   }
// //
// //   // Initialize ads
// //   await AdsService.initialize();
// //
// //   // Firebase Initialize
// //   try {
// //     await Firebase.initializeApp(
// //       options: DefaultFirebaseOptions.currentPlatform,
// //     );
// //     print('Firebase initialized successfully');
// //   } catch (e) {
// //     print('Firebase initialization error: $e');
// //   }
// //
// //   // Payment Service Initialize
// //   PaymentService.initialize();
// //   print('Payment service initialized');
// //
// //   // Notification Service Initialize
// //   try {
// //     await NotificationService.initialize();
// //     print('Notification service initialized successfully');
// //   } catch (e) {
// //     print('Notification service error: $e');
// //   }
// //
// //   runApp(const MyApp());
// // }
// //
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   static void handleNotificationNavigation(BuildContext context, Map<String, dynamic> data) {
// //     print('🧭 Navigating from notification: $data');
// //
// //     String screen = data['screen']?.toString() ?? 'home';
// //     String feature = data['feature']?.toString() ?? 'general';
// //     String babyName = data['babyName']?.toString() ?? 'Baby';
// //
// //     print('📍 Target screen: $screen, feature: $feature');
// //
// //     // Close any open dialogs first
// //     Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
// //
// //     // Water reminder special handling
// //     if (feature == 'water_reminder') {
// //       Navigator.of(context).pushNamedAndRemoveUntil(
// //         '/baby-chat',
// //             (route) => false,
// //         arguments: {
// //           'babyName': babyName,
// //           'initialMessage': 'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙',
// //           'isWaterReminder': true,
// //         },
// //       );
// //       return;
// //     }
// //
// //     // Baby chat handling
// //     if (screen == 'baby_chat' || feature == 'baby_chat') {
// //       Navigator.of(context).pushNamedAndRemoveUntil(
// //         '/baby-chat',
// //             (route) => false,
// //         arguments: {
// //           'babyName': babyName,
// //           'initialMessage': data['message'] ?? 'Hi mumma! I missed you! 💕',
// //         },
// //       );
// //       return;
// //     }
// //
// //     // Medication reminder
// //     if (feature == 'medication_reminder' || screen == 'medications') {
// //       Navigator.of(context).pushNamedAndRemoveUntil(
// //         '/medication',
// //             (route) => false,
// //         arguments: data,
// //       );
// //       return;
// //     }
// //
// //     // Other screens
// //     switch (screen) {
// //       case 'weekly_update':
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/weekly-development',
// //               (route) => false,
// //           arguments: data,
// //         );
// //         break;
// //       case 'journal':
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/journal',
// //               (route) => false,
// //           arguments: data,
// //         );
// //         break;
// //       case 'milestones':
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/milestones',
// //               (route) => false,
// //           arguments: data,
// //         );
// //         break;
// //       case 'mood-tracker':
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/mood-tracker',
// //               (route) => false,
// //           arguments: data,
// //         );
// //         break;
// //       case 'appointments':
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/appointments',
// //               (route) => false,
// //           arguments: data,
// //         );
// //         break;
// //       default:
// //       // Navigate to home and then show notification
// //         Navigator.of(context).pushNamedAndRemoveUntil(
// //           '/home',
// //               (route) => false,
// //         );
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: "Bump Bond",
// //       debugShowCheckedModeBanner: false,
// //       navigatorKey: navigatorKey,
// //       theme: ThemeData(
// //         primarySwatch: Colors.pink,
// //         scaffoldBackgroundColor: const Color(0xFFFFF5F7),
// //       ),
// //       home: const SplashScreen(),
// //       routes: {
// //         '/': (context) => const MainScreen(),
// //         '/main': (context) => const MainScreen(),
// //         '/home': (context) => const MainScreen(),
// //         '/notifications': (context) => const NotificationScreen(),
// //
// //         // ✅ FIXED BABY CHAT WITH PROPER NAVIGATION
// //         '/baby-chat': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //
// //           String babyName = 'Baby';
// //           String? initialMessage;
// //           bool isWaterReminder = false;
// //           Map<String, dynamic>? notificationData;
// //
// //           if (args != null && args is Map<String, dynamic>) {
// //             babyName = args['babyName']?.toString() ?? 'Baby';
// //             initialMessage = args['initialMessage']?.toString();
// //             isWaterReminder = args['isWaterReminder'] == true;
// //             notificationData = args;
// //           }
// //
// //           print('👶 Opening baby chat with name: $babyName');
// //           print('💧 Water reminder: $isWaterReminder');
// //           print('📱 Initial message: $initialMessage');
// //
// //           return ChatScreen(
// //             babyName: babyName,
// //             notificationData: notificationData,
// //             initialMessage: initialMessage,
// //             isWaterReminder: isWaterReminder,
// //           );
// //         },
// //
// //         '/medication': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('💊 Opening medication screen with data: $args');
// //           return const MedicationRemindersScreen();
// //         },
// //
// //         '/weekly-development': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('📅 Opening weekly development screen with data: $args');
// //           return const PregnancyJourneyScreen();
// //         },
// //
// //         '/journal': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('📝 Opening journal screen with data: $args');
// //           return const JournalScreen();
// //         },
// //
// //         '/milestones': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('🎯 Opening milestones screen with data: $args');
// //           return const MilestoneScreen();
// //         },
// //
// //         '/mood-tracker': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('😊 Opening mood tracker screen with data: $args');
// //           return const MoodSymptomTrackerScreen();
// //         },
// //
// //         '/appointments': (context) {
// //           final args = ModalRoute.of(context)?.settings.arguments;
// //           print('🏥 Opening appointments screen with data: $args');
// //           return const BookConsultationScreen();
// //         },
// //       },
// //     );
// //   }
// // }
// //
// // class MainScreen extends StatefulWidget {
// //   const MainScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }
// //
// // class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
// //   int _selectedIndex = 0;
// //   final PageController _pageController = PageController();
// //
// //   final List<Widget> _screens = [
// //     const HomeScreen(),
// //     const HealthTrackerScreen(),
// //     const EducationScreen(),
// //     const JournalScreen(),
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     WidgetsBinding.instance.addObserver(this);
// //
// //     // Check for pending notifications when app resumes
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _checkPendingNotification();
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     WidgetsBinding.instance.removeObserver(this);
// //     super.dispose();
// //   }
// //
// //   @override
// //   void didChangeAppLifecycleState(AppLifecycleState state) {
// //     if (state == AppLifecycleState.resumed) {
// //       // App came to foreground
// //       _checkPendingNotification();
// //     }
// //   }
// //
// //   void _checkPendingNotification() {
// //     if (_pendingNotificationData != null && mounted) {
// //       print('📱 Processing pending notification: $_pendingNotificationData');
// //       MyApp.handleNotificationNavigation(context, _pendingNotificationData!);
// //       _pendingNotificationData = null;
// //     }
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFFFF5F7),
// //       body: PageView(
// //         controller: _pageController,
// //         onPageChanged: (index) {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //         },
// //         children: _screens,
// //       ),
// //       bottomNavigationBar: Container(
// //         decoration: BoxDecoration(
// //           color: Colors.white,
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.pink.withOpacity(0.1),
// //               blurRadius: 10,
// //               offset: const Offset(0, -5),
// //             ),
// //           ],
// //         ),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _buildNavItem(Icons.home, 'Home', 0),
// //                 _buildNavItem(Icons.favorite, 'Tracker', 1),
// //                 _buildNavItem(Icons.school, 'Learn', 2),
// //                 _buildNavItem(Icons.book, 'Journal', 3),
// //                 _buildNavItem(Icons.menu, 'Menu', 4, isMenu: true),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildNavItem(IconData icon, String label, int index, {bool isMenu = false}) {
// //     final isSelected = _selectedIndex == index;
// //     return GestureDetector(
// //       onTap: () {
// //         if (isMenu) {
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (_) => const SettingsScreen()),
// //           );
// //         } else {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //           _pageController.jumpToPage(index);
// //         }
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         decoration: BoxDecoration(
// //           color: !isMenu && isSelected ? const Color(0xFFB794F4) : null,
// //           borderRadius: BorderRadius.circular(20),
// //         ),
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               icon,
// //               color: !isMenu && isSelected ? Colors.white : Colors.grey,
// //               size: 20,
// //             ),
// //             const SizedBox(height: 4),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 color: !isMenu && isSelected ? Colors.white : Colors.grey,
// //                 fontSize: 10,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //
// //
// // // import 'dart:typed_data';
// // // import 'dart:convert';
// // // import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
// // // import 'package:bump_bond_flutter_app/auth/milestones.dart';
// // // import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
// // // import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// // // import 'package:bump_bond_flutter_app/screens/book_consultation_screen.dart';
// // // import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
// // // import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// // // import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// // // import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// // // import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
// // // import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// // // import 'package:bump_bond_flutter_app/auth/notification_screen.dart'; // Added
// // // import 'package:bump_bond_flutter_app/screens/week_development_screen.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:firebase_core/firebase_core.dart';
// // // import 'firebase_options.dart';
// // // import 'package:hive_flutter/hive_flutter.dart';
// // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // import 'models/journal_entry.dart';
// // // import 'package:bump_bond_flutter_app/services/notification_service.dart';
// // // import 'package:bump_bond_flutter_app/services/payment_service.dart';
// // // import 'package:bump_bond_flutter_app/services/ads_service.dart';
// // // import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
// // // const String journalBoxName = 'journal_box';
// // // const String secureKeyName = 'hive_enc_key';
// // //
// // // Future<Uint8List> _getEncryptionKey() async {
// // //   final secureStorage = FlutterSecureStorage();
// // //   String? existing = await secureStorage.read(key: secureKeyName);
// // //
// // //   if (existing != null) {
// // //     return base64Url.decode(existing);
// // //   } else {
// // //     final key = Hive.generateSecureKey();
// // //     final encoded = base64Url.encode(key);
// // //     await secureStorage.write(key: secureKeyName, value: encoded);
// // //     return Uint8List.fromList(key);
// // //   }
// // // }
// // //
// // // Future<void> main() async {
// // //   WidgetsFlutterBinding.ensureInitialized();
// // //
// // //   // ✅ FIXED: Proper Hive initialization sequence
// // //   try {
// // //     // Step 1: Initialize Hive with Flutter
// // //     await Hive.initFlutter();
// // //     print('Hive initialized successfully');
// // //
// // //     // Step 2: Register adapters
// // //     Hive.registerAdapter(JournalEntryAdapter());
// // //     print('Hive adapters registered');
// // //
// // //     // Step 3: Get encryption key
// // //     final encryptionKey = await _getEncryptionKey();
// // //     print('Encryption key obtained');
// // //
// // //     // Step 4: Open encrypted box
// // //     await Hive.openBox<JournalEntry>(
// // //       journalBoxName,
// // //       encryptionCipher: HiveAesCipher(encryptionKey),
// // //     );
// // //     print('Hive box opened successfully');
// // //
// // //   } catch (e) {
// // //     print('Hive initialization error: $e');
// // //     // If Hive fails, continue with app but show error
// // //   }
// // //
// // //   // Initialize ads
// // //   await AdsService.initialize();
// // //
// // //   // Firebase Initialize
// // //   try {
// // //     await Firebase.initializeApp(
// // //       options: DefaultFirebaseOptions.currentPlatform,
// // //     );
// // //     print('Firebase initialized successfully');
// // //   } catch (e) {
// // //     print('Firebase initialization error: $e');
// // //   }
// // //
// // //   // ✅ Payment Service Initialize
// // //   PaymentService.initialize();
// // //   print('Payment service initialized');
// // //
// // //   // Notification Service Initialize
// // //   try {
// // //     await NotificationService.initialize();
// // //     print('Notification service initialized successfully');
// // //   } catch (e) {
// // //     print('Notification service error: $e');
// // //   }
// // //
// // //   runApp(const MyApp());
// // // }
// // //
// // // class MyApp extends StatelessWidget {
// // //   const MyApp({super.key});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return MaterialApp(
// // //       title: "Bump Bond",
// // //       debugShowCheckedModeBanner: false,
// // //       theme: ThemeData(primarySwatch: Colors.pink),
// // //       home: const SplashScreen(),
// // //       // ✅ ADDED: Routes for navigation
// // //       routes: {
// // //         '/main': (context) => const MainScreen(),
// // //         '/home': (context) => const MainScreen(),
// // //         '/notifications': (context) => const NotificationScreen(),
// // //         '/baby-chat': (context) {
// // //           final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
// // //
// // //           final babyName = args?['babyName']?.toString() ?? 'Baby';
// // //
// // //           return ChatScreen(
// // //             babyName: babyName,
// // //             notificationData: args,
// // //           );
// // //         },
// // //         '/medication': (context) {
// // //           final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
// // //           // Replace with your actual medication screen
// // //           return const MedicationRemindersScreen(); // Replace with MedicationScreen
// // //         },
// // //         '/hydration': (context) {
// // //           final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
// // //           // Replace with your actual hydration screen
// // //           return const Placeholder(); // Replace with HydrationScreen
// // //         },
// // //         '/weekly-development': (context) => const PregnancyJourneyScreen(), // Replace with actual screen
// // //         '/journal': (context) => const JournalScreen(),
// // //         '/milestones': (context) => const MilestoneScreen(), // Replace with actual screen
// // //         '/mood-tracker': (context) => const MoodSymptomTrackerScreen(), // Replace with actual screen
// // //         '/appointments': (context) => const BookConsultationScreen(), // Replace with actual screen
// // //       },
// // //     );
// // //   }
// // // }
// // //
// // // class MainScreen extends StatefulWidget {
// // //   const MainScreen({Key? key}) : super(key: key);
// // //
// // //   @override
// // //   State<MainScreen> createState() => _MainScreenState();
// // // }
// // //
// // // class _MainScreenState extends State<MainScreen> {
// // //   int _selectedIndex = 0;
// // //   final PageController _pageController = PageController();
// // //
// // //   final List<Widget> _screens = [
// // //     const HomeScreen(),
// // //     const HealthTrackerScreen(),
// // //     const EducationScreen(),
// // //     const JournalScreen(),
// // //   ];
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //   }
// // //
// // //   // ✅ ADDED: Global notification tap handler
// // //   void _handleNotificationTap(Map<String, dynamic> data) {
// // //     print('🔔 Global notification tap: $data');
// // //
// // //     String screen = data['screen']?.toString() ?? 'home';
// // //     String feature = data['feature']?.toString() ?? 'general';
// // //
// // //     print('Navigating to: $screen, feature: $feature');
// // //
// // //     // Handle different notification types
// // //     if (screen == 'baby_chat' || feature == 'baby_chat') {
// // //       // Navigate to baby chat
// // //       _navigateToScreen('/baby-chat', data);
// // //     }
// // //     else if (screen == 'medications' || feature == 'medication_reminder') {
// // //       // Navigate to medication screen
// // //       _navigateToScreen('/medication', data);
// // //     }
// // //     else if (screen == 'home' && feature == 'water_reminder') {
// // //       // Navigate to hydration screen
// // //       _navigateToScreen('/hydration', data);
// // //     }
// // //     else if (screen == 'weekly_update') {
// // //       Navigator.pushNamed(context, '/weekly-development');
// // //     }
// // //     else if (screen == 'journal') {
// // //       Navigator.pushNamed(context, '/journal');
// // //     }
// // //     else {
// // //       // Default: Stay on current screen
// // //       print('Notification tapped but staying on current screen');
// // //     }
// // //   }
// // //
// // //   void _navigateToScreen(String route, Map<String, dynamic> data) {
// // //     Navigator.pushNamed(context, route, arguments: data);
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFFFF5F7),
// // //       body: PageView(
// // //         controller: _pageController,
// // //         onPageChanged: (index) {
// // //           setState(() {
// // //             _selectedIndex = index;
// // //           });
// // //         },
// // //         children: _screens,
// // //       ),
// // //       bottomNavigationBar: Container(
// // //         decoration: BoxDecoration(
// // //           color: Colors.white,
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: Colors.pink.withOpacity(0.1),
// // //               blurRadius: 10,
// // //               offset: const Offset(0, -5),
// // //             ),
// // //           ],
// // //         ),
// // //         child: SafeArea(
// // //           child: Padding(
// // //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // //             child: Row(
// // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // //               children: [
// // //                 _buildNavItem(Icons.home, 'Home', 0),
// // //                 _buildNavItem(Icons.favorite, 'Tracker', 1),
// // //                 _buildNavItem(Icons.school, 'Learn', 2),
// // //                 _buildNavItem(Icons.book, 'Journal', 3),
// // //                 _buildNavItem(Icons.menu, 'Menu', 4, isMenu: true),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildNavItem(IconData icon, String label, int index, {bool isMenu = false}) {
// // //     final isSelected = _selectedIndex == index;
// // //     return GestureDetector(
// // //       onTap: () {
// // //         if (isMenu) {
// // //           Navigator.push(
// // //             context,
// // //             MaterialPageRoute(builder: (_) => const SettingsScreen()),
// // //           );
// // //         } else {
// // //           setState(() {
// // //             _selectedIndex = index;
// // //           });
// // //           _pageController.jumpToPage(index);
// // //         }
// // //       },
// // //       child: Container(
// // //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // //         decoration: BoxDecoration(
// // //           color: !isMenu && isSelected ? const Color(0xFFB794F4) : null,
// // //           borderRadius: BorderRadius.circular(20),
// // //         ),
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(
// // //               icon,
// // //               color: !isMenu && isSelected ? Colors.white : Colors.grey,
// // //               size: 20,
// // //             ),
// // //             const SizedBox(height: 4),
// // //             Text(
// // //               label,
// // //               style: TextStyle(
// // //                 color: !isMenu && isSelected ? Colors.white : Colors.grey,
// // //                 fontSize: 10,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // //
// // //
// // // // import 'dart:typed_data';
// // // // import 'dart:convert';
// // // // import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// // // // import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// // // // import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// // // // import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// // // // import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
// // // // import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:firebase_core/firebase_core.dart';
// // // // import 'firebase_options.dart';
// // // // import 'package:hive_flutter/hive_flutter.dart';
// // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // import 'models/journal_entry.dart';
// // // // import 'package:bump_bond_flutter_app/services/notification_service.dart';
// // // // import 'package:bump_bond_flutter_app/services/payment_service.dart';
// // // // import 'package:bump_bond_flutter_app/services/ads_service.dart';
// // // //
// // // // const String journalBoxName = 'journal_box';
// // // // const String secureKeyName = 'hive_enc_key';
// // // //
// // // // Future<Uint8List> _getEncryptionKey() async {
// // // //   final secureStorage = FlutterSecureStorage();
// // // //   String? existing = await secureStorage.read(key: secureKeyName);
// // // //
// // // //   if (existing != null) {
// // // //     return base64Url.decode(existing);
// // // //   } else {
// // // //     final key = Hive.generateSecureKey();
// // // //     final encoded = base64Url.encode(key);
// // // //     await secureStorage.write(key: secureKeyName, value: encoded);
// // // //     return Uint8List.fromList(key);
// // // //   }
// // // // }
// // // //
// // // // Future<void> main() async {
// // // //   WidgetsFlutterBinding.ensureInitialized();
// // // //
// // // //   // ✅ FIXED: Proper Hive initialization sequence
// // // //   try {
// // // //     // Step 1: Initialize Hive with Flutter
// // // //     await Hive.initFlutter();
// // // //     print('Hive initialized successfully');
// // // //
// // // //     // Step 2: Register adapters
// // // //     Hive.registerAdapter(JournalEntryAdapter());
// // // //     print('Hive adapters registered');
// // // //
// // // //     // Step 3: Get encryption key
// // // //     final encryptionKey = await _getEncryptionKey();
// // // //     print('Encryption key obtained');
// // // //
// // // //     // Step 4: Open encrypted box
// // // //     await Hive.openBox<JournalEntry>(
// // // //       journalBoxName,
// // // //       encryptionCipher: HiveAesCipher(encryptionKey),
// // // //     );
// // // //     print('Hive box opened successfully');
// // // //
// // // //   } catch (e) {
// // // //     print('Hive initialization error: $e');
// // // //     // If Hive fails, continue with app but show error
// // // //   }
// // // //
// // // //
// // // //   // Initialize ads
// // // //   await AdsService.initialize();
// // // //
// // // //
// // // //   // Firebase Initialize
// // // //   try {
// // // //     await Firebase.initializeApp(
// // // //       options: DefaultFirebaseOptions.currentPlatform,
// // // //     );
// // // //     print('Firebase initialized successfully');
// // // //   } catch (e) {
// // // //     print('Firebase initialization error: $e');
// // // //   }
// // // //
// // // //   // ✅ Payment Service Initialize
// // // //   PaymentService.initialize();
// // // //   print('Payment service initialized');
// // // //
// // // //   // Notification Service Initialize
// // // //   try {
// // // //     await NotificationService.initialize();
// // // //     print('Notification service initialized successfully');
// // // //   } catch (e) {
// // // //     print('Notification service error: $e');
// // // //   }
// // // //
// // // //   runApp(const MyApp());
// // // // }
// // // //
// // // // class MyApp extends StatelessWidget {
// // // //   const MyApp({super.key});
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return MaterialApp(
// // // //       title: "Bump Bond",
// // // //       debugShowCheckedModeBanner: false,
// // // //       theme: ThemeData(primarySwatch: Colors.pink),
// // // //       home: const SplashScreen(),
// // // //     );
// // // //   }
// // // // }
// // // //
// // // // class MainScreen extends StatefulWidget {
// // // //   const MainScreen({Key? key}) : super(key: key);
// // // //
// // // //   @override
// // // //   State<MainScreen> createState() => _MainScreenState();
// // // // }
// // // //
// // // // class _MainScreenState extends State<MainScreen> {
// // // //   int _selectedIndex = 0;
// // // //   final PageController _pageController = PageController();
// // // //
// // // //   final List<Widget> _screens = [
// // // //     const HomeScreen(),
// // // //     const HealthTrackerScreen(),
// // // //     const EducationScreen(),
// // // //     const JournalScreen(),
// // // //   ];
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFFFFF5F7),
// // // //       body: PageView(
// // // //         controller: _pageController,
// // // //         onPageChanged: (index) {
// // // //           setState(() {
// // // //             _selectedIndex = index;
// // // //           });
// // // //         },
// // // //         children: _screens,
// // // //       ),
// // // //       bottomNavigationBar: Container(
// // // //         decoration: BoxDecoration(
// // // //           color: Colors.white,
// // // //           boxShadow: [
// // // //             BoxShadow(
// // // //               color: Colors.pink.withOpacity(0.1),
// // // //               blurRadius: 10,
// // // //               offset: const Offset(0, -5),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //         child: SafeArea(
// // // //           child: Padding(
// // // //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // // //             child: Row(
// // // //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// // // //               children: [
// // // //                 _buildNavItem(Icons.home, 'Home', 0),
// // // //                 _buildNavItem(Icons.favorite, 'Tracker', 1),
// // // //                 _buildNavItem(Icons.school, 'Learn', 2),
// // // //                 _buildNavItem(Icons.book, 'Journal', 3),
// // // //                 _buildNavItem(Icons.menu, 'Menu', 4, isMenu: true),
// // // //               ],
// // // //             ),
// // // //           ),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // //
// // // //   Widget _buildNavItem(IconData icon, String label, int index, {bool isMenu = false}) {
// // // //     final isSelected = _selectedIndex == index;
// // // //     return GestureDetector(
// // // //       onTap: () {
// // // //         if (isMenu) {
// // // //           Navigator.push(
// // // //             context,
// // // //             MaterialPageRoute(builder: (_) => const SettingsScreen()),
// // // //           );
// // // //         } else {
// // // //           setState(() {
// // // //             _selectedIndex = index;
// // // //           });
// // // //           _pageController.jumpToPage(index);
// // // //         }
// // // //       },
// // // //       child: Container(
// // // //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// // // //         decoration: BoxDecoration(
// // // //           color: !isMenu && isSelected ? const Color(0xFFB794F4) : null,
// // // //           borderRadius: BorderRadius.circular(20),
// // // //         ),
// // // //         child: Column(
// // // //           mainAxisSize: MainAxisSize.min,
// // // //           children: [
// // // //             Icon(
// // // //               icon,
// // // //               color: !isMenu && isSelected ? Colors.white : Colors.grey,
// // // //               size: 20,
// // // //             ),
// // // //             const SizedBox(height: 4),
// // // //             Text(
// // // //               label,
// // // //               style: TextStyle(
// // // //                 color: !isMenu && isSelected ? Colors.white : Colors.grey,
// // // //                 fontSize: 10,
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }
import 'dart:typed_data';
import 'dart:convert';
import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
import 'package:bump_bond_flutter_app/screens/education_screen.dart';
import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
import 'package:bump_bond_flutter_app/screens/home_screen.dart';
import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'models/journal_entry.dart';
import 'package:bump_bond_flutter_app/services/notification_service.dart';

const String journalBoxName = 'journal_box';
const String secureKeyName = 'hive_enc_key';

Future<Uint8List> _getEncryptionKey() async {
  final secureStorage = FlutterSecureStorage();
  String? existing = await secureStorage.read(key: secureKeyName);

  if (existing != null) {
    return base64Url.decode(existing);
  } else {
    final key = Hive.generateSecureKey();
    final encoded = base64Url.encode(key);
    await secureStorage.write(key: secureKeyName, value: encoded);
    return Uint8List.fromList(key);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase Initialize
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive initialization
  await Hive.initFlutter();
  Hive.registerAdapter(JournalEntryAdapter());

  // Encryption Key setup
  final encryptionKey = await _getEncryptionKey();
  await Hive.openBox<JournalEntry>(
    journalBoxName,
    encryptionCipher: HiveAesCipher(encryptionKey),
  );

  // Notification Service Initialize
  await NotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Bump Bond",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.pink),
      home: const SplashScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const HealthTrackerScreen(),
    const EducationScreen(),
    const JournalScreen(),
  ];

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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          );
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


// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// import 'package:bump_bond_flutter_app/screens/journal_screen.dart' hide JournalEntry;
// import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'models/journal_entry.dart';
// import 'package:bump_bond_flutter_app/services/notification_service.dart';
//
// const String journalBoxName = 'journal_box';
// const String secureKeyName = 'hive_enc_key';
//
// /// Generate or fetch encryption key safely
// Future<Uint8List> _getEncryptionKey() async {
//   final secureStorage = const FlutterSecureStorage();
//   String? existing = await secureStorage.read(key: secureKeyName);
//
//   if (existing != null) {
//     return base64Url.decode(existing);
//   } else {
//     final key = Hive.generateSecureKey();
//     final encoded = base64Url.encode(key);
//     await secureStorage.write(key: secureKeyName, value: encoded);
//     return Uint8List.fromList(key);
//   }
// }
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   // ✅ Firebase Initialize
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // ✅ Hive initialization
//   await Hive.initFlutter();
//   Hive.registerAdapter(JournalEntryAdapter());
//
//   // ✅ Encryption Key setup
//   final encryptionKey = await _getEncryptionKey();
//   await Hive.openBox<JournalEntry>(
//     journalBoxName,
//     encryptionCipher: HiveAesCipher(encryptionKey),
//   );
//
//   // ✅ Timezone setup
//   tz.initializeTimeZones();
//   tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
//
//   // ✅ Notification Service Initialize
//   await NotificationService.initialize();
//
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Bump Bond",
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//       ),
//       home: const SplashScreen(),
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
// class _MainScreenState extends State<MainScreen> {
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
//           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
//         ),
//         child: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 _buildNavItem(Icons.home_rounded, 'Home', 0),
//                 _buildNavItem(Icons.favorite_rounded, 'Tracker', 1),
//                 _buildNavItem(Icons.school_rounded, 'Learn', 2),
//                 _buildNavItem(Icons.book_rounded, 'Journal', 3),
//                 _buildNavItem(Icons.menu_rounded, 'Menu', 5, isMenu: true),
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
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (_) => const SettingsScreen()),
//           );
//         } else {
//           setState(() {
//             _selectedIndex = index;
//           });
//           _pageController.animateToPage(
//             index,
//             duration: const Duration(milliseconds: 300),
//             curve: Curves.easeInOut,
//           );
//         }
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           gradient: !isMenu && isSelected
//               ? const LinearGradient(
//             colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
//           )
//               : null,
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
//                 fontWeight: !isMenu && isSelected ? FontWeight.w600 : FontWeight.normal,
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
// // import 'dart:typed_data';
// // import 'dart:convert';
// // import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
// // import 'package:timezone/data/latest.dart' as tz;
// // import 'package:timezone/timezone.dart' as tz;
// // import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// // import 'package:bump_bond_flutter_app/auth/health_tracker_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/home_screen.dart';
// // import 'package:bump_bond_flutter_app/screens/journal_screen.dart';
// // import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:firebase_core/firebase_core.dart';
// // import 'firebase_options.dart';
// // import 'screens/chat_screen.dart';
// // import 'package:hive_flutter/hive_flutter.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'models/journal_entry.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:bump_bond_flutter_app/services/notification_service.dart';
// // import 'package:intl/intl.dart';
// //
// //
// //
// // // ✅ Background message handler (top-level function required)
// // @pragma('vm:entry-point')
// // Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
// //   await Firebase.initializeApp();
// //   print('🔔 Background Message: ${message.notification?.title}');
// // }
// //
// //
// // const String journalBoxName = 'journal_box';
// // const String secureKeyName = 'hive_enc_key';
// //
// // /// Generate or fetch encryption key safely
// // Future<Uint8List> _getEncryptionKey() async {
// //   final secureStorage = const FlutterSecureStorage();
// //
// //   String? existing = await secureStorage.read(key: secureKeyName);
// //
// //   if (existing != null) {
// //     // decode base64 to Uint8List
// //     return base64Url.decode(existing);
// //   } else {
// //     // Generate a secure random 32 byte key
// //     final key = Hive.generateSecureKey();
// //     final encoded = base64Url.encode(key);
// //     await secureStorage.write(key: secureKeyName, value: encoded);
// //     return Uint8List.fromList(key);
// //   }
// // }
// //
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Firebase.initializeApp();
// //
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //
// //   // Notification permission lo
// //   FirebaseMessaging messaging = FirebaseMessaging.instance;
// //   await messaging.requestPermission();
// //
// //   // ✅ Initialize Notifications
// //   await NotificationService.initialize();
// //
// //   // ✅ Set background message handler
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //
// //
// //   // Background message handler
// //   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
// //
// //   // Hive initialization
// //   await Hive.initFlutter();
// //   Hive.registerAdapter(JournalEntryAdapter());
// //
// //   // Encryption Key setup
// //   final encryptionKey = await _getEncryptionKey();
// //   await Hive.openBox<JournalScreen>(
// //     journalBoxName,
// //     encryptionCipher: HiveAesCipher(encryptionKey),
// //   );
// //
// //   // Timezone setup
// //   tz.initializeTimeZones();
// //   tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
// //
// //   if (Firebase.apps.isEmpty) {
// //     await Firebase.initializeApp(
// //       options: DefaultFirebaseOptions.currentPlatform,
// //     );
// //   }
// //
// //   runApp(const MyApp());
// // }
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: "Bump Bond",
// //       debugShowCheckedModeBanner: false,
// //       theme: ThemeData(
// //         primarySwatch: Colors.pink,
// //       ),
// //       home: const SplashScreen(),
// //     );
// //   }
// // }
// //
// //
// // class MainScreen extends StatefulWidget {
// //   const MainScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<MainScreen> createState() => _MainScreenState();
// // }
// //
// // class _MainScreenState extends State<MainScreen> {
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
// //           borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
// //         ),
// //         child: SafeArea(
// //           child: Padding(
// //             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.spaceAround,
// //               children: [
// //                 _buildNavItem(Icons.home_rounded, 'Home', 0),
// //                 _buildNavItem(Icons.favorite_rounded, 'Tracker', 1),
// //                 _buildNavItem(Icons.school_rounded, 'Learn', 2),
// //                 _buildNavItem(Icons.book_rounded, 'Journal', 3),
// //                 _buildNavItem(Icons.menu_rounded, 'Menu', 5, isMenu: true),
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
// //           // Open Settings screen
// //           Navigator.push(
// //             context,
// //             MaterialPageRoute(builder: (_) => const SettingsScreen()),
// //           );
// //         } else {
// //           setState(() {
// //             _selectedIndex = index;
// //           });
// //           _pageController.animateToPage(
// //             index,
// //             duration: const Duration(milliseconds: 300),
// //             curve: Curves.easeInOut,
// //           );
// //         }
// //       },
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //         decoration: BoxDecoration(
// //           gradient: !isMenu && isSelected
// //               ? const LinearGradient(
// //             colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
// //           )
// //               : null,
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
// //                 fontWeight: !isMenu && isSelected ? FontWeight.w600 : FontWeight.normal,
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

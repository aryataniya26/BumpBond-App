import 'dart:async';
import 'package:bump_bond_flutter_app/screens/baby_nickname_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bump_bond_flutter_app/models/pregnancy_data.dart';
import 'package:bump_bond_flutter_app/auth/onboarding_screen.dart';
import 'package:bump_bond_flutter_app/screens/due_date_setup_screen.dart';
import 'package:bump_bond_flutter_app/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthFlow();
  }

  void _setupAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }
  Future<void> _checkAuthFlow() async {
    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    print('🔍 SplashScreen Debug:');
    print('Firebase User: $user');
    print('isLoggedIn Flag: $isLoggedIn');

    // ✅ Case 1: User is properly logged in (BOTH Firebase AND our flag)
    if (user != null && isLoggedIn) {
      final pregnancyData = await PregnancyData.loadFromPrefs();

      print('Due Date: ${pregnancyData.dueDate}');
      print('Last Period: ${pregnancyData.lastPeriodDate}');
      print('Baby Nickname: ${pregnancyData.babyNickname}');

      if (pregnancyData.dueDate != null &&
          pregnancyData.lastPeriodDate != null &&
          pregnancyData.babyNickname != null &&
          pregnancyData.babyNickname!.isNotEmpty) {
        // ✅ COMPLETE SETUP - Go to Main Screen
        print('🚀 Redirecting to MainScreen - Setup Complete');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      } else if (pregnancyData.dueDate != null && pregnancyData.lastPeriodDate != null) {
        // ✅ HAS DUE DATE but no nickname
        print('👶 Redirecting to BabyNicknameScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BabyNicknameScreen(pregnancyData: pregnancyData)),
              (route) => false,
        );
      } else {
        // LOGGED IN but no pregnancy data
        print('📅 Redirecting to DueDateSetupScreen');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
              (route) => false,
        );
      }
    }
    // ✅ Case 2: User has Firebase session but our flag is missing (FIX STATE)
    else if (user != null && !isLoggedIn) {
      print('🔄 Fixing missing login state...');
      await prefs.setBool('isLoggedIn', true);

      // Retry the check
      _checkAuthFlow();
      return;
    }
    // ✅ Case 3: User is NOT logged in
    else {
      print('🎯 Redirecting to Onboarding - Not Logged In');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            (route) => false,
      );
    }
  }




  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB794F4), Color(0xFF9C7ECE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // App Name
                  const Text(
                    "Bump Bond",
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Tagline
                  const Text(
                    "AI-Powered Pregnancy Companion",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),

                  // Loading Indicator
                  const SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



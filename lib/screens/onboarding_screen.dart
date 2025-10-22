import 'package:bump_bond_flutter_app/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Welcome to Bump Bond",
      "desc": "Your AI-powered pregnancy companion for every step of your beautiful journey.",
      "image": "https://cdn-icons-png.flaticon.com/128/6381/6381743.png",
      "color": const Color(0xFFBBA0FF),
      "gradient": const [Color(0xFFBBA0FF), Color(0xFFD9CFFF)],
    },
    {
      "title": "Track Your Health",
      "desc": "Log moods, symptoms, medications & milestones easily with our intuitive tracking tools.",
      "image": "https://cdn-icons-png.flaticon.com/512/2966/2966486.png",
      "color": const Color(0xFFD8B4FE),
      "gradient": const [Color(0xFFD8B4FE), Color(0xFFF3E8FF)],
    },
    {
      "title": "AI Baby Companion",
      "desc": "Chat with your baby persona and receive personalized tips tailored just for you.",
      "image": "https://cdn-icons-png.flaticon.com/128/2867/2867024.png",
      "color": const Color(0xFFB794F4),
      "gradient": const [Color(0xFFB794F4), Color(0xFFEDE9FE)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fadeController.reset();
    _fadeController.forward();
    _scaleController.reset();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF8F5FF),
              onboardingData[_currentIndex]["gradient"][0].withOpacity(0.2),
              const Color(0xFFF3E8FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_currentIndex != onboardingData.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page View
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: _onPageChanged,
                  itemCount: onboardingData.length,
                  itemBuilder: (_, index) {
                    return FadeTransition(
                      opacity: _fadeController,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Image with Animation
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                                CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
                              ),
                              child: Container(
                                width: 260,
                                height: 260,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: onboardingData[index]["gradient"],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(36),
                                  boxShadow: [
                                    BoxShadow(
                                      color: onboardingData[index]["color"].withOpacity(0.25),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 220,
                                    height: 220,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.95),
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    padding: const EdgeInsets.all(32),
                                    child: Image.network(
                                      onboardingData[index]["image"]!,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 50),

                            // Title
                            Text(
                              onboardingData[index]["title"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Description
                            Text(
                              onboardingData[index]["desc"]!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Section
              Container(
                padding: const EdgeInsets.all(28),
                child: Column(
                  children: [
                    // Page Indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        onboardingData.length,
                            (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 5),
                          width: _currentIndex == index ? 36 : 12,
                          height: 12,
                          decoration: BoxDecoration(
                            gradient: _currentIndex == index
                                ? LinearGradient(
                              colors: onboardingData[_currentIndex]["gradient"],
                            )
                                : null,
                            color: _currentIndex == index ? null : const Color(0xFFD1D5DB),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: _currentIndex == index
                                ? [
                              BoxShadow(
                                color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : null,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Action Button
                    _currentIndex == onboardingData.length - 1
                        ? _buildGetStartedButton()
                        : _buildNextButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: onboardingData[_currentIndex]["gradient"]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _completeOnboarding,
          borderRadius: BorderRadius.circular(16),
          child: const Center(
            child: Text(
              "Get Started",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Row(
      children: [
        if (_currentIndex > 0)
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _controller.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                },
                borderRadius: BorderRadius.circular(16),
                child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6B7280), size: 26),
              ),
            ),
          ),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: onboardingData[_currentIndex]["gradient"]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
                },
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text(
                    "Next",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

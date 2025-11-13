import 'package:bump_bond_flutter_app/auth/login_screen.dart';
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
  late AnimationController _slideController;

  final List<Map<String, dynamic>> onboardingData = [
    {
      "title": "Welcome to Bump Bond",
      "desc": "Your personal pregnancy companion, offering AI-powered guidance and support throughout your beautiful journey to motherhood.",
      "image": "https://cdn-icons-png.flaticon.com/512/3079/3079165.png",
      "color": Color(0xFF8B5CF6),
      "gradient": [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    },
    {
      "title": "Track Your Wellness",
      "desc": "Easily monitor your health with intuitive tools for mood tracking, symptom logging, medication reminders, and milestone celebrations.",
      "image": "https://cdn-icons-png.flaticon.com/512/2966/2966486.png",
      "color": Color(0xFFEC4899),
      "gradient": [Color(0xFFEC4899), Color(0xFFF472B6)],
    },
    {
      "title": "AI-Powered Insights",
      "desc": "Experience personalized guidance with our AI companion, offering tailored advice and connecting you with your baby's development.",
      "image": "https://cdn-icons-png.flaticon.com/512/4712/4712035.png",
      "color": Color(0xFF06B6D4),
      "gradient": [Color(0xFF06B6D4), Color(0xFF67E8F9)],
    },
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _fadeController.dispose();
    _slideController.dispose();
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
          var curve = Curves.easeInOut;
          var tween = Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));
          return FadeTransition(
            opacity: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    _fadeController.reset();
    _fadeController.forward();
    _slideController.reset();
    _slideController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _currentIndex != onboardingData.length - 1
                    ? TextButton(
                  onPressed: _completeOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: Color(0xFF6B7280),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )
                    : const SizedBox(height: 48),
              ),
            ),

            // Page View
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _controller,
                onPageChanged: _onPageChanged,
                itemCount: onboardingData.length,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image with professional styling
                        AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: onboardingData[index]["color"].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: onboardingData[index]["color"].withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: Offset(0, 10),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(32),
                              child: Image.network(
                                onboardingData[index]["image"]!,
                                fit: BoxFit.contain,
                                color: onboardingData[index]["color"],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Title with slide animation
                        SlideTransition(
                          position: Tween<Offset>(
                            begin: Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _slideController,
                            curve: Curves.easeOutCubic,
                          )),
                          child: FadeTransition(
                            opacity: _fadeController,
                            child: Text(
                              onboardingData[index]["title"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Description
                        FadeTransition(
                          opacity: _fadeController,
                          child: Text(
                            onboardingData[index]["desc"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF6B7280),
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentIndex == index ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? onboardingData[index]["color"]
                              : Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Action Button
                  _currentIndex == onboardingData.length - 1
                      ? _buildGetStartedButton()
                      : _buildNavigationButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetStartedButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _completeOnboarding,
        style: ElevatedButton.styleFrom(
          backgroundColor: onboardingData[_currentIndex]["color"],
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: onboardingData[_currentIndex]["color"].withOpacity(0.3),
        ),
        child: const Text(
          "Get Started",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        // Back Button
        if (_currentIndex > 0)
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Color(0xFFE5E7EB), width: 1.5),
            ),
            child: IconButton(
              onPressed: () {
                _controller.previousPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              icon: Icon(Icons.arrow_back_rounded, color: Color(0xFF6B7280), size: 24),
            ),
          ),

        // Next Button
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: onboardingData[_currentIndex]["color"],
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextButton(
              onPressed: () {
                _controller.nextPage(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Next",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


// import 'package:bump_bond_flutter_app/auth/login_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});
//
//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }
//
// class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
//   final PageController _controller = PageController();
//   int _currentIndex = 0;
//   late AnimationController _fadeController;
//   late AnimationController _scaleController;
//
//   final List<Map<String, dynamic>> onboardingData = [
//     {
//       "title": "Welcome to Bump Bond",
//       "desc": "Your AI-powered pregnancy companion for every step of your beautiful journey.",
//       "image": "https://cdn-icons-png.flaticon.com/128/6381/6381743.png",
//       "color": const Color(0xFFBBA0FF),
//       "gradient": const [Color(0xFFBBA0FF), Color(0xFFD9CFFF)],
//     },
//     {
//       "title": "Track Your Health",
//       "desc": "Log moods, symptoms, medications & milestones easily with our intuitive tracking tools.",
//       "image": "https://cdn-icons-png.flaticon.com/512/2966/2966486.png",
//       "color": const Color(0xFFD8B4FE),
//       "gradient": const [Color(0xFFD8B4FE), Color(0xFFF3E8FF)],
//     },
//     {
//       "title": "AI Baby Companion",
//       "desc": "Chat with your baby persona and receive personalized tips tailored just for you.",
//       "image": "https://cdn-icons-png.flaticon.com/128/2867/2867024.png",
//       "color": const Color(0xFFB794F4),
//       "gradient": const [Color(0xFFB794F4), Color(0xFFEDE9FE)],
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 600),
//     )..forward();
//
//     _scaleController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 800),
//     )..forward();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _fadeController.dispose();
//     _scaleController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _completeOnboarding() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('seenOnboarding', true);
//     Navigator.pushReplacement(
//       context,
//       PageRouteBuilder(
//         pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
//         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//           return FadeTransition(opacity: animation, child: child);
//         },
//         transitionDuration: const Duration(milliseconds: 500),
//       ),
//     );
//   }
//
//   void _onPageChanged(int index) {
//     setState(() {
//       _currentIndex = index;
//     });
//     _fadeController.reset();
//     _fadeController.forward();
//     _scaleController.reset();
//     _scaleController.forward();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               const Color(0xFFF8F5FF),
//               onboardingData[_currentIndex]["gradient"][0].withOpacity(0.2),
//               const Color(0xFFF3E8FF),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Skip Button
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     if (_currentIndex != onboardingData.length - 1)
//                       TextButton(
//                         onPressed: _completeOnboarding,
//                         style: TextButton.styleFrom(
//                           foregroundColor: const Color(0xFF9CA3AF),
//                           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                         ),
//                         child: const Text(
//                           "Skip",
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//
//               // Page View
//               Expanded(
//                 child: PageView.builder(
//                   controller: _controller,
//                   onPageChanged: _onPageChanged,
//                   itemCount: onboardingData.length,
//                   itemBuilder: (_, index) {
//                     return FadeTransition(
//                       opacity: _fadeController,
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 32),
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Image with Animation
//                             ScaleTransition(
//                               scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//                                 CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
//                               ),
//                               child: Container(
//                                 width: 260,
//                                 height: 260,
//                                 decoration: BoxDecoration(
//                                   gradient: LinearGradient(
//                                     colors: onboardingData[index]["gradient"],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(36),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: onboardingData[index]["color"].withOpacity(0.25),
//                                       blurRadius: 20,
//                                       offset: const Offset(0, 10),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Center(
//                                   child: Container(
//                                     width: 220,
//                                     height: 220,
//                                     decoration: BoxDecoration(
//                                       color: Colors.white.withOpacity(0.95),
//                                       borderRadius: BorderRadius.circular(28),
//                                     ),
//                                     padding: const EdgeInsets.all(32),
//                                     child: Image.network(
//                                       onboardingData[index]["image"]!,
//                                       fit: BoxFit.contain,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//
//                             const SizedBox(height: 50),
//
//                             // Title
//                             Text(
//                               onboardingData[index]["title"]!,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 fontSize: 26,
//                                 fontWeight: FontWeight.bold,
//                                 color: Color(0xFF1F2937),
//                                 height: 1.3,
//                               ),
//                             ),
//
//                             const SizedBox(height: 16),
//
//                             // Description
//                             Text(
//                               onboardingData[index]["desc"]!,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(
//                                 fontSize: 15,
//                                 color: Color(0xFF6B7280),
//                                 height: 1.6,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//               // Bottom Section
//               Container(
//                 padding: const EdgeInsets.all(28),
//                 child: Column(
//                   children: [
//                     // Page Indicators
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: List.generate(
//                         onboardingData.length,
//                             (index) => AnimatedContainer(
//                           duration: const Duration(milliseconds: 300),
//                           margin: const EdgeInsets.symmetric(horizontal: 5),
//                           width: _currentIndex == index ? 36 : 12,
//                           height: 12,
//                           decoration: BoxDecoration(
//                             gradient: _currentIndex == index
//                                 ? LinearGradient(
//                               colors: onboardingData[_currentIndex]["gradient"],
//                             )
//                                 : null,
//                             color: _currentIndex == index ? null : const Color(0xFFD1D5DB),
//                             borderRadius: BorderRadius.circular(6),
//                             boxShadow: _currentIndex == index
//                                 ? [
//                               BoxShadow(
//                                 color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
//                                 blurRadius: 6,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ]
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 32),
//
//                     // Action Button
//                     _currentIndex == onboardingData.length - 1
//                         ? _buildGetStartedButton()
//                         : _buildNextButton(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildGetStartedButton() {
//     return Container(
//       width: double.infinity,
//       height: 56,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: onboardingData[_currentIndex]["gradient"]),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
//             blurRadius: 16,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _completeOnboarding,
//           borderRadius: BorderRadius.circular(16),
//           child: const Center(
//             child: Text(
//               "Get Started",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNextButton() {
//     return Row(
//       children: [
//         if (_currentIndex > 0)
//           Container(
//             width: 56,
//             height: 56,
//             margin: const EdgeInsets.only(right: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
//               boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 3))],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   _controller.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//                 },
//                 borderRadius: BorderRadius.circular(16),
//                 child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF6B7280), size: 26),
//               ),
//             ),
//           ),
//         Expanded(
//           child: Container(
//             height: 56,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(colors: onboardingData[_currentIndex]["gradient"]),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: onboardingData[_currentIndex]["color"].withOpacity(0.3),
//                   blurRadius: 16,
//                   offset: const Offset(0, 6),
//                 ),
//               ],
//             ),
//             child: Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: () {
//                   _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
//                 },
//                 borderRadius: BorderRadius.circular(16),
//                 child: const Center(
//                   child: Text(
//                     "Next",
//                     style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.3),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

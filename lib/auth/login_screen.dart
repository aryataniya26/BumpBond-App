import 'package:bump_bond_flutter_app/main.dart';
import 'package:bump_bond_flutter_app/models/pregnancy_data.dart';
import 'package:bump_bond_flutter_app/screens/baby_nickname_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bump_bond_flutter_app/services/auth_service.dart';
import '../screens/due_date_setup_screen.dart';
import 'phone_login_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  // Login Controllers
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Signup Controllers
  final TextEditingController signupEmailController = TextEditingController();
  final TextEditingController signupPasswordController = TextEditingController();
  final TextEditingController signupConfirmPasswordController = TextEditingController();

  bool isLoading = false;
  late SharedPreferences prefs;
  late TabController _tabController;
  bool _showLoginPassword = false;
  bool _showSignupPassword = false;
  bool _showSignupConfirmPassword = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initPrefs();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }



  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (loggedIn && mounted) {
      // ✅ Check if pregnancy data exists and is complete
      PregnancyData pregnancyData = await PregnancyData.loadFromPrefs();

      print('🔍 LoginScreen Debug:');
      print('Due Date: ${pregnancyData.dueDate}');
      print('Last Period: ${pregnancyData.lastPeriodDate}');
      print('Baby Nickname: ${pregnancyData.babyNickname}');
      print('Is Setup Complete: ${pregnancyData.dueDate != null && pregnancyData.lastPeriodDate != null && pregnancyData.babyNickname != null}');

      // ✅ COMPLETE SETUP CHECK - All 3 conditions must be true
      if (pregnancyData.dueDate != null &&
          pregnancyData.lastPeriodDate != null &&
          pregnancyData.babyNickname != null &&
          pregnancyData.babyNickname!.isNotEmpty) {

        // ✅ User has COMPLETED full setup - Go DIRECTLY to MainScreen
        print('🚀 Redirecting to MainScreen - Setup Complete');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );

      } else if (pregnancyData.dueDate != null && pregnancyData.lastPeriodDate != null) {
        // ✅ User has due date but no nickname - Go to Nickname Screen
        print('👶 Redirecting to BabyNicknameScreen - Missing Nickname');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BabyNicknameScreen(pregnancyData: pregnancyData)),
              (route) => false,
        );

      } else {
        // ✅ User logged in but no pregnancy data - Go to Setup
        print('📅 Redirecting to DueDateSetupScreen - No Data');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
              (route) => false,
        );
      }
    }
  }




  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    signupEmailController.dispose();
    signupPasswordController.dispose();
    signupConfirmPasswordController.dispose();
    _animController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loginWithEmail() async {
    String email = loginEmailController.text.trim();
    String password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please enter email and password", isError: true);
      return;
    }

    setState(() => isLoading = true);
    final error = await _authService.loginWithEmail(email, password);

    if (error != null) {
      setState(() => isLoading = false);
      _showSnackBar(error, isError: true);
    } else {
      // ✅ CRITICAL FIX: Save login state IMMEDIATELY
      await prefs.setBool('isLoggedIn', true);

      // ✅ Check pregnancy data and navigate accordingly
      PregnancyData pregnancyData = await PregnancyData.loadFromPrefs();

      setState(() => isLoading = false);

      if (!mounted) return;

      if (pregnancyData.dueDate != null &&
          pregnancyData.lastPeriodDate != null &&
          pregnancyData.babyNickname != null &&
          pregnancyData.babyNickname!.isNotEmpty) {
        // ✅ Complete setup - go to MainScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      } else if (pregnancyData.dueDate != null && pregnancyData.lastPeriodDate != null) {
        // ✅ Has due date but no nickname
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BabyNicknameScreen(pregnancyData: pregnancyData)),
              (route) => false,
        );
      } else {
        // ❌ No pregnancy data - setup required
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
              (route) => false,
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    final error = await _authService.signInWithGoogle();

    if (error != null) {
      setState(() => isLoading = false);
      _showSnackBar(error, isError: true);
    } else {
      // ✅ CRITICAL FIX: Save login state
      await prefs.setBool('isLoggedIn', true);

      // ✅ Same pregnancy data check as above
      PregnancyData pregnancyData = await PregnancyData.loadFromPrefs();

      setState(() => isLoading = false);

      if (!mounted) return;

      // ✅ Use the SAME navigation logic as email login
      if (pregnancyData.dueDate != null &&
          pregnancyData.lastPeriodDate != null &&
          pregnancyData.babyNickname != null &&
          pregnancyData.babyNickname!.isNotEmpty) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
              (route) => false,
        );
      } else if (pregnancyData.dueDate != null && pregnancyData.lastPeriodDate != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => BabyNicknameScreen(pregnancyData: pregnancyData)),
              (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
              (route) => false,
        );
      }
    }
  }



  // SIGNUP FUNCTIONS
  Future<void> _signUpWithEmail() async {
    String email = signupEmailController.text.trim();
    String password = signupPasswordController.text.trim();
    String confirmPassword = signupConfirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar("Please fill all fields", isError: true);
      return;
    }

    setState(() => isLoading = true);
    final error = await _authService.signUpWithEmail(email, password, confirmPassword);
    setState(() => isLoading = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      _showSnackBar("Account created successfully! Please login", isError: false);

      signupEmailController.clear();
      signupPasswordController.clear();
      signupConfirmPasswordController.clear();

      _tabController.animateTo(0);
      loginEmailController.text = email;
    }
  }

  // BUILD METHODS
  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onPasswordToggle,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB794F4).withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword && !showPassword,
            keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFFB794F4), size: 22)
                  : null,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.grey[400],
                  size: 22,
                ),
                onPressed: onPasswordToggle,
              )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey[200]!, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFB794F4), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildInputField(
            label: "Email Address",
            hint: "Enter your email",
            controller: loginEmailController,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Password",
            hint: "Enter your password",
            controller: loginPasswordController,
            isPassword: true,
            showPassword: _showLoginPassword,
            prefixIcon: Icons.lock_outline_rounded,
            onPasswordToggle: () {
              setState(() => _showLoginPassword = !_showLoginPassword);
            },
          ),

          // Forgot Password Link
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Color(0xFFB794F4),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB794F4), Color(0xFF9F7AEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB794F4).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _loginWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text(
                "Login",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "OR",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
            ],
          ),
          const SizedBox(height: 20),

          // Phone Login Button
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFB794F4).withOpacity(0.3), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB794F4).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PhoneLoginScreen()),
                );
              },
              icon: const Icon(
                Icons.phone_android_rounded,
                size: 24,
                color: Color(0xFFB794F4),
              ),
              label: const Text(
                "Login with Phone",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFFB794F4),
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Google Login Button
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey[300]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _loginWithGoogle,
              icon: Image.asset(
                'assets/google_logo.png',
                height: 24,
                width: 24,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.g_mobiledata_rounded,
                    size: 32,
                    color: Color(0xFF4285F4),
                  );
                },
              ),
              label: const Text(
                "Continue with Google",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Color(0xFF374151),
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _buildInputField(
            label: "Email Address",
            hint: "Enter your email",
            controller: signupEmailController,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Password",
            hint: "At least 6 characters",
            controller: signupPasswordController,
            isPassword: true,
            showPassword: _showSignupPassword,
            prefixIcon: Icons.lock_outline_rounded,
            onPasswordToggle: () {
              setState(() => _showSignupPassword = !_showSignupPassword);
            },
          ),
          const SizedBox(height: 20),
          _buildInputField(
            label: "Confirm Password",
            hint: "Re-enter password",
            controller: signupConfirmPasswordController,
            isPassword: true,
            showPassword: _showSignupConfirmPassword,
            prefixIcon: Icons.lock_outline_rounded,
            onPasswordToggle: () {
              setState(() => _showSignupConfirmPassword = !_showSignupConfirmPassword);
            },
          ),
          const SizedBox(height: 28),
          Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB794F4), Color(0xFF9F7AEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFB794F4).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: isLoading ? null : _signUpWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: isLoading
                  ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
                  : const Text(
                "Create Account",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text.rich(
              TextSpan(
                text: "Already have an account? ",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                children: const [
                  TextSpan(
                    text: "Login",
                    style: TextStyle(
                      color: Color(0xFFB794F4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFB794F4), Color(0xFF9F7AEA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Bump Bond",
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Your pregnancy journey companion",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: const Color(0xFFB794F4),
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        letterSpacing: 0.3,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                      tabs: const [
                        Tab(text: "Login"),
                        Tab(text: "Sign Up"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 30,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildLoginTab(),
                            _buildSignupTab(),
                          ],
                        ),
                      ),
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
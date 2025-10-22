import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bump_bond_flutter_app/services/auth_service.dart';
import 'due_date_setup_screen.dart';

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
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward();
  }

  Future<void> _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    bool loggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (loggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
      );
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
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(msg)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // LOGIN FUNCTIONS
  Future<void> _loginWithEmail() async {
    String email = loginEmailController.text.trim();
    String password = loginPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Enter email and password", isError: true);
      return;
    }

    setState(() => isLoading = true);
    final error = await _authService.loginWithEmail(email, password);
    setState(() => isLoading = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      await prefs.setBool('isLoggedIn', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
        );
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);
    final error = await _authService.signInWithGoogle();
    setState(() => isLoading = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      await prefs.setBool('isLoggedIn', true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DueDateSetupScreen()),
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
      _showSnackBar("Fill all fields", isError: true);
      return;
    }

    setState(() => isLoading = true);
    final error = await _authService.signUpWithEmail(email, password, confirmPassword);
    setState(() => isLoading = false);

    if (error != null) {
      _showSnackBar(error, isError: true);
    } else {
      _showSnackBar("Account created! Please login", isError: false);

      // Clear signup fields
      signupEmailController.clear();
      signupPasswordController.clear();
      signupConfirmPasswordController.clear();

      // Switch to login tab
      _tabController.animateTo(0);

      // Pre-fill login email
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword && !showPassword,
          keyboardType: isPassword ? TextInputType.text : TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                showPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: onPasswordToggle,
            )
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            label: "Email",
            hint: "Enter your email",
            controller: loginEmailController,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Password",
            hint: "Enter your password",
            controller: loginPasswordController,
            isPassword: true,
            showPassword: _showLoginPassword,
            onPasswordToggle: () {
              setState(() => _showLoginPassword = !_showLoginPassword);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _loginWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB794F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Login with Email",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _loginWithGoogle,
              icon: const Icon(Icons.g_mobiledata_rounded, size: 30),
              label: const Text(
                "Sign in with Google",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
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
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInputField(
            label: "Email",
            hint: "Enter your email",
            controller: signupEmailController,
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Password",
            hint: "At least 6 characters",
            controller: signupPasswordController,
            isPassword: true,
            showPassword: _showSignupPassword,
            onPasswordToggle: () {
              setState(() => _showSignupPassword = !_showSignupPassword);
            },
          ),
          const SizedBox(height: 16),
          _buildInputField(
            label: "Confirm Password",
            hint: "Re-enter password",
            controller: signupConfirmPasswordController,
            isPassword: true,
            showPassword: _showSignupConfirmPassword,
            onPasswordToggle: () {
              setState(() => _showSignupConfirmPassword = !_showSignupConfirmPassword);
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : _signUpWithEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB794F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                foregroundColor: Colors.white,
              ),
              child: isLoading
                  ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
                "Create Account",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Already have an account? Use Login tab",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
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
            colors: [Color(0xFFB794F4), Color(0xFFB794F4)],
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
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 80),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          "Bump Bond",
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Your pregnancy journey companion",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelColor: const Color(0xFFB794F4),
                      unselectedLabelColor: Colors.white,
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      tabs: const [
                        Tab(text: "  Login  "),
                        Tab(text: " Sign Up "),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(top: 16, left: 16, right: 16,bottom: 180),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
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
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
import 'package:bump_bond_flutter_app/screens/baby_name_screen.dart';
import 'package:bump_bond_flutter_app/screens/education_screen.dart';
import 'package:bump_bond_flutter_app/screens/government_policy.dart';
import 'package:bump_bond_flutter_app/screens/journal_screen.dart';
import 'package:bump_bond_flutter_app/auth/milestones.dart';
import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
import 'package:bump_bond_flutter_app/screens/setting_screen_feture.dart';
import 'package:bump_bond_flutter_app/screens/subscription_plan_screen.dart';
import 'package:bump_bond_flutter_app/services/auth_service.dart';
import 'package:bump_bond_flutter_app/models/pregnancy_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String userName = "Mom";
  String userEmail = "";
  String? userPhotoUrl;
  DateTime? lastPeriodDate;
  DateTime? dueDate;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Future<void> _loadUserData() async {
  //   try {
  //     // Load from SharedPreferences
  //     final prefs = await SharedPreferences.getInstance();
  //     final savedName = prefs.getString('userName');
  //
  //     // Load PregnancyData
  //     PregnancyData pregnancyData = await PregnancyData.loadFromPrefs();
  //
  //     setState(() {
  //       userName = savedName ?? _auth.currentUser?.displayName ?? "Mom";
  //       userEmail = _auth.currentUser?.email ?? "";
  //       userPhotoUrl = _auth.currentUser?.photoURL;
  //       lastPeriodDate = pregnancyData.lastPeriodDate;
  //       dueDate = pregnancyData.dueDate;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     print("Error loading user data: $e");
  //     setState(() => isLoading = false);
  //   }
  // }
  Future<void> _loadUserData() async {
    try {
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString('userName');

      // Load PregnancyData
      PregnancyData pregnancyData = await PregnancyData.loadFromPrefs();

      print('SettingsScreen - Loaded pregnancy data:');
      print('Due Date: ${pregnancyData.dueDate}');
      print('Last Period: ${pregnancyData.lastPeriodDate}');
      print('Nickname: ${pregnancyData.babyNickname}');

      setState(() {
        userName = savedName ?? _auth.currentUser?.displayName ?? "Mom";
        userEmail = _auth.currentUser?.email ?? "";
        userPhotoUrl = _auth.currentUser?.photoURL;
        lastPeriodDate = pregnancyData.lastPeriodDate;
        dueDate = pregnancyData.dueDate;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading user data: $e");
      setState(() => isLoading = false);
    }
  }





  void logout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access the app.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: Color(0xFFB794F4)),
                ),
              );

              try {
                final authService = AuthService();
                final error = await authService.logout();
                if (context.mounted) Navigator.pop(context);

                if (error != null) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error), backgroundColor: Colors.red),
                    );
                  }
                } else {
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SplashScreen()),
                          (route) => false,
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) Navigator.pop(context);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditModal(
        userName: userName,
        userEmail: userEmail,
        lastPeriodDate: lastPeriodDate,
        dueDate: dueDate,
        onSave: () {
          _loadUserData();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB794F4)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Profile & Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card
              GestureDetector(
                onTap: _openProfileModal,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFE8D5F2),
                        backgroundImage: userPhotoUrl != null
                            ? NetworkImage(userPhotoUrl!)
                            : null,
                        child: userPhotoUrl == null
                            ? const Icon(Icons.person, size: 40, color: Color(0xFFB794F4))
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (dueDate != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB794F4).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Due: ${DateFormat('MMM dd, yyyy').format(dueDate!)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB794F4),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      Icon(Icons.edit, color: Colors.grey[400], size: 20),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreenFeture(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8D5F2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.settings_outlined,
                            color: Color(0xFFB794F4), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'App preferences and notifications',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
              const Text(
                'Tracking & Logs',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.medication_outlined,
                title: 'Medication Tracker',
                subtitle: 'Log your medications',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MedicationRemindersScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.trending_up_outlined,
                title: 'Mood Symptom Tracker',
                subtitle: 'Monitor pregnancy symptoms',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MoodSymptomTrackerScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.flag_outlined,
                title: 'Milestone Tracker',
                subtitle: 'Track pregnancy milestones',
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => MilestoneScreen()));
                },
              ),
              const SizedBox(height: 32),

              const Text(
                'Pregnancy Resources',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.book_outlined,
                title: 'Educational Resources',
                subtitle: 'Learn about pregnancy',
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => EducationScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.favorite_outline,
                title: 'Love Journal',
                subtitle: 'Write letters to your baby',
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => JournalScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.child_friendly_outlined,
                title: 'Baby Names',
                subtitle: 'Explore baby name ideas',
                onTap: () {
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => BabyNameScreen()));
                },
              ),
              const SizedBox(height: 32),

              const Text(
                'Premium Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.card_giftcard_outlined,
                title: 'Government Policy',
                subtitle: 'Discover premium features',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GovernmentPolicyScreen()));
                },
              ),
              const SizedBox(height: 12),
              _buildMenuCard(
                icon: Icons.receipt_long_outlined,
                title: 'Pricing',
                subtitle: 'View subscription plans',
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SubscriptionPlansScreen()));
                },
              ),
              const SizedBox(height: 32),

              // Logout Button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.1),
                      Colors.red.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => logout(context),
                    borderRadius: BorderRadius.circular(16),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: Colors.red, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Logout',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE8D5F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFFB794F4), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}

// ✅ Profile Edit Modal
class ProfileEditModal extends StatefulWidget {
  final String userName;
  final String userEmail;
  final DateTime? lastPeriodDate;
  final DateTime? dueDate;
  final VoidCallback onSave;

  const ProfileEditModal({
    Key? key,
    required this.userName,
    required this.userEmail,
    this.lastPeriodDate,
    this.dueDate,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ProfileEditModal> createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends State<ProfileEditModal> {
  late TextEditingController nameController;
  DateTime? selectedLastPeriodDate;
  DateTime? calculatedDueDate;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userName);
    selectedLastPeriodDate = widget.lastPeriodDate;
    calculatedDueDate = widget.dueDate;
  }

  Future<void> _saveProfile() async {
    if (nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name')),
      );
      return;
    }

    if (selectedLastPeriodDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select last period date')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', nameController.text);
      await prefs.setString('lastPeriodDate', selectedLastPeriodDate!.toIso8601String());

      // Save to PregnancyData
      PregnancyData pregnancyData = PregnancyData();
      pregnancyData.lastPeriodDate = selectedLastPeriodDate;
      pregnancyData.calculateDueDateFromLMP();
      await pregnancyData.saveToPrefs();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSave();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _calculateDueDate() {
    if (selectedLastPeriodDate != null) {
      setState(() {
        calculatedDueDate = selectedLastPeriodDate!.add(const Duration(days: 280));
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 24, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Name Field
              const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  prefixIcon: const Icon(Icons.person_outline, color: Color(0xFFB794F4)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFB794F4), width: 2),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field (Read-only)
              const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: widget.userEmail),
                enabled: false,
                decoration: InputDecoration(
                  hintText: 'Email',
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Last Period Date
              const Text('Last Period Date',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedLastPeriodDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFFB794F4),
                            onPrimary: Colors.white,
                            onSurface: Color(0xFF1F2937),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      selectedLastPeriodDate = date;
                      _calculateDueDate();
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          color: Color(0xFFB794F4)),
                      const SizedBox(width: 12),
                      Text(
                        selectedLastPeriodDate != null
                            ? DateFormat('MMM dd, yyyy').format(selectedLastPeriodDate!)
                            : 'Select Last Period Date',
                        style: TextStyle(
                          fontSize: 14,
                          color: selectedLastPeriodDate != null
                              ? Colors.black87
                              : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Calculated Due Date (Read-only)
              if (calculatedDueDate != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB794F4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFB794F4).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event, color: Color(0xFFB794F4)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Calculated Due Date',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(calculatedDueDate!),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB794F4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 16),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB794F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
// import 'package:bump_bond_flutter_app/screens/baby_name_screen.dart';
// import 'package:bump_bond_flutter_app/screens/education_screen.dart';
// import 'package:bump_bond_flutter_app/screens/journal_screen.dart';
// import 'package:bump_bond_flutter_app/auth/login_screen.dart';
// import 'package:bump_bond_flutter_app/auth/milestones.dart';
// import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
// import 'package:bump_bond_flutter_app/auth/onboarding_screen.dart';
// import 'package:bump_bond_flutter_app/screens/setting_screen_feture.dart';
// import 'package:bump_bond_flutter_app/auth/splash_screen.dart';
// import 'package:bump_bond_flutter_app/screens/state_benefits_screen.dart';
// import 'package:bump_bond_flutter_app/screens/subscription_plan_screen.dart';
// import 'package:bump_bond_flutter_app/services/auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
//
// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreen> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   Map<String, dynamic>? userDetails;
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchUserDetails();
//   }
//
//   Future<void> fetchUserDetails() async {
//     User? user = _auth.currentUser;
//     if (user != null) {
//       try {
//         DocumentSnapshot snapshot =
//         await _firestore.collection('users').doc(user.uid).get();
//
//         if (snapshot.exists) {
//           setState(() {
//             userDetails = snapshot.data() as Map<String, dynamic>;
//             isLoading = false;
//           });
//         } else {
//           setState(() {
//             isLoading = false;
//           });
//         }
//       } catch (e) {
//         print("Error fetching user details: $e");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//
//
//
//   void logout(BuildContext context) async {
//     // ✅ Show confirmation dialog
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: const Row(
//           children: [
//             Icon(Icons.logout_rounded, color: Colors.red),
//             SizedBox(width: 12),
//             Text('Logout'),
//           ],
//         ),
//         content: const Text(
//           'Are you sure you want to logout? You will need to login again to access the app.',
//           style: TextStyle(fontSize: 15),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey),
//             ),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () async {
//               Navigator.pop(context); // Close dialog
//
//               // Show loading
//               showDialog(
//                 context: context,
//                 barrierDismissible: false,
//                 builder: (context) => const Center(
//                   child: CircularProgressIndicator(color: Color(0xFFB794F4)),
//                 ),
//               );
//
//               try {
//                 // ✅ Logout using AuthService
//                 final authService = AuthService();
//                 final error = await authService.logout();
//
//                 // Close loading dialog
//                 if (context.mounted) Navigator.pop(context);
//
//                 if (error != null) {
//                   // Show error
//                   if (context.mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text(error),
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 } else {
//                   // ✅ Success - Navigate to Splash Screen
//                   // Splash will automatically redirect to Onboarding
//                   if (context.mounted) {
//                     Navigator.pushAndRemoveUntil(
//                       context,
//                       MaterialPageRoute(builder: (context) => const SplashScreen()),
//                           (route) => false, // Remove all previous routes
//                     );
//                   }
//                 }
//               } catch (e) {
//                 // Close loading dialog
//                 if (context.mounted) Navigator.pop(context);
//
//                 // Show error
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(
//                       content: Text('Error: $e'),
//                       backgroundColor: Colors.red,
//                     ),
//                   );
//                 }
//               }
//             },
//             child: const Text(
//               'Logout',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   // void logout(BuildContext context) async {
//   //   await FirebaseAuth.instance.signOut(); // Firebase Logout
//   //
//   //   Navigator.pushAndRemoveUntil(
//   //     context,
//   //     MaterialPageRoute(builder: (context) => OnboardingScreen()), // Replace with your Login Screen class name
//   //         (route) => false, // Removes all previous routes
//   //   );
//   // }
//   void _openProfileModal() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => ProfileEditModal(
//         userDetails: userDetails,
//         onSave: () {
//           fetchUserDetails();
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       appBar: AppBar(
//         title: const Text('Profile & Settings'),
//         backgroundColor: const Color(0xFFB794F4),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: isLoading
//           ? const Center(
//           child: CircularProgressIndicator(color: Color(0xFFB794F4)))
//           : SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Profile & Settings Header
//               const Text(
//                 'Profile & Settings',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 20),
//
//               // Profile Card
//               GestureDetector(
//                 onTap: _openProfileModal,
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       CircleAvatar(
//                         radius: 30,
//                         backgroundColor: const Color(0xFFE8D5F2),
//                         backgroundImage:
//                         userDetails?['photoUrl'] != null
//                             ? NetworkImage(userDetails!['photoUrl'])
//                             : _auth.currentUser?.photoURL != null
//                             ? NetworkImage(
//                             _auth.currentUser!.photoURL!)
//                             : null,
//                         child: userDetails?['photoUrl'] == null &&
//                             _auth.currentUser?.photoURL == null
//                             ? const Icon(Icons.person,
//                             size: 40, color: Color(0xFFB794F4))
//                             : null,
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Profile',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'View and edit your profile',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Icon(Icons.chevron_right,
//                           color: Colors.grey[400], size: 24),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 16),
//
//               // Settings Card
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const SettingsScreenFeture(),
//                     ),
//                   );
//                 },
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.1),
//                         blurRadius: 10,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     children: [
//                       Container(
//                         padding: const EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFFE8D5F2),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: const Icon(Icons.settings_outlined,
//                             color: Color(0xFFB794F4), size: 24),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Settings',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[600],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                             const SizedBox(height: 4),
//                             Text(
//                               'App preferences and notifications',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       Icon(Icons.chevron_right,
//                           color: Colors.grey[400], size: 24),
//                     ],
//                   ),
//                 ),
//               ),
//
//               const SizedBox(height: 32),
//               // Tracking & Logs
//               const Text(
//                 'Tracking & Logs',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.medication_outlined,
//                 title: 'Medication Tracker',
//                 subtitle: 'Log your medications',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MedicationRemindersScreen()));
//                 },
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.trending_up_outlined,
//                 title: 'Mood Symptom Tracker',
//                 subtitle: 'Monitor pregnancy symptoms',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MoodSymptomTrackerScreen()));
//                 },
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.flag_outlined,
//                 title: 'Milestone Tracker',
//                 subtitle: 'Track pregnancy milestones',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => MilestoneScreen()));
//                 },
//               ),
//               const SizedBox(height: 32),
//
//               // Pregnancy Resources
//               const Text(
//                 'Pregnancy Resources',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.book_outlined,
//                 title: 'Educational Resources',
//                 subtitle: 'Learn about pregnancy',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => EducationScreen()));
//                 },
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.favorite_outline,
//                 title: 'Love Journal',
//                 subtitle: 'Write letters to your baby',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => JournalScreen()));
//                 },
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.child_friendly_outlined,
//                 title: 'Baby Names',
//                 subtitle: 'Explore baby name ideas',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => BabyNameScreen()));
//                 },
//               ),
//               const SizedBox(height: 32),
//
//               // Premium Features
//               const Text(
//                 'Premium Features',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.card_giftcard_outlined,
//                 title: 'Government Policy',
//                 subtitle: 'Discover premium features',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) =>StateBenefitsScreen ()));
//                 },
//               ),
//               const SizedBox(height: 12),
//               _buildMenuCard(
//                 icon: Icons.receipt_long_outlined,
//                 title: 'Pricing',
//                 subtitle: 'View subscription plans',
//                 onTap: () {
//                   Navigator.push(context, MaterialPageRoute(builder: (context) => SubscriptionPlansScreen()));
//                 },
//               ),
//               const SizedBox(height: 32),
//
//               // Logout Button
//               Container(
//                 width: double.infinity,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFB794F4),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     onTap: () => logout(context), // ✅ This will trigger logout
//                     borderRadius: BorderRadius.circular(16),
//                     child: const Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.logout_rounded,
//                             color: Colors.red, size: 24),
//                         SizedBox(width: 12),
//                         Text(
//                           'Logout',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildMenuCard({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: const Color(0xFFE8D5F2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Icon(icon, color: const Color(0xFFB794F4), size: 24),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
//         ],
//       ),
//         )
//     );
//   }
// }
//
// // Profile Edit Modal
// class ProfileEditModal extends StatefulWidget {
//   final Map<String, dynamic>? userDetails;
//   final VoidCallback onSave;
//
//   const ProfileEditModal({
//     Key? key,
//     this.userDetails,
//     required this.onSave,
//   }) : super(key: key);
//
//   @override
//   State<ProfileEditModal> createState() => _ProfileEditModalState();
// }
//
// class _ProfileEditModalState extends State<ProfileEditModal> {
//   late TextEditingController nameController;
//   late TextEditingController emailController;
//   DateTime? selectedDueDate;
//   bool isLoading = false;
//
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(
//       text: widget.userDetails?['name'] ?? _auth.currentUser?.displayName ?? '',
//     );
//     emailController = TextEditingController(
//       text: widget.userDetails?['email'] ?? _auth.currentUser?.email ?? '',
//     );
//     if (widget.userDetails?['dueDate'] != null) {
//       var dueDateValue = widget.userDetails!['dueDate'];
//       if (dueDateValue is Timestamp) {
//         selectedDueDate = dueDateValue.toDate();
//       }
//     }
//   }
//
//   Future<void> _savProfile() async {
//     if (nameController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter your name')),
//       );
//       return;
//     }
//
//     setState(() => isLoading = true);
//
//     try {
//       User? user = _auth.currentUser;
//       if (user != null) {
//         await _firestore.collection('users').doc(user.uid).update({
//           'name': nameController.text,
//           'email': emailController.text,
//           'dueDate': selectedDueDate,
//         });
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully!')),
//         );
//         widget.onSave();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     nameController.dispose();
//     emailController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(20, 24, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Edit Profile',
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               const Text('Name', style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: nameController,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your name',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text('Email', style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               TextField(
//                 controller: emailController,
//                 enabled: false,
//                 decoration: InputDecoration(
//                   hintText: 'Email',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Text('Due Date', style: TextStyle(fontWeight: FontWeight.w600)),
//               const SizedBox(height: 8),
//               GestureDetector(
//                 onTap: () async {
//                   final date = await showDatePicker(
//                     context: context,
//                     initialDate: selectedDueDate ?? DateTime.now(),
//                     firstDate: DateTime.now(),
//                     lastDate: DateTime.now().add(const Duration(days: 365)),
//                   );
//                   if (date != null) {
//                     setState(() => selectedDueDate = date);
//                   }
//                 },
//                 child: Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                   decoration: BoxDecoration(
//                     border: Border.all(color: Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(Icons.calendar_today_outlined,
//                           color: Color(0xFFB794F4)),
//                       const SizedBox(width: 12),
//                       Text(
//                         selectedDueDate != null
//                             ? '${selectedDueDate!.day}-${selectedDueDate!.month}-${selectedDueDate!.year}'
//                             : 'Select Due Date',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: isLoading ? null : _savProfile,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB794F4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: isLoading
//                       ? const SizedBox(
//                     height: 20,
//                     width: 20,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                       : const Text(
//                     'Save Changes',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
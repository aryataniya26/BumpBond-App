import 'package:bump_bond_flutter_app/auth/MedicationRemindersScreen.dart';
import 'package:bump_bond_flutter_app/auth/notification_screen.dart';
import 'package:bump_bond_flutter_app/screens/baby_name_screen.dart';
import 'package:bump_bond_flutter_app/screens/book_consultation_screen.dart';
import 'package:bump_bond_flutter_app/screens/buddy_connect_screen.dart';
import 'package:bump_bond_flutter_app/screens/chat_screen.dart';
import 'package:bump_bond_flutter_app/screens/consultation_history_screen.dart';
import 'package:bump_bond_flutter_app/screens/education_screen.dart';
import 'package:bump_bond_flutter_app/screens/journal_screen.dart';
import 'package:bump_bond_flutter_app/auth/milestones.dart';
import 'package:bump_bond_flutter_app/models/pregnancy_data.dart';
import 'package:bump_bond_flutter_app/auth/moodsymptomtrackerscreen.dart';
import 'package:bump_bond_flutter_app/auth/setting_screen.dart';
import 'package:bump_bond_flutter_app/screens/meal_plan_screen.dart';
import 'package:bump_bond_flutter_app/screens/subscription_plan_screen.dart';
import 'package:bump_bond_flutter_app/screens/webinar_screen.dart';
import 'package:bump_bond_flutter_app/screens/week_development_screen.dart';
import 'package:bump_bond_flutter_app/screens/weekly_quiz_screen.dart';
import 'package:bump_bond_flutter_app/services/subscription_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bump_bond_flutter_app/services/ads_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  Widget? _bannerAd;

  String userName = "Mom";
  int currentWeek = 0;
  int currentDay = 0;
  int daysToGo = 0;
  double progressPercentage = 0.0;
  String babySize = "Poppy Seed";
  String babyName = "Baby";
  String babyEmoji = "🌱";
  String dueDate = "";
  String currentMonth = "1st month";
  String trimester = "First Trimester";
  String stageDescription = "";

  PregnancyData? pregnancyData;
  bool _isExpanded = false;
  bool _isLoading = true;
  String _currentPlan = 'free';
  int _featureClickCounter = 0;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    _loadPregnancyData();
    _loadCurrentPlan();

    // Initialize ads when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdsService.initialize();
    });
  }

  Future<void> _loadBannerAd() async {
    final ad = await AdsService.getBannerAd();
    if (mounted) {
      setState(() {
        _bannerAd = ad;
      });
    }
  }

  void _loadPregnancyData() async {
    PregnancyData data = await PregnancyData.loadFromPrefs();

    if (data.lastPeriodDate != null) {
      data.calculateDueDateFromLMP();

      setState(() {
        pregnancyData = data;
        userName = "Mom";
        currentWeek = data.currentWeekNumber;
        currentDay = data.currentDayNumber;
        daysToGo = data.daysRemaining;
        progressPercentage = data.progress;
        babySize = data.babySize;
        babyName = data.babyNickname ?? "Baby";
        babyEmoji = data.babyEmoji;
        currentMonth = data.currentMonth;
        trimester = data.trimester;
        stageDescription = data.stageDescription;
        dueDate = data.dueDate != null
            ? DateFormat('MMM dd, yyyy').format(data.dueDate!)
            : "";
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _loadCurrentPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    setState(() {
      _currentPlan = plan;
    });
  }

  bool _hasFeatureAccess(String requiredPlan) {
    return SubscriptionService.hasAccess(_currentPlan, requiredPlan);
  }

  void _showUpgradeDialog(String featureName, String requiredPlan) {
    String planName = requiredPlan == 'basic'
        ? 'Basic (Ad-Free)'
        : requiredPlan == 'premium'
        ? 'Premium'
        : 'Pro';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            const Text('👑', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Upgrade Required',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unlock "$featureName" with $planName Plan',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (requiredPlan == 'basic') ...[
                    _buildBenefitRow('No advertisements'),
                    _buildBenefitRow('Ad-free experience'),
                  ],
                  if (requiredPlan == 'premium') ...[
                    _buildBenefitRow('Unlimited AI baby chat'),
                    _buildBenefitRow('Weekly recorded videos'),
                    _buildBenefitRow('Voice/Photos in journal'),
                    _buildBenefitRow('Custom meal plans'),
                    _buildBenefitRow('Buddy Connect'),
                    _buildBenefitRow('Book Consultation'),
                  ],
                  if (requiredPlan == 'pro') ...[
                    _buildBenefitRow('Lifetime access'),
                    _buildBenefitRow('Monthly webinars'),
                    _buildBenefitRow('Partner sharing'),
                    _buildBenefitRow('1-year support'),
                    _buildBenefitRow('Buddy Connect'),
                    _buildBenefitRow('Book Consultation'),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPlansScreen(),
                ),
              ).then((_) => _loadCurrentPlan());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD4B5E8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'View Plans',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: Color(0xFFD4B5E8),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
  // Updated method to handle feature access with interstitial ads
  Future<void> _handleFeatureAccessWithAd(
      String requiredPlan,
      VoidCallback onAccess,
      String featureName,
      String screenName,
      ) async {
    if (_hasFeatureAccess(requiredPlan)) {
      // Increment counter for ad frequency
      _featureClickCounter++;

      // Show interstitial ad every 3rd feature click for free users
      if (_currentPlan == 'free' && _featureClickCounter % 3 == 0) {
        await AdsService.showInterstitialAd(screenName: screenName);
        await Future.delayed(const Duration(milliseconds: 500));
      }

      onAccess();
    } else {
      _showUpgradeDialog(featureName, requiredPlan);
    }
  }

  // Navigate to screen with interstitial ad
  Future<void> _navigateWithAd({
    required Widget screen,
    required String screenName,
    bool showAd = true,
  }) async {
    // Show ad for free users
    if (_currentPlan == 'free' && showAd) {
      await AdsService.showInterstitialAd(screenName: screenName);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFB794F4)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE6E6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreeting(),
              const SizedBox(height: 16),
              _buildCurrentPlanBanner(),
              const SizedBox(height: 24),
              _buildWeekCard(),
              const SizedBox(height: 28),
              _buildPremiumAIFeatures(),
              const SizedBox(height: 20),
              _buildQuickActions(),
              const SizedBox(height: 20),
              _buildLearningDevelopment(),
              const SizedBox(height: 20),
              _buildConsultationsAndCare(),
              const SizedBox(height: 20),
              _buildAllFeaturesMenu(context),
              const SizedBox(height: 20),

              // Banner Ad Section
              if (_currentPlan == 'free') _buildAdSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdSection() {
    return FutureBuilder<Widget>(
      future: AdsService.getBannerAd(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 60,
            color: Colors.grey[200],
            child: const Center(
              child: Text(
                'Loading advertisement...',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            height: 60,
            color: Colors.red[100],
            child: Center(
              child: Text(
                'Ad temporarily unavailable',
                style: TextStyle(color: Colors.red[800], fontSize: 12),
              ),
            ),
          );
        }

        return snapshot.data ?? const SizedBox(height: 0);
      },
    );
  }

  Widget _buildCurrentPlanBanner() {
    Map<String, dynamic> planInfo = {
      'free': {
        'name': 'Free',
        'color': Colors.orange,
        'icon': Icons.free_breakfast,
        'tag': 'WITH ADS',
      },
      'basic': {
        'name': 'Basic',
        'color': Colors.blue,
        'icon': Icons.ads_click,
        'tag': 'AD-FREE',
      },
      'premium': {
        'name': 'Premium',
        'color': const Color(0xFFD4B5E8),
        'icon': Icons.favorite,
        'tag': 'PREMIUM',
      },
      'pro': {
        'name': 'Pro',
        'color': const Color(0xFFFFB800),
        'icon': Icons.emoji_events,
        'tag': 'LIFETIME',
      },
    };

    final currentPlanInfo = planInfo[_currentPlan] ?? planInfo['free'];

    return GestureDetector(
      onTap: () {
        _navigateWithAd(
          screen: const SubscriptionPlansScreen(),
          screenName: 'Subscription Plans',
          showAd: _currentPlan == 'free', // Only show ad for free users
        ).then((_) => _loadCurrentPlan());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              currentPlanInfo['color'].withOpacity(0.15),
              currentPlanInfo['color'].withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: currentPlanInfo['color'].withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: currentPlanInfo['color'].withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                currentPlanInfo['icon'],
                color: currentPlanInfo['color'],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Current Plan: ${currentPlanInfo['name']}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: currentPlanInfo['color'],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: currentPlanInfo['color'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          currentPlanInfo['tag'],
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentPlan == 'pro'
                        ? 'Lifetime Access • All Features Unlocked'
                        : 'Tap to upgrade and unlock more features',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (_currentPlan != 'pro')
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '👑',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_forward_ios,
              color: currentPlanInfo['color'],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    String greeting = "Good afternoon";
    final hour = DateTime.now().hour;
    if (hour < 12) greeting = "Good morning";
    else if (hour >= 18) greeting = "Good evening";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '$greeting, $userName!',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('👋', style: TextStyle(fontSize: 24)),
              ],
            ),
            GestureDetector(
              onTap: () {
                _navigateWithAd(
                  screen: NotificationScreen(),
                  screenName: 'Notifications',
                );
              },
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 1,
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Color(0xFFB794F4),
                  size: 26,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'You\'re $currentWeek weeks pregnant • $daysToGo days to go',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Week ',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '$currentWeek',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCE7F3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Day $currentDay',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFEC4899),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                        trimester,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB794F4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Due: $dueDate',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$daysToGo days to go',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEC4899),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 180,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFCE7F3),
                      const Color(0xFFB794F4).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      babyEmoji,
                      style: const TextStyle(fontSize: 50),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      babyName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB794F4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Size of a',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      babySize,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFEC4899),
              ),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercentage * 100).toStringAsFixed(1)}% completed',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                currentMonth,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumAIFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Text('👑', style: TextStyle(fontSize: 20)),
            SizedBox(width: 8),
            Text(
              'Premium AI Features',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          icon: Icons.chat_bubble_rounded,
          title: 'Chat with $babyName',
          subtitle: _hasFeatureAccess('premium')
              ? 'Unlimited AI-powered conversations'
              : '5 chats/day • Upgrade for unlimited',
          color: const Color(0xFF8B5CF6),
          isLocked: !_hasFeatureAccess('premium'),
          onTap: () => _handleFeatureAccessWithAd(
            'free',
                () => _navigateWithAd(
              screen: ChatScreen(babyName: babyName),
              screenName: 'AI Baby Chat',
            ),
            'Unlimited AI Baby Chat',
            'AI Baby Chat Screen',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallPremiumCard(
                icon: Icons.quiz_rounded,
                title: 'Weekly Quiz',
                subtitle: 'Test your knowledge',
                color: const Color(0xFF6366F1),
                isLocked: false,
                onTap: () {
                  _navigateWithAd(
                    screen: WeeklyQuizJourneyScreen(),
                    screenName: 'Weekly Quiz',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallCard(
                icon: Icons.child_care_rounded,
                title: 'Baby Names',
                subtitle: 'Find perfect name',
                color: Colors.lightBlue,
                onTap: () {
                  _navigateWithAd(
                    screen: const BabyNameScreen(),
                    screenName: 'Baby Names',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLocked) ...[
                const Icon(Icons.lock, color: Colors.grey, size: 20),
                const SizedBox(width: 8),
              ] else ...[
                const Text('👑', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
              ],
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmallPremiumCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 28),
                  if (isLocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.add_circle_outline, size: 20),
            SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: Icons.favorite_rounded,
                title: 'Mood & Symptom',
                subtitle: 'Track daily mood',
                color: const Color(0xFFF3E5F5),
                iconColor: const Color(0xFF9C27B0),
                onTap: () {
                  _navigateWithAd(
                    screen: const MoodSymptomTrackerScreen(),
                    screenName: 'Mood & Symptom Tracker',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                icon: Icons.medication_rounded,
                title: 'Medication',
                subtitle: 'Log medication',
                color: const Color(0xFFE8F5E9),
                iconColor: const Color(0xFF4CAF50),
                onTap: () {
                  _navigateWithAd(
                    screen: const MedicationRemindersScreen(),
                    screenName: 'Medication Reminders',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: iconColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLearningDevelopment() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: const [
                Icon(Icons.school_rounded, size: 20),
                SizedBox(width: 8),
                Text(
                  'Learning & Development',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          icon: Icons.videocam_rounded,
          title: 'Weekly Webinar',
          subtitle: _hasFeatureAccess('premium')
              ? 'Expert-led sessions'
              : 'Unlock with Premium',
          color: const Color(0xFFFCD34D),
          isLocked: !_hasFeatureAccess('premium'),
          onTap: () {
            _handleFeatureAccessWithAd(
              'premium',
                  () => _navigateWithAd(
                screen: WebinarScreen(),
                screenName: 'Weekly Webinar',
              ),
              'Weekly Webinar',
              'Webinar Screen',
            );
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSmallCard(
                icon: Icons.calendar_today_rounded,
                title: 'Week Development',
                subtitle: "What's happening",
                color: const Color(0xFF2196F3),
                onTap: () {
                  _navigateWithAd(
                    screen: PregnancyJourneyScreen(),
                    screenName: 'Week Development',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallCard(
                icon: Icons.book_rounded,
                title: 'Resources',
                subtitle: 'Expert guidance',
                color: const Color(0xFF10B981),
                onTap: () {
                  _navigateWithAd(
                    screen: ResourceLibraryScreen(),
                    screenName: 'Resources',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildLockedSmallCard(
                icon: Icons.people_rounded,
                title: 'Buddy Connect',
                subtitle: _hasFeatureAccess('premium')
                    ? 'Expert support'
                    : 'Unlock with Premium',
                color: const Color(0xFF6A0DAD),
                // isLocked: !_hasFeatureAccess('premium'),
                onTap: () {
                  _handleFeatureAccessWithAd(
                    'premium',
                        () => _navigateWithAd(
                      screen: BuddyConnectHome(),
                      screenName: 'Buddy Connect',
                    ),
                    'Buddy Connect',
                    'Buddy Connect Screen',
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSmallCard(
                icon: Icons.flag_rounded,
                title: 'Milestones',
                subtitle: 'Track progress',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  _navigateWithAd(
                    screen: const MilestoneScreen(),
                    screenName: 'Milestones',
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildMealPlanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.restaurant_menu, size: 20),
            SizedBox(width: 8),
            Text(
              'Nutrition & Wellness',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPremiumCard(
          icon: Icons.restaurant_menu_rounded,
          title: 'Custom Meal Plan',
          subtitle: _hasFeatureAccess('premium')
              ? 'Week-specific nutrition guide'
              : 'Unlock with Premium',
          color: const Color(0xFFFF6B6B),
          isLocked: !_hasFeatureAccess('premium'),
          onTap: () {
            _handleFeatureAccessWithAd(
              'premium',
                  () => _navigateWithAd(
                screen: const MealPlanScreen(),
                screenName: 'Custom Meal Plan',
              ),
              'Custom Meal Plan',
              'Meal Plan Screen',
            );
          },
        ),
      ],
    );
  }
  Widget _buildLockedSmallCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isLocked = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isLocked ? Colors.grey.withOpacity(0.3) : color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    icon,
                    color: isLocked ? Colors.grey : color,
                    size: 28,
                  ),
                  if (isLocked)
                    const Icon(Icons.lock, color: Colors.grey, size: 18),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? Colors.grey : color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isLocked ? Colors.grey : color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsultationsAndCare() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.calendar_month_rounded, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Consultations & Care',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLockedSmallCard(
                  icon: Icons.calendar_month,
                  title: 'Book Consultation',
                  subtitle: _hasFeatureAccess('premium')
                      ? 'Doctor appointment'
                      : 'Unlock with Premium',
                  color: Colors.orange,
                  // isLocked: !_hasFeatureAccess('premium'),
                  onTap: () {
                    _handleFeatureAccessWithAd(
                      'premium',
                          () => _navigateWithAd(
                        screen: BookConsultationScreen(),
                        screenName: 'Book Consultation',
                      ),
                      'Book Consultation',
                      'Book Consultation Screen',
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallCard(
                  icon: Icons.notes,
                  title: 'Love Journal',
                  subtitle: _hasFeatureAccess('premium')
                      ? 'Voice/Photos/Videos'
                      : 'Text only',
                  color: Colors.pink,
                  onTap: () {
                    _navigateWithAd(
                      screen: JournalScreen(),
                      screenName: 'Love Journal',
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildLockedSmallCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Custom Meal Plan',
                  subtitle: _hasFeatureAccess('premium')
                      ? 'Personalized nutrition for your week'
                      : 'Premium Week-specific meal planning',
                  color: Colors.indigo,
                  // isLocked: !_hasFeatureAccess('premium'),
                  onTap: () => _handleFeatureAccessWithAd(
                    'premium',
                        () => _navigateWithAd(
                      screen: const MealPlanScreen(),
                      screenName: 'Custom Meal Plan',
                    ),
                    'Custom Meal Plan',
                    'Meal Plan Screen',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSmallCard(
                  icon: Icons.history,
                  title: 'Consultation History',
                  subtitle: 'Past appointments',
                  color: Colors.brown,
                  onTap: () {
                    _navigateWithAd(
                      screen: ConsultationHistoryScreen(),
                      screenName: 'Consultation History',
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAllFeaturesMenu(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _navigateWithAd(
            screen: SettingsScreen(),
            screenName: 'All Features Menu',
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.menu_rounded, size: 20),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Features Menu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Complete feature list',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    AdsService.dispose();
    super.dispose();
  }
}

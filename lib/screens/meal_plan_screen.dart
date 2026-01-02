import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/subscription_service.dart';
import '../screens/subscription_plan_screen.dart';

class MealPlanScreen extends StatefulWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<MealPlan> _mealPlans = [];
  String _currentPlan = 'free';
  int _currentWeek = 1;
  bool _isLoading = true;

  // Lavender color palette
  static const Color primaryLavender = Color(0xFF7C3AED);
  static const Color lightLavender = Color(0xFFF3E8FF);
  static const Color darkLavender = Color(0xFF6D28D9);
  static const Color accentLavender = Color(0xFFA78BFA);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadUserPlan();
    _loadMealPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    setState(() {
      _currentPlan = plan;
    });
  }

  Future<void> _loadMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = prefs.getString('meal_plans');

    if (plansJson != null) {
      try {
        final List<dynamic> decoded = json.decode(plansJson);
        setState(() {
          _mealPlans = decoded.map((e) => MealPlan.fromJson(e as Map<String, dynamic>)).toList();
          _isLoading = false;
        });
      } catch (e) {
        print('Error loading meal plans: $e');
        _generateDefaultMealPlans();
      }
    } else {
      _generateDefaultMealPlans();
    }
  }

  void _generateDefaultMealPlans() {
    // Generate week-specific meal plans
    _mealPlans = List.generate(7, (dayIndex) {
      return MealPlan(
        id: DateTime.now().millisecondsSinceEpoch.toString() + dayIndex.toString(),
        day: _getDayName(dayIndex),
        week: _currentWeek,
        breakfast: _getBreakfastForDay(dayIndex),
        midMorningSnack: _getMidMorningSnack(dayIndex),
        lunch: _getLunchForDay(dayIndex),
        eveningSnack: _getEveningSnack(dayIndex),
        dinner: _getDinnerForDay(dayIndex),
        bedtimeSnack: _getBedtimeSnack(dayIndex),
        waterIntake: '8-10 glasses',
        nutritionTips: _getNutritionTips(dayIndex),
      );
    });

    _saveMealPlans();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveMealPlans() async {
    final prefs = await SharedPreferences.getInstance();
    final plansJson = json.encode(_mealPlans.map((e) => e.toJson()).toList());
    await prefs.setString('meal_plans', plansJson);
  }

  String _getDayName(int index) {
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[index];
  }

  // Sample meal data generators
  String _getBreakfastForDay(int day) {
    final breakfasts = [
      'Oatmeal with berries and almonds\n• 1 cup cooked oatmeal\n• 1/2 cup mixed berries\n• 1 tbsp almonds\n• 1 glass milk',
      'Whole grain toast with avocado\n• 2 slices whole grain bread\n• 1/2 avocado\n• 1 boiled egg\n• Fresh orange juice',
      'Greek yogurt parfait\n• 1 cup Greek yogurt\n• Granola\n• Honey\n• Mixed fruits',
      'Vegetable poha\n• 1 cup poha\n• Mixed vegetables\n• Peanuts\n• Lemon',
      'Idli with sambar\n• 3-4 idlis\n• 1 bowl sambar\n• Coconut chutney',
      'Banana pancakes\n• 2 whole grain pancakes\n• 1 banana\n• Maple syrup\n• Nuts',
      'Upma with vegetables\n• 1 bowl upma\n• Mixed veggies\n• Chutney',
    ];
    return breakfasts[day];
  }

  String _getMidMorningSnack(int day) {
    final snacks = [
      '1 apple with peanut butter',
      'Handful of mixed nuts',
      'Fresh fruit smoothie',
      'Carrot sticks with hummus',
      '1 banana with dates',
      'Greek yogurt with honey',
      'Whole grain crackers with cheese',
    ];
    return snacks[day];
  }

  String _getLunchForDay(int day) {
    final lunches = [
      'Brown rice with dal and vegetables\n• 1 cup brown rice\n• 1 bowl dal\n• Mixed vegetable curry\n• Salad',
      'Quinoa salad with grilled chicken\n• 1 cup quinoa\n• Grilled chicken breast\n• Mixed greens\n• Olive oil dressing',
      'Whole wheat roti with paneer\n• 3 rotis\n• Paneer curry\n• Curd\n• Salad',
      'Vegetable pulao with raita\n• 1 bowl pulao\n• Raita\n• Papad',
      'Grilled fish with steamed vegetables\n• 1 piece fish\n• Steamed broccoli\n• Sweet potato',
      'Rajma chawal\n• 1 cup rice\n• Rajma curry\n• Salad',
      'Pasta with vegetables\n• Whole wheat pasta\n• Mixed vegetables\n• Tomato sauce',
    ];
    return lunches[day];
  }

  String _getEveningSnack(int day) {
    final snacks = [
      'Green tea with whole grain biscuits',
      'Fresh fruit chaat',
      'Roasted chickpeas',
      'Vegetable sandwich',
      'Smoothie bowl',
      'Sprouts salad',
      'Corn chaat',
    ];
    return snacks[day];
  }

  String _getDinnerForDay(int day) {
    final dinners = [
      'Vegetable soup with whole grain bread\n• 1 bowl soup\n• 2 slices bread\n• Side salad',
      'Grilled chicken with quinoa\n• Chicken breast\n• 1 cup quinoa\n• Steamed vegetables',
      'Dal khichdi with curd\n• 1 bowl khichdi\n• Curd\n• Papad',
      'Vegetable stir-fry with brown rice\n• Mixed vegetables\n• 1 cup brown rice',
      'Palak paneer with roti\n• Palak paneer\n• 2 rotis\n• Salad',
      'Baked salmon with vegetables\n• Salmon fillet\n• Roasted vegetables\n• Quinoa',
      'Vegetable pulao with raita\n• 1 bowl pulao\n• Raita\n• Salad',
    ];
    return dinners[day];
  }

  String _getBedtimeSnack(int day) {
    final snacks = [
      'Warm milk with turmeric',
      'Handful of almonds',
      'Banana with milk',
      'Date and nut ladoo',
      'Chamomile tea',
      'Warm milk with honey',
      'Fresh fruit',
    ];
    return snacks[day];
  }

  String _getNutritionTips(int day) {
    final tips = [
      '💡 Focus on iron-rich foods like spinach and legumes',
      '💡 Include calcium sources - milk, yogurt, and cheese',
      '💡 Stay hydrated throughout the day',
      '💡 Add folic acid-rich foods like leafy greens',
      '💡 Include protein in every meal',
      '💡 Eat omega-3 rich foods like walnuts and flaxseeds',
      '💡 Have small, frequent meals to prevent nausea',
    ];
    return tips[day];
  }

  bool _hasAccess(String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(_currentPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);
    return userIndex >= requiredIndex;
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.restaurant_menu, color: primaryLavender, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Unlock Custom Meal Plans',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Get personalized nutrition guidance tailored to your pregnancy week',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: lightLavender,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildBenefitRow('Week-specific meal plans'),
                    _buildBenefitRow('Nutritionist-approved recipes'),
                    _buildBenefitRow('Pregnancy-safe food guide'),
                    _buildBenefitRow('Custom dietary preferences'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionPlansScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryLavender,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 20, color: primaryLavender),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        body: Center(
          child: CircularProgressIndicator(color: primaryLavender),
        ),
      );
    }

    // Show upgrade prompt for free users
    if (!_hasAccess('premium')) {
      return Scaffold(
        backgroundColor: const Color(0xFFFAF5FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1F2937)),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primaryLavender, accentLavender],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Custom Meal Plans',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Unlock personalized nutrition guidance',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      children: [
                        _buildBenefitRow('Week-specific meal plans'),
                        _buildBenefitRow('Nutritionist-approved recipes'),
                        _buildBenefitRow('Pregnancy-safe food guide'),
                        _buildBenefitRow('Custom dietary preferences'),
                        _buildBenefitRow('Daily nutrition tracking'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SubscriptionPlansScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryLavender,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF5FF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryLavender, accentLavender],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Custom Meal Plan',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Nutrition for your pregnancy journey',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Week $_currentWeek',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Week Selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(Icons.local_fire_department, '1800', 'Daily Cal'),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(Icons.restaurant, '5-6', 'Meals'),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(Icons.water_drop, '8-10', 'Glasses'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Day Tabs
            Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: primaryLavender,
                labelColor: primaryLavender,
                unselectedLabelColor: Colors.grey,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                tabs: _mealPlans.map((plan) => Tab(text: plan.day)).toList(),
              ),
            ),

            // Meal Plan Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _mealPlans.map((plan) => _buildMealPlanView(plan)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMealPlanView(MealPlan plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMealCard('Breakfast', Icons.wb_sunny, plan.breakfast, Colors.orange),
          const SizedBox(height: 16),
          _buildMealCard('Mid-Morning Snack', Icons.cookie, plan.midMorningSnack, Colors.amber),
          const SizedBox(height: 16),
          _buildMealCard('Lunch', Icons.lunch_dining, plan.lunch, Colors.green),
          const SizedBox(height: 16),
          _buildMealCard('Evening Snack', Icons.coffee, plan.eveningSnack, Colors.brown),
          const SizedBox(height: 16),
          _buildMealCard('Dinner', Icons.dinner_dining, plan.dinner, Colors.deepPurple),
          const SizedBox(height: 16),
          _buildMealCard('Bedtime Snack', Icons.nightlight, plan.bedtimeSnack, Colors.indigo),
          const SizedBox(height: 20),

          // Nutrition Tips
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [lightLavender, lightLavender.withOpacity(0.5)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: accentLavender),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, color: primaryLavender),
                    const SizedBox(width: 8),
                    const Text(
                      'Today\'s Nutrition Tip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  plan.nutritionTips,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1F2937),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Water Intake Reminder
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: Colors.blue, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stay Hydrated',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        plan.waterIntake,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String title, IconData icon, String content, Color color) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Meal Plan Model
class MealPlan {
  final String id;
  final String day;
  final int week;
  final String breakfast;
  final String midMorningSnack;
  final String lunch;
  final String eveningSnack;
  final String dinner;
  final String bedtimeSnack;
  final String waterIntake;
  final String nutritionTips;

  MealPlan({
    required this.id,
    required this.day,
    required this.week,
    required this.breakfast,
    required this.midMorningSnack,
    required this.lunch,
    required this.eveningSnack,
    required this.dinner,
    required this.bedtimeSnack,
    required this.waterIntake,
    required this.nutritionTips,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'day': day,
    'week': week,
    'breakfast': breakfast,
    'midMorningSnack': midMorningSnack,
    'lunch': lunch,
    'eveningSnack': eveningSnack,
    'dinner': dinner,
    'bedtimeSnack': bedtimeSnack,
    'waterIntake': waterIntake,
    'nutritionTips': nutritionTips,
  };

  factory MealPlan.fromJson(Map<String, dynamic> json) => MealPlan(
    id: json['id'] as String,
    day: json['day'] as String,
    week: json['week'] as int,
    breakfast: json['breakfast'] as String,
    midMorningSnack: json['midMorningSnack'] as String,
    lunch: json['lunch'] as String,
    eveningSnack: json['eveningSnack'] as String,
    dinner: json['dinner'] as String,
    bedtimeSnack: json['bedtimeSnack'] as String,
    waterIntake: json['waterIntake'] as String,
    nutritionTips: json['nutritionTips'] as String,
  );
}
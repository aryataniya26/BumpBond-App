import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String _currentPlanKey = 'user_current_plan';

  //Save User current plan
  static Future<void> setCurrentPlan(String planKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentPlanKey, planKey);
    print('Plan saved: $planKey');
  }

  // Get User current plan
  static Future<String> getCurrentPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentPlanKey) ?? 'free'; // default free plan
  }

  // Check if user has access to feature
  static bool hasAccess(String userPlan, String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(userPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);

    return userIndex >= requiredIndex;
  }
}
import 'package:flutter/material.dart';
import 'subscription_service.dart';

class SubscriptionAccessService {
  // Plan hierarchy: free < basic < premium < pro
  static const Map<String, int> planHierarchy = {
    'free': 0,
    'basic': 1,
    'premium': 2,
    'pro': 3,
  };

  // Feature access requirements - Updated according to your plans
  static const Map<String, String> featureAccess = {
    // Free features (available to all)
    'pregnancy_tracker': 'free',
    'weekly_updates': 'free',
    'milestone_tracking': 'free',
    'education_resources': 'free',
    'symptoms_log': 'free',
    'mood_tracker': 'free',
    'medication_reminders': 'free',
    'basic_journal': 'free',
    'baby_names': 'free',
    'weekly_quiz': 'free',
    'week_development': 'free',
    'milestones': 'free',

    // Basic plan features (ad-free)
    'ad_free': 'basic',

    // Premium features
    'ai_baby_chat_unlimited': 'premium',
    'weekly_videos': 'premium',
    'personalized_recommendations': 'premium',
    'voice_photo_journal': 'premium',
    'custom_meal_plan': 'premium',
    'priority_support': 'premium',
    'webinars': 'premium',
    'buddy_connect': 'premium',
    'consultation_booking': 'premium',

    // Pro features
    'lifetime_access': 'pro',
    'journey_video': 'pro',
    'monthly_webinar': 'pro',
    'partner_sharing': 'pro',
    'postpartum_support': 'pro',
    'lactation_support': 'pro',
    'pediatrician_support': 'pro',
  };

  // Check if user has access to a feature
  static Future<bool> hasAccess(String featureName) async {
    final currentPlan = await SubscriptionService.getCurrentPlan();
    final requiredPlan = featureAccess[featureName] ?? 'premium';

    return _comparePlans(currentPlan, requiredPlan);
  }

  // NEW: Check access with current plan (for home screen)
  static bool hasAccessToFeature(String featureName, String currentUserPlan) {
    final requiredPlan = featureAccess[featureName] ?? 'premium';
    return _comparePlans(currentUserPlan, requiredPlan);
  }

  // Check if user's plan is >= required plan
  static bool _comparePlans(String userPlan, String requiredPlan) {
    final userLevel = planHierarchy[userPlan] ?? 0;
    final requiredLevel = planHierarchy[requiredPlan] ?? 0;
    return userLevel >= requiredLevel;
  }

  // Get plan color
  static Color getPlanColor(String plan) {
    switch (plan) {
      case 'free':
        return Colors.orange;
      case 'basic':
        return Colors.blue;
      case 'premium':
        return const Color(0xFFD4B5E8);
      case 'pro':
        return const Color(0xFFFFB800);
      default:
        return Colors.grey;
    }
  }

  // Get plan name
  static String getPlanDisplayName(String plan) {
    switch (plan) {
      case 'free':
        return 'Free Plan';
      case 'basic':
        return 'Basic (Ad-Free)';
      case 'premium':
        return 'Premium';
      case 'pro':
        return 'Pro (Lifetime)';
      default:
        return 'Unknown Plan';
    }
  }

  // Show upgrade dialog
  static void showUpgradeDialog(
      BuildContext context, {
        required String featureName,
        required String requiredPlan,
      }) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                getPlanColor(requiredPlan).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock icon with glow effect
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: getPlanColor(requiredPlan).withOpacity(0.1),
                  boxShadow: [
                    BoxShadow(
                      color: getPlanColor(requiredPlan).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 48,
                  color: getPlanColor(requiredPlan),
                ),
              ),
              const SizedBox(height: 20),

              // Premium badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      getPlanColor(requiredPlan),
                      getPlanColor(requiredPlan).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      getPlanDisplayName(requiredPlan).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Unlock $featureName',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Upgrade to ${getPlanDisplayName(requiredPlan)} to access this premium feature and many more!',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Benefits based on plan
              if (requiredPlan == 'premium') ...[
                _buildBenefitRow('Unlimited AI Baby Chat', requiredPlan),
                _buildBenefitRow('Weekly Recorded Videos', requiredPlan),
                _buildBenefitRow('Custom Meal Plans', requiredPlan),
                _buildBenefitRow('Voice/Photo Journal', requiredPlan),
              ] else if (requiredPlan == 'pro') ...[
                _buildBenefitRow('Lifetime Access', requiredPlan),
                _buildBenefitRow('Partner Sharing', requiredPlan),
                _buildBenefitRow('1-Year Professional Support', requiredPlan),
                _buildBenefitRow('Monthly Webinars', requiredPlan),
              ] else if (requiredPlan == 'basic') ...[
                _buildBenefitRow('Ad-Free Experience', requiredPlan),
                _buildBenefitRow('No Interruptions', requiredPlan),
                _buildBenefitRow('Clean Interface', requiredPlan),
              ],

              const SizedBox(height: 24),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Maybe Later',
                        style: TextStyle(
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to subscription screen
                        Navigator.pushNamed(context, '/subscription');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getPlanColor(requiredPlan),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch, size: 18, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  static Widget _buildBenefitRow(String text, String plan) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: getPlanColor(plan),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build locked feature widget
  static Widget buildLockedFeature({
    required String featureName,
    required String requiredPlan,
    String? description,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: getPlanColor(requiredPlan).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lock icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: getPlanColor(requiredPlan).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_rounded,
              size: 40,
              color: getPlanColor(requiredPlan),
            ),
          ),
          const SizedBox(height: 16),

          // Feature name
          Text(
            featureName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),

          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 16),

          // Plan badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getPlanColor(requiredPlan).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  size: 14,
                  color: getPlanColor(requiredPlan),
                ),
                const SizedBox(width: 6),
                Text(
                  'Requires ${getPlanDisplayName(requiredPlan)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: getPlanColor(requiredPlan),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build feature access widget (for list items)
  static Widget buildFeatureAccessIndicator({
    required String requiredPlan,
    bool isCompact = false,
  }) {
    if (requiredPlan == 'free') return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            getPlanColor(requiredPlan),
            getPlanColor(requiredPlan).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: isCompact ? 10 : 12,
            color: Colors.white,
          ),
          SizedBox(width: isCompact ? 3 : 4),
          Text(
            requiredPlan.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: isCompact ? 9 : 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Get chat limit message for free users
  static String getChatLimitMessage(String currentPlan, int chatCount) {
    if (currentPlan == 'premium' || currentPlan == 'pro') {
      return 'Unlimited chats';
    }
    return '${5 - chatCount} chats left today';
  }

  // NEW: Check if user can use chat feature
  static bool canUseChat(String currentPlan, int chatCount) {
    if (currentPlan == 'premium' || currentPlan == 'pro') {
      return true;
    }
    return chatCount < 5;
  }

  // NEW: Get feature status message
  static String getFeatureStatus(String featureName, String currentPlan) {
    final requiredPlan = featureAccess[featureName] ?? 'premium';
    final hasAccess = _comparePlans(currentPlan, requiredPlan);

    if (hasAccess) {
      return 'Available';
    } else {
      return 'Upgrade to ${getPlanDisplayName(requiredPlan)}';
    }
  }
}
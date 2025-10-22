import 'package:flutter/material.dart';


class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String? selectedPlan = 'free'; // free, premium, pro

  // Plan Data
  final Map<String, Map<String, dynamic>> plans = {
    'free': {
      'name': 'Free',
      'price': '₹0',
      'duration': '/Forever',
      'icon': Icons.favorite_outline,
      'isMostPopular': false,
      'borderColor': Colors.transparent,
      'bgColor': Colors.white,
      'included': [
        'Basic pregnancy tracker',
        'Weekly baby updates',
        'Simple milestone tracking',
        'Basic educational resources',
        'Symptom & mood logging',
        'Community access',
      ],
      'limitations': [
        'Limited AI baby chat responses',
        'Basic reminders only',
        'No personalized recommendations',
        'No webinar access',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price': '₹999',
      'duration': '/one time',
      'icon': Icons.chat_bubble_outline,
      'isMostPopular': true,
      'borderColor': const Color(0xFFD4B5E8),
      'bgColor': const Color(0xFFF5F0FB),
      'trialText': '1 month free trial included',
      'included': [
        'Everything in Free',
        'AI Baby Chat (Unlimited)',
        'Weekly Expert Webinars (Choose 1)',
        'AI Reminder Assistant',
        'AI Emotional Companion',
        'Personalized recommendations',
        'Advanced tracking tools',
        'Love Journal (Voice notes)',
        'Priority support',
        'Detailed analytics',
        'Custom meal plans',
      ],
    },
    'pro': {
      'name': 'Pro',
      'price': '₹9,999',
      'duration': '/one-time',
      'icon': Icons.emoji_events,
      'isMostPopular': false,
      'borderColor': const Color(0xFFFFB800),
      'bgColor': const Color(0xFFFFFBE6),
      'included': [
        'Everything in Premium',
        'Lifetime access',
        'All 3 Weekly Webinars',
        'Doctor consultations (3 per month)',
        'Pediatrician consultations',
        'Custom meal plans',
        'Family sharing (up to 3 members)',
        'Exclusive premium content',
        'Early access to new features',
        'Dedicated support specialist',
        'Postpartum support (1 year)',
        'Baby development tracker',
        'Lactation consultant access',
      ],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFD4B5E8),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Subscription Plans',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Choose the perfect plan for your pregnancy journey',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Premium Features
              _buildPremiumFeaturesCard(),
              const SizedBox(height: 24),
              // Free Plan
              _buildPlanCard('free'),
              const SizedBox(height: 16),
              // Premium Plan
              _buildPlanCard('premium'),
              const SizedBox(height: 16),
              // Pro Plan
              _buildPlanCard('pro'),
              const SizedBox(height: 24),
              // Feature Comparison Table
              _buildFeatureComparisonTable(),
              const SizedBox(height: 24),
              // Info Cards
              _buildInfoCard(
                icon: Icons.verified,
                text: 'All plans include basic pregnancy tracking',
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.videocam,
                text:
                'Premium: Choose 1 weekly webinar • Pro: Access all 3 webinars',
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.lock,
                text: 'Secure payment • No hidden fees',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.favorite,
                text: 'Special offer: Save 20% on yearly plans',
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.call,
                text: 'Need help choosing? Contact our support team',
                color: Colors.grey,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumFeaturesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.adjust, color: Colors.red, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'Premium Features',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFeatureRow('📹', 'Weekly Expert Webinars',
              'Join live webinars with pregnancy experts every week'),
          const SizedBox(height: 12),
          _buildFeatureRow('💬', 'AI Baby Chatbot',
              'Chat with your baby using AI that speaks in cute baby language'),
          const SizedBox(height: 12),
          _buildFeatureRow('🔔', 'AI Reminder Assistant',
              'Smart reminders for medications, appointments, and self-care'),
          const SizedBox(height: 12),
          _buildFeatureRow('❤️', 'AI Emotional Companion',
              'Mental wellness support with personalized affirmations'),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFB794F4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Premium+',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(String planKey) {
    final plan = plans[planKey]!;
    final isCurrent = selectedPlan == planKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planKey;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: plan['bgColor'],
          border: Border.all(
            color: isCurrent ? plan['borderColor'] : Colors.grey[300]!,
            width: isCurrent ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isCurrent
              ? [
            BoxShadow(
              color: (plan['borderColor'] as Color).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
            ),
          ],
        ),
        child: Stack(
          children: [
            if (plan['isMostPopular'] == true)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4B5E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '⭐ Most Popular',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (plan['isMostPopular'] == true) const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(plan['icon'],
                          color: const Color(0xFFB794F4), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        plan['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        plan['price'],
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB794F4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        plan['duration'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (plan['trialText'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      plan['trialText'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    "What's included:",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    (plan['included'] as List).length,
                        (index) {
                      final feature = (plan['included'] as List)[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '✓ ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              planKey == 'free'
                                  ? 'Already on Free Plan'
                                  : 'Starting ${plan['name']} Plan...',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: planKey == 'premium'
                            ? const Color(0xFFD4B5E8)
                            : planKey == 'pro'
                            ? const Color(0xFFFFB800)
                            : Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        planKey == 'premium'
                            ? 'Start Free Trial'
                            : planKey == 'pro'
                            ? 'Get Lifetime Access'
                            : 'Current Plan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: planKey == 'free'
                              ? Colors.grey[600]
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (planKey == 'premium')
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                        child: Text(
                          'Cancel anytime during trial',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feature Comparison',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              dataRowHeight: 50,
              headingRowHeight: 50,
              columnSpacing: 20,
              columns: const [
                DataColumn(
                  label: Text(
                    'Feature',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Free',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFB794F4),
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Pro',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ),
              ],
              rows: [
                _buildComparisonRow('Weekly Webinars', ['-', '✓ Choose 1', '✓ All 3']),
                _buildComparisonRow('AI Baby Chat', ['Limited', '✓ Unlimited', '✓ Unlimited']),
                _buildComparisonRow('Doctor Consultations', ['-', 'Pay per session', '3/month']),
                _buildComparisonRow('Love Journal', ['Text only', 'Voice notes', 'Voice + Templates']),
                _buildComparisonRow('AI Reminders', ['Basic', 'Smart AI', 'Smart AI + Priority']),
                _buildComparisonRow('Support', ['Community', 'Priority', 'Dedicated']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildComparisonRow(String feature, List<String> values) {
    return DataRow(
      cells: [
        DataCell(
          Text(
            feature,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        DataCell(
          Text(
            values[0],
            style: TextStyle(
              fontSize: 12,
              color: values[0] == '-' ? Colors.grey[400] : Colors.green,
            ),
          ),
        ),
        DataCell(
          Text(
            values[1],
            style: TextStyle(
              fontSize: 12,
              color: values[1].startsWith('✓') ? Colors.green : Colors.grey,
            ),
          ),
        ),
        DataCell(
          Text(
            values[2],
            style: TextStyle(
              fontSize: 12,
              color: values[2].startsWith('✓') ? Colors.green : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      {required IconData icon,
        required String text,
        required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
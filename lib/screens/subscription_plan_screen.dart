import 'package:flutter/material.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlansScreen> createState() =>
      _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  String? selectedPlan = 'free'; // free, basic, premium, pro

  // Updated Plan Data - Added Basic plan
  final Map<String, Map<String, dynamic>> plans = {
    'free': {
      'name': 'Free',
      'price': '₹0',
      'duration': 'Forever',
      'icon': Icons.free_breakfast,
      'isMostPopular': false,
      'borderColor': Colors.transparent,
      'bgColor': Colors.white,
      'included': [
        'Ads included',
        'Basic pregnancy tracker',
        'Weekly baby updates',
        'Milestone tracking',
        'Education resources',
        'Symptoms & mood log',
        '5 chats/day with AI baby',
        'Love journal (text only)',
      ],
    },
    'basic': {
      'name': 'Basic',
      'price': '₹99',
      'duration': 'Ad-Free Experience',
      'icon': Icons.ads_click,
      'isMostPopular': false,
      'borderColor': Colors.blue,
      'bgColor': Colors.blue[50]!,
      'included': [
        'Everything in Free',
        'No ads',
        'Ad-free experience',
        'Basic pregnancy tracker',
        'Weekly baby updates',
        'Milestone tracking',
        'Education resources',
        'Symptoms & mood log',
        '5 chats/day with AI baby',
        'Love journal (text only)',
      ],
    },
    'premium': {
      'name': 'Premium',
      'price': '₹999',
      'duration': '1 Year Access',
      'icon': Icons.favorite,
      'isMostPopular': true,
      'borderColor': const Color(0xFFD4B5E8),
      'bgColor': const Color(0xFFF5F0FB),
      'included': [
        'Everything in Basic',
        'Unlimited AI baby chat',
        'Weekly recorded videos',
        'Personalized recommendations',
        'Love journal (voice/photos/videos)',
        'Custom meal plan',
        'Priority support',
      ],
    },
    'pro': {
      'name': 'Pro',
      'price': '₹9,999',
      'duration': 'Lifetime Access',
      'icon': Icons.emoji_events,
      'isMostPopular': false,
      'borderColor': const Color(0xFFFFB800),
      'bgColor': const Color(0xFFFFFBE6),
      'included': [
        'Everything in Premium',
        'Lifetime access',
        'Love journal journey video',
        'Monthly webinar',
        'Partner sharing',
        'Postpartum support (1 year)',
        'Lactation support (1 year)',
        'Pediatrician support (1 year)',
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

              // Updated Plan Type Indicators - Added Basic
              _buildPlanTypeIndicators(),
              const SizedBox(height: 24),

              // Free Plan
              _buildPlanCard('free'),
              const SizedBox(height: 16),

              // Basic Plan
              _buildPlanCard('basic'),
              const SizedBox(height: 16),

              // Premium Plan
              _buildPlanCard('premium'),
              const SizedBox(height: 16),

              // Pro Plan
              _buildPlanCard('pro'),
              const SizedBox(height: 24),

              // Updated Feature Comparison Table
              _buildFeatureComparisonTable(),
              const SizedBox(height: 24),

              // Updated Info Cards
              _buildInfoCard(
                icon: Icons.ads_click,
                text: 'Free plan includes advertisements',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.no_accounts,
                text: 'Basic plan removes all ads for attentive parents',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.videocam,
                text: 'Premium includes weekly recorded videos & custom meal plans',
                color: Colors.purple,
              ),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.people,
                text: 'Pro plan allows sharing with partner & includes 1-year support',
                color: Colors.green,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTypeIndicators() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: const [
                Icon(Icons.ads_click, color: Colors.orange, size: 20),
                SizedBox(height: 4),
                Text(
                  'Free\nWith Ads',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue),
            ),
            child: Column(
              children: const [
                Icon(Icons.no_accounts, color: Colors.blue, size: 20),
                SizedBox(height: 4),
                Text(
                  'Basic\nAd-Free',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F0FB),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFD4B5E8)),
            ),
            child: Column(
              children: const [
                Icon(Icons.favorite, color: Color(0xFFD4B5E8), size: 20),
                SizedBox(height: 4),
                Text(
                  'Premium\nFeatures',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFD4B5E8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBE6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFFFB800)),
            ),
            child: Column(
              children: const [
                Icon(Icons.emoji_events, color: Color(0xFFFFB800), size: 20),
                SizedBox(height: 4),
                Text(
                  'Pro\nLifetime',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFB800),
                  ),
                ),
              ],
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
                      Icon(plan['icon'], color: _getPlanColor(planKey), size: 28),
                      const SizedBox(width: 12),
                      Text(
                        plan['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _getPlanColor(planKey),
                        ),
                      ),
                      if (planKey == 'free') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'ADS',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                      if (planKey == 'basic') ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'AD-FREE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        plan['price'],
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: _getPlanColor(planKey),
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
                  if (planKey == 'basic') ...[
                    const SizedBox(height: 8),
                    Text(
                      'Ad-Free Basic for Attentive Parent',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getPlanColor(planKey),
                        fontStyle: FontStyle.italic,
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
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: _getPlanColor(planKey),
                            ),
                            const SizedBox(width: 8),
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
                        _handlePlanSelection(planKey);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _getPlanColor(planKey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        _getButtonText(planKey),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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

  Color _getPlanColor(String planKey) {
    switch (planKey) {
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

  String _getButtonText(String planKey) {
    switch (planKey) {
      case 'free':
        return 'Current Plan';
      case 'basic':
        return 'Get Ad-Free';
      case 'premium':
        return 'Get Premium';
      case 'pro':
        return 'Get Lifetime Access';
      default:
        return 'Select Plan';
    }
  }

  void _handlePlanSelection(String planKey) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          planKey == 'free'
              ? 'You are on Free Plan'
              : 'Starting ${plans[planKey]!['name']} Plan...',
        ),
      ),
    );
    // TODO: Add payment integration here
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
              columns: [
                const DataColumn(
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
                      color: Colors.orange,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Basic',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Premium',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Color(0xFFD4B5E8),
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
                _buildComparisonRow('Advertisements', ['Yes', 'No', 'No', 'No']),
                _buildComparisonRow('AI Baby Chat', ['5/day', '5/day', 'Unlimited', 'Unlimited']),
                _buildComparisonRow('Love Journal', ['Text only', 'Text only', 'Voice/Photos/Videos', 'Voice/Photos/Videos + Journey Video']),
                _buildComparisonRow('Weekly Videos', ['-', '-', 'Recorded', 'Recorded']),
                _buildComparisonRow('Custom Meal Plan', ['-', '-', 'Yes', 'Yes']),
                _buildComparisonRow('Webinars', ['-', '-', '-', 'Monthly']),
                _buildComparisonRow('Partner Sharing', ['-', '-', '-', 'Yes']),
                _buildComparisonRow('Support', ['-', '-', 'Priority', '1 Year Postpartum + Lactation + Pediatric']),
                _buildComparisonRow('Access', ['Forever', 'Forever', '1 Year', 'Lifetime']),
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
          _buildComparisonCell(values[0]),
        ),
        DataCell(
          _buildComparisonCell(values[1]),
        ),
        DataCell(
          _buildComparisonCell(values[2]),
        ),
        DataCell(
          _buildComparisonCell(values[3]),
        ),
      ],
    );
  }

  Widget _buildComparisonCell(String value) {
    Color textColor = Colors.grey;
    if (value == 'Yes' || value == 'Unlimited' || value.contains('Recorded') || value == 'Priority') {
      textColor = Colors.green;
    } else if (value == 'No' || value == '-') {
      textColor = Colors.grey;
    } else if (value.contains('1 Year') || value.contains('Lifetime')) {
      textColor = const Color(0xFFFFB800);
    }

    return Text(
      value,
      style: TextStyle(
        fontSize: 11,
        color: textColor,
        fontWeight: value == 'Yes' || value == 'Unlimited' || value.contains('1 Year') || value == 'Lifetime'
            ? FontWeight.bold
            : FontWeight.normal,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String text,
    required Color color,
  }) {
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




// import 'package:flutter/material.dart';
//
// class SubscriptionPlansScreen extends StatefulWidget {
//   const SubscriptionPlansScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SubscriptionPlansScreen> createState() =>
//       _SubscriptionPlansScreenState();
// }
//
// class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
//   String? selectedPlan = 'free'; // free, premium, pro
//
//   // Updated Plan Data - Removed Basic plan
//   final Map<String, Map<String, dynamic>> plans = {
//     'free': {
//       'name': 'Free',
//       'price': '₹0',
//       'duration': 'Forever',
//       'icon': Icons.free_breakfast,
//       'isMostPopular': false,
//       'borderColor': Colors.transparent,
//       'bgColor': Colors.white,
//       'included': [
//         'Ads included',
//         'Basic pregnancy tracker',
//         'Weekly baby updates',
//         'Milestone tracking',
//         'Education resources',
//         'Symptoms & mood log',
//         '5 chats/day with AI baby',
//         'Love journal (text only)',
//       ],
//     },
//     'premium': {
//       'name': 'Premium',
//       'price': '₹999',
//       'duration': '1 Year Access',
//       'icon': Icons.favorite,
//       'isMostPopular': true,
//       'borderColor': const Color(0xFFD4B5E8),
//       'bgColor': const Color(0xFFF5F0FB),
//       'included': [
//         'Everything in Free',
//         'No ads',
//         'Unlimited AI baby chat',
//         'Weekly recorded videos',
//         'Personalized recommendations',
//         'Love journal (voice/photos/videos)',
//         'Custom meal plan',
//         'Priority support',
//       ],
//     },
//     'pro': {
//       'name': 'Pro',
//       'price': '₹9,999',
//       'duration': 'Lifetime Access',
//       'icon': Icons.emoji_events,
//       'isMostPopular': false,
//       'borderColor': const Color(0xFFFFB800),
//       'bgColor': const Color(0xFFFFFBE6),
//       'included': [
//         'Everything in Premium',
//         'Lifetime access',
//         'Love journal journey video',
//         'Monthly webinar',
//         'Partner sharing',
//         'Postpartum support (1 year)',
//         'Lactation support (1 year)',
//         'Pediatrician support (1 year)',
//       ],
//     },
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFD4B5E8),
//         elevation: 0,
//         leading: GestureDetector(
//           onTap: () => Navigator.pop(context),
//           child: const Icon(Icons.arrow_back, color: Colors.white),
//         ),
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               'Subscription Plans',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             Text(
//               'Choose the perfect plan for your pregnancy journey',
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               const SizedBox(height: 16),
//
//               // Updated Plan Type Indicators - Removed Basic
//               _buildPlanTypeIndicators(),
//               const SizedBox(height: 24),
//
//               // Free Plan
//               _buildPlanCard('free'),
//               const SizedBox(height: 16),
//
//               // Premium Plan
//               _buildPlanCard('premium'),
//               const SizedBox(height: 16),
//
//               // Pro Plan
//               _buildPlanCard('pro'),
//               const SizedBox(height: 24),
//
//               // Updated Feature Comparison Table
//               _buildFeatureComparisonTable(),
//               const SizedBox(height: 24),
//
//               // Updated Info Cards
//               _buildInfoCard(
//                 icon: Icons.ads_click,
//                 text: 'Free plan includes advertisements',
//                 color: Colors.orange,
//               ),
//               const SizedBox(height: 12),
//               _buildInfoCard(
//                 icon: Icons.videocam,
//                 text: 'Premium includes weekly recorded videos & custom meal plans',
//                 color: Colors.purple,
//               ),
//               const SizedBox(height: 12),
//               _buildInfoCard(
//                 icon: Icons.people,
//                 text: 'Pro plan allows sharing with partner & includes 1-year support',
//                 color: Colors.green,
//               ),
//               const SizedBox(height: 32),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildPlanTypeIndicators() {
//     return Row(
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: Colors.orange[50],
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Colors.orange),
//             ),
//             child: Column(
//               children: const [
//                 Icon(Icons.ads_click, color: Colors.orange, size: 20),
//                 SizedBox(height: 4),
//                 Text(
//                   'Free\nWith Ads',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF5F0FB),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Color(0xFFD4B5E8)),
//             ),
//             child: Column(
//               children: const [
//                 Icon(Icons.favorite, color: Color(0xFFD4B5E8), size: 20),
//                 SizedBox(height: 4),
//                 Text(
//                   'Premium\nAd-Free + Features',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFD4B5E8),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFFFFFBE6),
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: Color(0xFFFFB800)),
//             ),
//             child: Column(
//               children: const [
//                 Icon(Icons.emoji_events, color: Color(0xFFFFB800), size: 20),
//                 SizedBox(height: 4),
//                 Text(
//                   'Pro\nLifetime + Support',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFFFFB800),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlanCard(String planKey) {
//     final plan = plans[planKey]!;
//     final isCurrent = selectedPlan == planKey;
//
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedPlan = planKey;
//         });
//       },
//       child: Container(
//         decoration: BoxDecoration(
//           color: plan['bgColor'],
//           border: Border.all(
//             color: isCurrent ? plan['borderColor'] : Colors.grey[300]!,
//             width: isCurrent ? 2 : 1,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: isCurrent
//               ? [
//             BoxShadow(
//               color: (plan['borderColor'] as Color).withOpacity(0.3),
//               blurRadius: 12,
//               offset: const Offset(0, 4),
//             ),
//           ]
//               : [
//             BoxShadow(
//               color: Colors.grey.withOpacity(0.1),
//               blurRadius: 8,
//             ),
//           ],
//         ),
//         child: Stack(
//           children: [
//             if (plan['isMostPopular'] == true)
//               Positioned(
//                 top: 0,
//                 left: 0,
//                 right: 0,
//                 child: Center(
//                   child: Container(
//                     padding:
//                     const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFD4B5E8),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: const Text(
//                       '⭐ Most Popular',
//                       style: TextStyle(
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             Padding(
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (plan['isMostPopular'] == true) const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       Icon(plan['icon'], color: _getPlanColor(planKey), size: 28),
//                       const SizedBox(width: 12),
//                       Text(
//                         plan['name'],
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w700,
//                           color: _getPlanColor(planKey),
//                         ),
//                       ),
//                       if (planKey == 'free') ...[
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 8, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.orange,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: const Text(
//                             'ADS',
//                             style: TextStyle(
//                               fontSize: 10,
//                               fontWeight: FontWeight.w600,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.baseline,
//                     textBaseline: TextBaseline.alphabetic,
//                     children: [
//                       Text(
//                         plan['price'],
//                         style: TextStyle(
//                           fontSize: 32,
//                           fontWeight: FontWeight.w700,
//                           color: _getPlanColor(planKey),
//                         ),
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         plan['duration'],
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     "What's included:",
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.grey[800],
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...List.generate(
//                     (plan['included'] as List).length,
//                         (index) {
//                       final feature = (plan['included'] as List)[index];
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 8),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Icon(
//                               Icons.check_circle,
//                               size: 16,
//                               color: _getPlanColor(planKey),
//                             ),
//                             const SizedBox(width: 8),
//                             Expanded(
//                               child: Text(
//                                 feature,
//                                 style: TextStyle(
//                                   fontSize: 13,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: () {
//                         _handlePlanSelection(planKey);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: _getPlanColor(planKey),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                       ),
//                       child: Text(
//                         _getButtonText(planKey),
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Color _getPlanColor(String planKey) {
//     switch (planKey) {
//       case 'free':
//         return Colors.orange;
//       case 'premium':
//         return const Color(0xFFD4B5E8);
//       case 'pro':
//         return const Color(0xFFFFB800);
//       default:
//         return Colors.grey;
//     }
//   }
//
//   String _getButtonText(String planKey) {
//     switch (planKey) {
//       case 'free':
//         return 'Current Plan';
//       case 'premium':
//         return 'Get Premium';
//       case 'pro':
//         return 'Get Lifetime Access';
//       default:
//         return 'Select Plan';
//     }
//   }
//
//   void _handlePlanSelection(String planKey) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           planKey == 'free'
//               ? 'You are on Free Plan'
//               : 'Starting ${plans[planKey]!['name']} Plan...',
//         ),
//       ),
//     );
//     // TODO: Add payment integration here
//   }
//
//   Widget _buildFeatureComparisonTable() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Feature Comparison',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 16),
//           SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: DataTable(
//               dataRowHeight: 50,
//               headingRowHeight: 50,
//               columnSpacing: 20,
//               columns: [
//                 const DataColumn(
//                   label: Text(
//                     'Feature',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Text(
//                     'Free',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: Colors.orange,
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Text(
//                     'Premium',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: Color(0xFFD4B5E8),
//                     ),
//                   ),
//                 ),
//                 DataColumn(
//                   label: Text(
//                     'Pro',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w600,
//                       fontSize: 12,
//                       color: Color(0xFFFFB800),
//                     ),
//                   ),
//                 ),
//               ],
//               rows: [
//                 _buildComparisonRow('Advertisements', ['Yes', 'No', 'No']),
//                 _buildComparisonRow('AI Baby Chat', ['5/day', 'Unlimited', 'Unlimited']),
//                 _buildComparisonRow('Love Journal', ['Text only', 'Voice/Photos/Videos', 'Voice/Photos/Videos + Journey Video']),
//                 _buildComparisonRow('Weekly Videos', ['-', 'Recorded', 'Recorded']),
//                 _buildComparisonRow('Custom Meal Plan', ['-', 'Yes', 'Yes']),
//                 _buildComparisonRow('Webinars', ['-', '-', 'Monthly']),
//                 _buildComparisonRow('Partner Sharing', ['-', '-', 'Yes']),
//                 _buildComparisonRow('Support', ['-', 'Priority', '1 Year Postpartum + Lactation + Pediatric']),
//                 _buildComparisonRow('Access', ['Forever', '1 Year', 'Lifetime']),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   DataRow _buildComparisonRow(String feature, List<String> values) {
//     return DataRow(
//       cells: [
//         DataCell(
//           Text(
//             feature,
//             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
//           ),
//         ),
//         DataCell(
//           _buildComparisonCell(values[0]),
//         ),
//         DataCell(
//           _buildComparisonCell(values[1]),
//         ),
//         DataCell(
//           _buildComparisonCell(values[2]),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildComparisonCell(String value) {
//     Color textColor = Colors.grey;
//     if (value == 'Yes' || value == 'Unlimited' || value.contains('Recorded') || value == 'Priority') {
//       textColor = Colors.green;
//     } else if (value == 'No' || value == '-') {
//       textColor = Colors.grey;
//     } else if (value.contains('1 Year') || value.contains('Lifetime')) {
//       textColor = const Color(0xFFFFB800);
//     }
//
//     return Text(
//       value,
//       style: TextStyle(
//         fontSize: 11,
//         color: textColor,
//         fontWeight: value == 'Yes' || value == 'Unlimited' || value.contains('1 Year') || value == 'Lifetime'
//             ? FontWeight.bold
//             : FontWeight.normal,
//       ),
//     );
//   }
//
//   Widget _buildInfoCard({
//     required IconData icon,
//     required String text,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[700],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
//
//
// // import 'package:flutter/material.dart';
// //
// // class SubscriptionPlansScreen extends StatefulWidget {
// //   const SubscriptionPlansScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<SubscriptionPlansScreen> createState() =>
// //       _SubscriptionPlansScreenState();
// // }
// //
// // class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
// //   String? selectedPlan = 'free'; // free, basic, premium, pro
// //
// //   // Plan Data
// //   final Map<String, Map<String, dynamic>> plans = {
// //     'free': {
// //       'name': 'Free',
// //       'price': '₹0',
// //       'duration': 'Forever',
// //       'icon': Icons.free_breakfast,
// //       'isMostPopular': false,
// //       'borderColor': Colors.transparent,
// //       'bgColor': Colors.white,
// //       'included': [
// //         'Basic pregnancy tracker',
// //         'Weekly baby updates',
// //         'Milestone tracking',
// //         'Educational resources',
// //         'Symptoms & mood logging',
// //         'Limited Baby AI Chat (5 chats/day)',
// //         'Love Journal (text only)',
// //       ],
// //       'limitations': [
// //         'Ads included',
// //         'Limited AI chat responses',
// //         'No voice/image support in journal',
// //       ],
// //     },
// //     'basic': {
// //       'name': 'Basic',
// //       'price': '₹99',
// //       'duration': 'one-time',
// //       'icon': Icons.ads_click,
// //       'isMostPopular': false,
// //       'borderColor': Colors.blue,
// //       'bgColor': const Color(0xFFE3F2FD),
// //       'included': [
// //         'Everything in Free plan',
// //         'No advertisements',
// //         'Unlimited app access',
// //         'Ad-free experience',
// //       ],
// //     },
// //     'premium': {
// //       'name': 'Premium',
// //       'price': '₹999',
// //       'duration': '1 Year Access',
// //       'icon': Icons.favorite,
// //       'isMostPopular': true,
// //       'borderColor': const Color(0xFFD4B5E8),
// //       'bgColor': const Color(0xFFF5F0FB),
// //       'included': [
// //         'Everything in Basic',
// //         'Unlimited AI Baby Chat',
// //         'Weekly recorded videos',
// //         'Personalized recommendations',
// //         'Love Journal (Voice, images, videos)',
// //         'Custom meal plan and tracking',
// //         'Priority support',
// //       ],
// //     },
// //     'pro': {
// //       'name': 'Pro',
// //       'price': '₹9,999',
// //       'duration': 'Lifetime Access',
// //       'icon': Icons.emoji_events,
// //       'isMostPopular': false,
// //       'borderColor': const Color(0xFFFFB800),
// //       'bgColor': const Color(0xFFFFFBE6),
// //       'included': [
// //         'Everything in Premium',
// //         'Lifetime access',
// //         'Love Journal Journey Video',
// //         'Monthly webinar during pregnancy',
// //         'Sharing app with partner',
// //         'Postpartum support (1 year)',
// //         'Lactation support (1 year)',
// //         'Pediatrician support (1 year)',
// //       ],
// //     },
// //   };
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: Colors.grey[50],
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFFD4B5E8),
// //         elevation: 0,
// //         leading: GestureDetector(
// //           onTap: () => Navigator.pop(context),
// //           child: const Icon(Icons.arrow_back, color: Colors.white),
// //         ),
// //         title: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: const [
// //             Text(
// //               'Subscription Plans',
// //               style: TextStyle(
// //                 color: Colors.white,
// //                 fontSize: 18,
// //                 fontWeight: FontWeight.w600,
// //               ),
// //             ),
// //             Text(
// //               'Choose the perfect plan for your pregnancy journey',
// //               style: TextStyle(
// //                 color: Colors.white70,
// //                 fontSize: 12,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 16),
// //
// //               // Plan Type Indicators
// //               _buildPlanTypeIndicators(),
// //               const SizedBox(height: 24),
// //
// //               // Free Plan
// //               _buildPlanCard('free'),
// //               const SizedBox(height: 16),
// //
// //               // Basic Plan
// //               _buildPlanCard('basic'),
// //               const SizedBox(height: 16),
// //
// //               // Premium Plan
// //               _buildPlanCard('premium'),
// //               const SizedBox(height: 16),
// //
// //               // Pro Plan
// //               _buildPlanCard('pro'),
// //               const SizedBox(height: 24),
// //
// //               // Feature Comparison Table
// //               _buildFeatureComparisonTable(),
// //               const SizedBox(height: 24),
// //
// //               // Info Cards
// //               _buildInfoCard(
// //                 icon: Icons.ads_click,
// //                 text: 'Free plan includes advertisements',
// //                 color: Colors.orange,
// //               ),
// //               const SizedBox(height: 12),
// //               _buildInfoCard(
// //                 icon: Icons.block,
// //                 text: 'Basic plan removes all ads',
// //                 color: Colors.blue,
// //               ),
// //               const SizedBox(height: 12),
// //               _buildInfoCard(
// //                 icon: Icons.videocam,
// //                 text: 'Premium includes weekly recorded videos',
// //                 color: Colors.purple,
// //               ),
// //               const SizedBox(height: 12),
// //               _buildInfoCard(
// //                 icon: Icons.people,
// //                 text: 'Pro plan allows sharing with partner',
// //                 color: Colors.green,
// //               ),
// //               const SizedBox(height: 12),
// //               _buildInfoCard(
// //                 icon: Icons.health_and_safety,
// //                 text: 'Pro includes 1-year postpartum & pediatric support',
// //                 color: Colors.red,
// //               ),
// //               const SizedBox(height: 32),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildPlanTypeIndicators() {
// //     return Row(
// //       children: [
// //         Expanded(
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(vertical: 8),
// //             decoration: BoxDecoration(
// //               color: Colors.blue[50],
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: Colors.blue),
// //             ),
// //             child: Column(
// //               children: const [
// //                 Icon(Icons.ads_click, color: Colors.blue, size: 20),
// //                 SizedBox(height: 4),
// //                 Text(
// //                   'Free\nWith Ads',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.blue,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Expanded(
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(vertical: 8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFE3F2FD),
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: Colors.blue),
// //             ),
// //             child: Column(
// //               children: const [
// //                 Icon(Icons.block, color: Colors.blue, size: 20),
// //                 SizedBox(height: 4),
// //                 Text(
// //                   'Basic\nAd-Free',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w600,
// //                     color: Colors.blue,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Expanded(
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(vertical: 8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF5F0FB),
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: Color(0xFFD4B5E8)),
// //             ),
// //             child: Column(
// //               children: const [
// //                 Icon(Icons.favorite, color: Color(0xFFD4B5E8), size: 20),
// //                 SizedBox(height: 4),
// //                 Text(
// //                   'Premium\nCaring Parent',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFFD4B5E8),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //         const SizedBox(width: 8),
// //         Expanded(
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(vertical: 8),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFFFFBE6),
// //               borderRadius: BorderRadius.circular(8),
// //               border: Border.all(color: Color(0xFFFFB800)),
// //             ),
// //             child: Column(
// //               children: const [
// //                 Icon(Icons.emoji_events, color: Color(0xFFFFB800), size: 20),
// //                 SizedBox(height: 4),
// //                 Text(
// //                   'Pro\nCurious Parent',
// //                   textAlign: TextAlign.center,
// //                   style: TextStyle(
// //                     fontSize: 10,
// //                     fontWeight: FontWeight.w600,
// //                     color: Color(0xFFFFB800),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildPlanCard(String planKey) {
// //     final plan = plans[planKey]!;
// //     final isCurrent = selectedPlan == planKey;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         setState(() {
// //           selectedPlan = planKey;
// //         });
// //       },
// //       child: Container(
// //         decoration: BoxDecoration(
// //           color: plan['bgColor'],
// //           border: Border.all(
// //             color: isCurrent ? plan['borderColor'] : Colors.grey[300]!,
// //             width: isCurrent ? 2 : 1,
// //           ),
// //           borderRadius: BorderRadius.circular(16),
// //           boxShadow: isCurrent
// //               ? [
// //             BoxShadow(
// //               color: (plan['borderColor'] as Color).withOpacity(0.3),
// //               blurRadius: 12,
// //               offset: const Offset(0, 4),
// //             ),
// //           ]
// //               : [
// //             BoxShadow(
// //               color: Colors.grey.withOpacity(0.1),
// //               blurRadius: 8,
// //             ),
// //           ],
// //         ),
// //         child: Stack(
// //           children: [
// //             if (plan['isMostPopular'] == true)
// //               Positioned(
// //                 top: 0,
// //                 left: 0,
// //                 right: 0,
// //                 child: Center(
// //                   child: Container(
// //                     padding:
// //                     const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
// //                     decoration: BoxDecoration(
// //                       color: const Color(0xFFD4B5E8),
// //                       borderRadius: BorderRadius.circular(20),
// //                     ),
// //                     child: const Text(
// //                       '⭐ Most Popular',
// //                       style: TextStyle(
// //                         fontSize: 12,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.white,
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             Padding(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   if (plan['isMostPopular'] == true) const SizedBox(height: 20),
// //                   Row(
// //                     children: [
// //                       Icon(plan['icon'],
// //                           color: _getPlanColor(planKey), size: 28),
// //                       const SizedBox(width: 12),
// //                       Text(
// //                         plan['name'],
// //                         style: TextStyle(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.w700,
// //                           color: _getPlanColor(planKey),
// //                         ),
// //                       ),
// //                       if (planKey == 'free') ...[
// //                         const SizedBox(width: 8),
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                           decoration: BoxDecoration(
// //                             color: Colors.orange,
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: const Text(
// //                             'ADS',
// //                             style: TextStyle(
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                       if (planKey == 'basic') ...[
// //                         const SizedBox(width: 8),
// //                         Container(
// //                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                           decoration: BoxDecoration(
// //                             color: Colors.blue,
// //                             borderRadius: BorderRadius.circular(10),
// //                           ),
// //                           child: const Text(
// //                             'AD-FREE',
// //                             style: TextStyle(
// //                               fontSize: 10,
// //                               fontWeight: FontWeight.w600,
// //                               color: Colors.white,
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ],
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.baseline,
// //                     textBaseline: TextBaseline.alphabetic,
// //                     children: [
// //                       Text(
// //                         plan['price'],
// //                         style: TextStyle(
// //                           fontSize: 32,
// //                           fontWeight: FontWeight.w700,
// //                           color: _getPlanColor(planKey),
// //                         ),
// //                       ),
// //                       const SizedBox(width: 4),
// //                       Text(
// //                         plan['duration'],
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     "What's included:",
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w600,
// //                       color: Colors.grey[800],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   ...List.generate(
// //                     (plan['included'] as List).length,
// //                         (index) {
// //                       final feature = (plan['included'] as List)[index];
// //                       return Padding(
// //                         padding: const EdgeInsets.only(bottom: 8),
// //                         child: Row(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             const Text(
// //                               '✓ ',
// //                               style: TextStyle(
// //                                 fontSize: 14,
// //                                 color: Colors.green,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                             Expanded(
// //                               child: Text(
// //                                 feature,
// //                                 style: TextStyle(
// //                                   fontSize: 13,
// //                                   color: Colors.grey[700],
// //                                 ),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                   if (plan['limitations'] != null) ...[
// //                     const SizedBox(height: 12),
// //                     Text(
// //                       "Limitations:",
// //                       style: TextStyle(
// //                         fontSize: 13,
// //                         fontWeight: FontWeight.w600,
// //                         color: Colors.red[600],
// //                       ),
// //                     ),
// //                     const SizedBox(height: 8),
// //                     ...List.generate(
// //                       (plan['limitations'] as List).length,
// //                           (index) {
// //                         final limitation = (plan['limitations'] as List)[index];
// //                         return Padding(
// //                           padding: const EdgeInsets.only(bottom: 6),
// //                           child: Row(
// //                             crossAxisAlignment: CrossAxisAlignment.start,
// //                             children: [
// //                               const Text(
// //                                 '✗ ',
// //                                 style: TextStyle(
// //                                   fontSize: 14,
// //                                   color: Colors.red,
// //                                   fontWeight: FontWeight.bold,
// //                                 ),
// //                               ),
// //                               Expanded(
// //                                 child: Text(
// //                                   limitation,
// //                                   style: TextStyle(
// //                                     fontSize: 12,
// //                                     color: Colors.grey[600],
// //                                     fontStyle: FontStyle.italic,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         );
// //                       },
// //                     ),
// //                   ],
// //                   const SizedBox(height: 16),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () {
// //                         _handlePlanSelection(planKey);
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: _getPlanColor(planKey),
// //                         padding: const EdgeInsets.symmetric(vertical: 12),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(24),
// //                         ),
// //                       ),
// //                       child: Text(
// //                         _getButtonText(planKey),
// //                         style: TextStyle(
// //                           fontSize: 14,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Color _getPlanColor(String planKey) {
// //     switch (planKey) {
// //       case 'free':
// //         return Colors.orange;
// //       case 'basic':
// //         return Colors.blue;
// //       case 'premium':
// //         return const Color(0xFFD4B5E8);
// //       case 'pro':
// //         return const Color(0xFFFFB800);
// //       default:
// //         return Colors.grey;
// //     }
// //   }
// //
// //   String _getButtonText(String planKey) {
// //     switch (planKey) {
// //       case 'free':
// //         return 'Current Plan';
// //       case 'basic':
// //         return 'Go Ad-Free';
// //       case 'premium':
// //         return 'Get Premium';
// //       case 'pro':
// //         return 'Get Lifetime Access';
// //       default:
// //         return 'Select Plan';
// //     }
// //   }
// //
// //   void _handlePlanSelection(String planKey) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(
// //           planKey == 'free'
// //               ? 'You are on Free Plan'
// //               : 'Starting ${plans[planKey]!['name']} Plan...',
// //         ),
// //       ),
// //     );
// //     // TODO: Add payment integration here
// //   }
// //
// //   Widget _buildFeatureComparisonTable() {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(16),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.grey.withOpacity(0.1),
// //             blurRadius: 10,
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             'Feature Comparison',
// //             style: TextStyle(
// //               fontSize: 16,
// //               fontWeight: FontWeight.w600,
// //               color: Colors.black87,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
// //           SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: DataTable(
// //               dataRowHeight: 50,
// //               headingRowHeight: 50,
// //               columnSpacing: 20,
// //               columns: [
// //                 const DataColumn(
// //                   label: Text(
// //                     'Feature',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: 12,
// //                     ),
// //                   ),
// //                 ),
// //                 DataColumn(
// //                   label: Text(
// //                     'Free',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: 12,
// //                       color: Colors.orange,
// //                     ),
// //                   ),
// //                 ),
// //                 DataColumn(
// //                   label: Text(
// //                     'Basic',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: 12,
// //                       color: Colors.blue,
// //                     ),
// //                   ),
// //                 ),
// //                 DataColumn(
// //                   label: Text(
// //                     'Premium',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: 12,
// //                       color: Color(0xFFD4B5E8),
// //                     ),
// //                   ),
// //                 ),
// //                 DataColumn(
// //                   label: Text(
// //                     'Pro',
// //                     style: TextStyle(
// //                       fontWeight: FontWeight.w600,
// //                       fontSize: 12,
// //                       color: Color(0xFFFFB800),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //               rows: [
// //                 _buildComparisonRow('Advertisements', ['✓', '✗', '✗', '✗']),
// //                 _buildComparisonRow('AI Baby Chat', ['5/day', '5/day', 'Unlimited', 'Unlimited']),
// //                 _buildComparisonRow('Love Journal', ['Text', 'Text', 'Voice+Media', 'Voice+Media+Video']),
// //                 _buildComparisonRow('Weekly Videos', ['-', '-', '✓ Recorded', '✓ Recorded']),
// //                 _buildComparisonRow('Webinars', ['-', '-', '-', 'Monthly Live']),
// //                 _buildComparisonRow('Meal Plans', ['-', '-', 'Custom', 'Custom']),
// //                 _buildComparisonRow('Partner Sharing', ['-', '-', '-', '✓']),
// //                 _buildComparisonRow('Support Period', ['-', '-', '1 Year', 'Lifetime + 1Y Support']),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   DataRow _buildComparisonRow(String feature, List<String> values) {
// //     return DataRow(
// //       cells: [
// //         DataCell(
// //           Text(
// //             feature,
// //             style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
// //           ),
// //         ),
// //         DataCell(
// //           _buildComparisonCell(values[0]),
// //         ),
// //         DataCell(
// //           _buildComparisonCell(values[1]),
// //         ),
// //         DataCell(
// //           _buildComparisonCell(values[2]),
// //         ),
// //         DataCell(
// //           _buildComparisonCell(values[3]),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildComparisonCell(String value) {
// //     Color textColor = Colors.grey;
// //     if (value == '✓') {
// //       textColor = Colors.green;
// //     } else if (value == '✗') {
// //       textColor = Colors.red;
// //     } else if (value == 'Unlimited' || value.contains('✓')) {
// //       textColor = Colors.green;
// //     }
// //
// //     return Text(
// //       value,
// //       style: TextStyle(
// //         fontSize: 12,
// //         color: textColor,
// //         fontWeight: value == '✓' || value == 'Unlimited' ? FontWeight.bold : FontWeight.normal,
// //       ),
// //     );
// //   }
// //
// //   Widget _buildInfoCard({
// //     required IconData icon,
// //     required String text,
// //     required Color color,
// //   }) {
// //     return Container(
// //       padding: const EdgeInsets.all(12),
// //       decoration: BoxDecoration(
// //         color: color.withOpacity(0.1),
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Icon(icon, color: color, size: 20),
// //           const SizedBox(width: 12),
// //           Expanded(
// //             child: Text(
// //               text,
// //               style: TextStyle(
// //                 fontSize: 12,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// //

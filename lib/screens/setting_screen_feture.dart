import 'package:flutter/material.dart';
import 'package:bump_bond_flutter_app/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreenFeture extends StatefulWidget {
  const SettingsScreenFeture({Key? key}) : super(key: key);

  @override
  State<SettingsScreenFeture> createState() => _SettingsScreenFetureState();
}

class _SettingsScreenFetureState extends State<SettingsScreenFeture> {
  bool dailyReminders = true;
  bool chatNotifications = true;
  bool milestoneAlerts = true;
  bool dataSharing = false;
  bool analytics = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  // ✅ Load notification settings from SharedPreferences
  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        dailyReminders = prefs.getBool('notifications_enabled') ?? true;
        chatNotifications = prefs.getBool('chat_notifications') ?? true;
        milestoneAlerts = prefs.getBool('milestone_alerts') ?? true;
        dataSharing = prefs.getBool('data_sharing') ?? false;
        analytics = prefs.getBool('analytics') ?? true;
      });
    } catch (e) {
      print('Error loading settings: $e');
    }
  }

  // ✅ Save individual setting
  Future<void> _saveSetting(String key, bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);

      // Agar main notification toggle change hua hai
      if (key == 'notifications_enabled') {
        await NotificationService.setNotificationsEnabled(value);
      }
    } catch (e) {
      print('Error saving setting: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // App Settings Section
            _buildSettingsSection(
              icon: Icons.settings_outlined,
              title: 'App Settings',
              subtitle: 'Customize your Bump Bond experience',
              children: [
                // No additional content needed for this section
              ],
            ),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSettingsSection(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: '',
              children: [
                _buildNotificationSwitch(
                  title: 'Daily Pregnancy Notifications',
                  subtitle: 'Get daily pregnancy tips and updates',
                  value: dailyReminders,
                  onChanged: (value) {
                    setState(() {
                      dailyReminders = value;
                    });
                    _saveSetting('notifications_enabled', value);
                  },
                ),
                _buildNotificationSwitch(
                  title: 'Chat Notifications',
                  subtitle: 'Baby chat message alerts',
                  value: chatNotifications,
                  onChanged: (value) {
                    setState(() {
                      chatNotifications = value;
                    });
                    _saveSetting('chat_notifications', value);
                  },
                ),
                _buildNotificationSwitch(
                  title: 'Milestone Alerts',
                  subtitle: 'Important pregnancy milestones',
                  value: milestoneAlerts,
                  onChanged: (value) {
                    setState(() {
                      milestoneAlerts = value;
                    });
                    _saveSetting('milestone_alerts', value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Privacy Section
            _buildSettingsSection(
              icon: Icons.shield_outlined,
              title: 'Privacy',
              subtitle: '',
              children: [
                _buildNotificationSwitch(
                  title: 'Data Sharing',
                  subtitle: 'Share data for improvements',
                  value: dataSharing,
                  onChanged: (value) {
                    setState(() {
                      dataSharing = value;
                    });
                    _saveSetting('data_sharing', value);
                  },
                ),
                _buildNotificationSwitch(
                  title: 'Analytics',
                  subtitle: 'Help improve the app',
                  value: analytics,
                  onChanged: (value) {
                    setState(() {
                      analytics = value;
                    });
                    _saveSetting('analytics', value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Help & Support Section
            _buildSettingsSection(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: '',
              children: [
                _buildHelpTile(
                  'FAQs',
                  'Frequently asked questions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FAQsScreen(),
                      ),
                    );
                  },
                ),
                _buildHelpTile(
                  'Contact Support',
                  'Get help from our team',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactSupportScreen(),
                      ),
                    );
                  },
                ),
                _buildHelpTile('App Version', 'v1.0.0', onTap: null),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(icon, color: const Color(0xFFB794F4), size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFFB794F4),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildHelpTile(String title, String subtitle, {Function()? onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (onTap != null)
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ✅ New FAQs Screen
class FAQsScreen extends StatefulWidget {
  @override
  State<FAQsScreen> createState() => _FAQsScreenState();
}

class _FAQsScreenState extends State<FAQsScreen> {
  final List<FAQItem> faqs = [
    FAQItem(
      question: 'How do I track my pregnancy week?',
      answer: 'The app automatically tracks your pregnancy week based on your due date. You can update your due date in the profile section.',
    ),
    FAQItem(
      question: 'What is the AI Baby Chat feature?',
      answer: 'AI Baby Chat allows you to have simulated conversations with your baby. Free users get 5 chats per day, while premium users get unlimited access.',
    ),
    FAQItem(
      question: 'How do I update my due date?',
      answer: 'Go to Profile → Edit Profile → Update Due Date. Your pregnancy timeline will automatically adjust.',
    ),
    FAQItem(
      question: 'What is included in the Free plan?',
      answer: 'Free plan includes basic pregnancy tracking, weekly updates, milestone tracking, educational resources, symptoms logging, 5 AI chats per day, and text-only love journal.',
    ),
    FAQItem(
      question: 'What are the benefits of Premium plan?',
      answer: 'Premium includes no ads, unlimited AI chat, weekly videos, personalized recommendations, voice/media love journal, custom meal plans, and priority support.',
    ),
    FAQItem(
      question: 'Can I share the app with my partner?',
      answer: 'Yes! The Pro plan includes partner sharing feature so both parents can track the pregnancy journey together.',
    ),
    FAQItem(
      question: 'How do I backup my data?',
      answer: 'Your data is automatically backed up to the cloud. You can enable/disable this in Privacy settings.',
    ),
    FAQItem(
      question: 'What support is included in Pro plan?',
      answer: 'Pro plan includes 1-year postpartum support, lactation support, and pediatrician support after delivery.',
    ),
    FAQItem(
      question: 'How do I cancel my subscription?',
      answer: 'You can cancel through Google Play Store or Apple App Store settings. Cancellation takes effect at the end of your billing cycle.',
    ),
    FAQItem(
      question: 'Is my data secure?',
      answer: 'Yes! We use encryption and follow strict privacy policies to protect your personal health information.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FAQs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return _buildFAQItem(faqs[index]);
        },
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          faq.question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ New Contact Support Screen
class ContactSupportScreen extends StatefulWidget {
  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Contact Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        const Text(
                          'Support Information',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSupportInfoItem(
                      Icons.email_outlined,
                      'Email',
                      'support@bumpbond.com',
                    ),
                    _buildSupportInfoItem(
                      Icons.phone_outlined,
                      'Phone',
                      '+91-XXXXX-XXXXX',
                    ),
                    _buildSupportInfoItem(
                      Icons.access_time_outlined,
                      'Response Time',
                      'Within 24 hours',
                    ),
                    _buildSupportInfoItem(
                      Icons.language_outlined,
                      'Website',
                      'www.bumpbond.com',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Form
            const Text(
              'Send us a message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Your Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.subject_outlined),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
              ),
              maxLines: 5,
              textAlignVertical: TextAlignVertical.top,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitSupportRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB794F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Send Message',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Quick Help Options
            const Text(
              'Quick Help',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            _buildQuickHelpOption(
              'Check FAQs',
              Icons.help_outline,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FAQsScreen(),
                  ),
                );
              },
            ),
            _buildQuickHelpOption(
              'Call Support',
              Icons.phone_outlined,
                  () {
                // TODO: Implement call functionality
                _showComingSoonSnackbar();
              },
            ),
            _buildQuickHelpOption(
              'Live Chat',
              Icons.chat_outlined,
                  () {
                // TODO: Implement live chat
                _showComingSoonSnackbar();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportInfoItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpOption(String title, IconData icon, Function() onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFB794F4)),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  void _submitSupportRequest() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // TODO: Implement actual support request submission
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Support request submitted successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear form
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
  }

  void _showComingSoonSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

// FAQ Item Model
class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}



// import 'package:flutter/material.dart';
// import 'package:bump_bond_flutter_app/services/notification_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class SettingsScreenFeture extends StatefulWidget {
//   const SettingsScreenFeture({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsScreenFeture> createState() => _SettingsScreenFetureState();
// }
//
// class _SettingsScreenFetureState extends State<SettingsScreenFeture> {
//   bool dailyReminders = true;
//   bool chatNotifications = true;
//   bool milestoneAlerts = true;
//   bool dataSharing = false;
//   bool analytics = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadNotificationSettings();
//   }
//
//   // ✅ Load notification settings from SharedPreferences
//   Future<void> _loadNotificationSettings() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         dailyReminders = prefs.getBool('notifications_enabled') ?? true;
//         chatNotifications = prefs.getBool('chat_notifications') ?? true;
//         milestoneAlerts = prefs.getBool('milestone_alerts') ?? true;
//         dataSharing = prefs.getBool('data_sharing') ?? false;
//         analytics = prefs.getBool('analytics') ?? true;
//       });
//     } catch (e) {
//       print('Error loading settings: $e');
//     }
//   }
//
//   // ✅ Save individual setting
//   Future<void> _saveSetting(String key, bool value) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool(key, value);
//
//       // Agar main notification toggle change hua hai
//       if (key == 'notifications_enabled') {
//         await NotificationService.setNotificationsEnabled(value);
//       }
//     } catch (e) {
//       print('Error saving setting: $e');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFB794F4),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Settings',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             const SizedBox(height: 24),
//
//             // App Settings Section
//             _buildSettingsSection(
//               icon: Icons.settings_outlined,
//               title: 'App Settings',
//               subtitle: 'Customize your Bump Bond experience',
//               children: [
//                 // No additional content needed for this section
//               ],
//             ),
//             const SizedBox(height: 24),
//
//             // Notifications Section
//             _buildSettingsSection(
//               icon: Icons.notifications_outlined,
//               title: 'Notifications',
//               subtitle: '',
//               children: [
//                 _buildNotificationSwitch(
//                   title: 'Daily Pregnancy Notifications',
//                   subtitle: 'Get daily pregnancy tips and updates',
//                   value: dailyReminders,
//                   onChanged: (value) {
//                     setState(() {
//                       dailyReminders = value;
//                     });
//                     _saveSetting('notifications_enabled', value);
//                   },
//                 ),
//                 _buildNotificationSwitch(
//                   title: 'Chat Notifications',
//                   subtitle: 'Baby chat message alerts',
//                   value: chatNotifications,
//                   onChanged: (value) {
//                     setState(() {
//                       chatNotifications = value;
//                     });
//                     _saveSetting('chat_notifications', value);
//                   },
//                 ),
//                 _buildNotificationSwitch(
//                   title: 'Milestone Alerts',
//                   subtitle: 'Important pregnancy milestones',
//                   value: milestoneAlerts,
//                   onChanged: (value) {
//                     setState(() {
//                       milestoneAlerts = value;
//                     });
//                     _saveSetting('milestone_alerts', value);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//
//             // Privacy Section
//             _buildSettingsSection(
//               icon: Icons.shield_outlined,
//               title: 'Privacy',
//               subtitle: '',
//               children: [
//                 _buildNotificationSwitch(
//                   title: 'Data Sharing',
//                   subtitle: 'Share data for improvements',
//                   value: dataSharing,
//                   onChanged: (value) {
//                     setState(() {
//                       dataSharing = value;
//                     });
//                     _saveSetting('data_sharing', value);
//                   },
//                 ),
//                 _buildNotificationSwitch(
//                   title: 'Analytics',
//                   subtitle: 'Help improve the app',
//                   value: analytics,
//                   onChanged: (value) {
//                     setState(() {
//                       analytics = value;
//                     });
//                     _saveSetting('analytics', value);
//                   },
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//
//             // Help & Support Section
//             _buildSettingsSection(
//               icon: Icons.help_outline,
//               title: 'Help & Support',
//               subtitle: '',
//               children: [
//                 _buildHelpTile('FAQs', 'Frequently asked questions'),
//                 _buildHelpTile('Contact support', 'Get help from our team'),
//                 _buildHelpTile('App version', 'v1.0.0'),
//               ],
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsSection({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required List<Widget> children,
//   }) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(20),
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
//           Row(
//             children: [
//               Icon(icon, color: const Color(0xFFB794F4), size: 24),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           if (subtitle.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//           const SizedBox(height: 16),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   Widget _buildNotificationSwitch({
//     required String title,
//     required String subtitle,
//     required bool value,
//     required Function(bool) onChanged,
//   }) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     subtitle,
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Switch(
//               value: value,
//               onChanged: onChanged,
//               activeColor: const Color(0xFFB794F4),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
//
//   Widget _buildHelpTile(String title, String subtitle) {
//     return Column(
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   subtitle,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//             Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//       ],
//     );
//   }
// }

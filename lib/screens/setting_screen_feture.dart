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
                _buildHelpTile('FAQs', 'Frequently asked questions'),
                _buildHelpTile('Contact support', 'Get help from our team'),
                _buildHelpTile('App version', 'v1.0.0'),
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

  Widget _buildHelpTile(String title, String subtitle) {
    return Column(
      children: [
        Row(
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
            Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}


// import 'package:flutter/material.dart';
//
//
// class SettingsScreenFeture extends StatefulWidget {
//   const SettingsScreenFeture({Key? key}) : super(key: key);
//
//   @override
//   State<SettingsScreenFeture> createState() => _SettingsScreenState();
// }
//
// class _SettingsScreenState extends State<SettingsScreenFeture> {
//   bool dailyReminders = true;
//   bool chatNotifications = true;
//   bool milestoneAlerts = false;
//   bool dataSharing = false;
//   bool analytics = true;
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
//             // App Settings Section
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Icon(Icons.settings_outlined,
//                       color: const Color(0xFFB794F4), size: 40),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'App Settings',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Customize your Womb Whispers experience',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Notifications Section
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.notifications_outlined,
//                           color: const Color(0xFFB794F4), size: 24),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Notifications',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Daily Reminders
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Daily reminders',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Get daily pregnancy tips',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Switch(
//                         value: dailyReminders,
//                         onChanged: (value) {
//                           setState(() {
//                             dailyReminders = value;
//                           });
//                         },
//                         activeColor: const Color(0xFFB794F4),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Chat Notifications
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Chat notifications',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Baby chat message alerts',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Switch(
//                         value: chatNotifications,
//                         onChanged: (value) {
//                           setState(() {
//                             chatNotifications = value;
//                           });
//                         },
//                         activeColor: const Color(0xFFB794F4),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Milestone Alerts
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Milestone alerts',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Important pregnancy milestones',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Switch(
//                         value: milestoneAlerts,
//                         onChanged: (value) {
//                           setState(() {
//                             milestoneAlerts = value;
//                           });
//                         },
//                         activeColor: const Color(0xFFB794F4),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Privacy Section
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.shield_outlined,
//                           color: const Color(0xFFB794F4), size: 24),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Privacy',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   // Data Sharing
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Data sharing',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Share data for improvements',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Switch(
//                         value: dataSharing,
//                         onChanged: (value) {
//                           setState(() {
//                             dataSharing = value;
//                           });
//                         },
//                         activeColor: const Color(0xFFB794F4),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                   // Analytics
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Analytics',
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.w500,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Help improve the app',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.grey[600],
//                             ),
//                           ),
//                         ],
//                       ),
//                       Switch(
//                         value: analytics,
//                         onChanged: (value) {
//                           setState(() {
//                             analytics = value;
//                           });
//                         },
//                         activeColor: const Color(0xFFB794F4),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//             // Help & Support Section
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 16),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.1),
//                     blurRadius: 10,
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.help_outline,
//                           color: const Color(0xFFB794F4), size: 24),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Help & Support',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 20),
//                   _buildHelpTile('FAQs', 'Frequently asked questions'),
//                   const SizedBox(height: 16),
//                   _buildHelpTile('Contact support', 'Get help from our team'),
//                   const SizedBox(height: 16),
//                   _buildHelpTile('App version', 'v1.0.0'),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHelpTile(String title, String subtitle) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               subtitle,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//         Text(
//           'View',
//           style: TextStyle(
//             fontSize: 12,
//             color: Colors.grey[400],
//           ),
//         ),
//       ],
//     );
//   }
// }
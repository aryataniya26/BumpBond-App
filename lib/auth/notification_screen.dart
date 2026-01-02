import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await NotificationService.getNotifications();

      data.sort((a, b) {
        final timeA = DateTime.parse(a['time'] ?? DateTime.now().toString());
        final timeB = DateTime.parse(b['time'] ?? DateTime.now().toString());
        return timeB.compareTo(timeA);
      });

      setState(() {
        notifications = data;
        isLoading = false;
      });
    } catch (e) {
      isLoading = false;
    }
  }

  Future<void> _clearAll() async {
    await NotificationService.clearAllNotifications();
    setState(() => notifications = []);
  }

  String _formatTime(String? timeStr) {
    if (timeStr == null) return 'Just now';
    final time = DateTime.parse(timeStr);
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM dd, yyyy').format(time);
  }

  String _getCategoryFromTitle(String title) {
    if (title.contains('💊')) return 'Medication';
    if (title.contains('Reminder')) return 'Reminder';
    if (title.contains('Test')) return 'Test';
    return 'General';
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Medication':
        return const Color(0xFFB794F4);
      case 'Reminder':
        return const Color(0xFFF59E0B);
      case 'Test':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  // 🔥 NEW: TAP PAR SCREEN OPEN KARNE KA LOGIC
  void _openScreen(String screen) {
    switch (screen) {
      case 'baby_chat':
        Navigator.pushNamed(context, '/baby_chat');
        break;
      case 'nutrition':
        Navigator.pushNamed(context, '/nutrition');
        break;
      case 'self_care':
        Navigator.pushNamed(context, '/self_care');
        break;
      case 'weekly_update':
        Navigator.pushNamed(context, '/weekly_update');
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFFB794F4),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification, index);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text('No notifications'));
  }

  Widget _buildNotificationCard(
      Map<String, dynamic> notification, int index) {
    final title = notification['title'] ?? '';
    final body = notification['body'] ?? '';
    final time = notification['time'];
    final screen = notification['screen']; // 🔥 IMPORTANT
    final category = _getCategoryFromTitle(title);
    final categoryColor = _getCategoryColor(category);

    return GestureDetector(
      // 🔥 TAP HANDLER ADDED
      onTap: () {
        if (screen != null && screen.isNotEmpty) {
          _openScreen(screen);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: categoryColor.withOpacity(0.2), width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.notifications, color: categoryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text(body),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(time),
                      style: TextStyle(color: categoryColor, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

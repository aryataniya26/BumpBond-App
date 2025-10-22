import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pregnancy_data.dart';
import 'baby_nickname_screen.dart';

class DueDateConfirmationScreen extends StatefulWidget {
  final PregnancyData pregnancyData;

  const DueDateConfirmationScreen({Key? key, required this.pregnancyData}) : super(key: key);

  @override
  State<DueDateConfirmationScreen> createState() => _DueDateConfirmationScreenState();
}

class _DueDateConfirmationScreenState extends State<DueDateConfirmationScreen> with SingleTickerProviderStateMixin {
  late PregnancyData data;
  bool loading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    data = widget.pregnancyData;
    _prepareData();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  void _prepareData() {
    if (data.dueDate == null && data.lastPeriodDate != null) {
      data.calculateDueDateFromLMP();
    }
    setState(() => loading = false);
  }

  String _progressHeadline() {
    final percent = (data.progress * 100).round();
    if (percent >= 90) return "Almost time — Baby is here soon!";
    if (percent >= 75) return "You're in the home stretch!";
    if (percent >= 50) return "Halfway there — great progress!";
    if (percent >= 25) return "Early days — exciting journey!";
    return "Congratulations — your journey has begun!";
  }

  Future<void> _onContinuePressed() async {
    await data.saveToPrefs();
    if (!mounted) return;

    // ✅ Navigate to Baby Nickname Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BabyNicknameScreen(pregnancyData: data),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final dueDateStr = data.dueDate != null
        ? DateFormat.yMMMMd().format(data.dueDate!)
        : "N/A";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text("Your Pregnancy Details"),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ✅ Animated Header
            FadeTransition(
              opacity: _animationController,
              child: Column(
                children: [
                  Text(
                    "Congratulations! 🎉",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _progressHeadline(),
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Main Info Card
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(
                    Icons.calendar_today_rounded,
                    "Estimated Due Date",
                    dueDateStr,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.timer,
                    "Days to Go",
                    "${data.daysRemaining} days",
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.pregnant_woman_rounded,
                    "You're Currently",
                    data.weeksPregnant,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.calendar_month,
                    "Current Month",
                    data.currentMonth,
                  ),
                  const Divider(height: 24),
                  _infoRow(
                    Icons.spa_rounded,
                    "Trimester",
                    data.trimester,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ✅ Baby Size Card
            _glassCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFB794F4).withOpacity(0.1),
                          const Color(0xFFFCE7F3).withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      data.babyEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Baby's Size",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Size of a ${data.babySize}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data.stageDescription,
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
            ),

            const SizedBox(height: 18),

            // ✅ Progress Card
            _glassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Pregnancy Progress",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        data.progressPercentage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB794F4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: data.progress),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: value,
                          minHeight: 12,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation(
                            Color(0xFFB794F4),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${data.currentWeekNumber} of 40 weeks completed",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ✅ Continue Button
            ElevatedButton(
              onPressed: _onContinuePressed,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: const Color(0xFFB794F4),
                elevation: 3,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB794F4), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

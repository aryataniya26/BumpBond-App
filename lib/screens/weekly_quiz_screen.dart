import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyQuizJourneyScreen extends StatefulWidget {
  const WeeklyQuizJourneyScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyQuizJourneyScreen> createState() => _WeeklyQuizJourneyScreenState();
}

class _WeeklyQuizJourneyScreenState extends State<WeeklyQuizJourneyScreen> {
  static const int totalWeeks = 42;
  DateTime? lastPeriodDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('lastPeriodDate');

    if (dateString != null) {
      lastPeriodDate = DateTime.tryParse(dateString);
    }

    setState(() => loading = false);
  }

  int get currentWeek {
    if (lastPeriodDate == null) return 0;
    final today = DateTime.now();
    final diff = today.difference(lastPeriodDate!).inDays;
    final week = (diff ~/ 7) + 1;
    if (week < 1) return 1;
    if (week > totalWeeks) return totalWeeks;
    return week;
  }

  Future<bool?> _isQuizCompleted(int weekNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quiz_completed_week_$weekNumber');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (lastPeriodDate == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Quiz Journey'),
          backgroundColor: const Color(0xFFB794F4),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 20),
              const Text(
                'No Pregnancy Date Set',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Please set your due date in the app settings first',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                label: const Text('Go Back', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB794F4),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = ((currentWeek) / totalWeeks * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Weekly Quiz Journey'),
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB794F4),
                  const Color(0xFF9F7AEA),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Week $currentWeek of $totalWeeks',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your pregnancy journey',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$progress%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (currentWeek) / totalWeeks,
                    minHeight: 10,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: totalWeeks,
              itemBuilder: (context, index) {
                final weekNum = index + 1;
                final isUnlocked = weekNum <= currentWeek;
                final isCurrent = weekNum == currentWeek;

                return FutureBuilder<bool?>(
                  future: _isQuizCompleted(weekNum),
                  builder: (context, snapshot) {
                    final isCompleted = snapshot.data ?? false;

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WeeklyQuizScreen(weekNumber: weekNum),
                        ),
                      ).then((_) => setState(() {}))
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: isCurrent
                              ? LinearGradient(
                            colors: [
                              const Color(0xFFB794F4).withOpacity(0.1),
                              const Color(0xFF9F7AEA).withOpacity(0.1),
                            ],
                          )
                              : null,
                          color: isCurrent
                              ? null
                              : (isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.08)
                              : Colors.white),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFFB794F4)
                                : (isCompleted
                                ? const Color(0xFF10B981)
                                : (isUnlocked ? Colors.grey[300]! : Colors.grey[200]!)),
                            width: isCurrent ? 2.5 : 1.5,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isCurrent
                              ? [
                            BoxShadow(
                              color: const Color(0xFFB794F4).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: isCompleted
                                    ? const LinearGradient(
                                  colors: [Color(0xFF10B981), Color(0xFF34D399)],
                                )
                                    : (isCurrent
                                    ? const LinearGradient(
                                  colors: [Color(0xFFB794F4), Color(0xFF9F7AEA)],
                                )
                                    : null),
                                color: isCompleted || isCurrent
                                    ? null
                                    : (isUnlocked ? Colors.grey[300] : Colors.grey[200]),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check_circle, color: Colors.white, size: 28)
                                    : Text(
                                  '$weekNum',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent
                                        ? Colors.white
                                        : (isUnlocked ? Colors.black87 : Colors.black45),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Week $weekNum Quiz',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked ? Colors.black87 : Colors.grey[500],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    isCompleted
                                        ? '✓ Completed'
                                        : (isCurrent
                                        ? '📚 Available Now'
                                        : (isUnlocked
                                        ? 'Tap to start'
                                        : '🔒 Locked')),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                          : (isCurrent
                                          ? const Color(0xFFB794F4)
                                          : Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isCompleted
                                  ? Icons.emoji_events
                                  : (isUnlocked ? Icons.arrow_forward_ios : Icons.lock),
                              size: 20,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isUnlocked ? const Color(0xFFB794F4) : Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyQuizScreen extends StatefulWidget {
  final int weekNumber;

  const WeeklyQuizScreen({Key? key, required this.weekNumber}) : super(key: key);

  @override
  State<WeeklyQuizScreen> createState() => _WeeklyQuizScreenState();
}

class _WeeklyQuizScreenState extends State<WeeklyQuizScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;
  bool showResult = false;
  late DateTime startTime;
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    questions = _getQuestionsForWeek(widget.weekNumber);
  }

  List<Map<String, dynamic>> _getQuestionsForWeek(int weekNumber) {
    // ✅ Week-specific questions
    final baseQuestions = [
      {
        'question': 'What is the most important nutrient during week $weekNumber?',
        'options': ['Folic Acid', 'Iron', 'Calcium', 'Vitamin D'],
        'correct': weekNumber <= 12 ? 0 : (weekNumber <= 27 ? 1 : 2),
        'explanation': 'Nutritional needs vary by trimester for optimal baby development.'
      },
      {
        'question': 'What major development occurs around week $weekNumber?',
        'options': ['Heart formation', 'Brain growth', 'Lung maturation', 'Bone strengthening'],
        'correct': weekNumber <= 8 ? 0 : (weekNumber <= 20 ? 1 : (weekNumber <= 35 ? 2 : 3)),
        'explanation': 'Each week brings unique milestones in fetal development.'
      },
      {
        'question': 'What symptom is common during week $weekNumber?',
        'options': ['Morning sickness', 'Fatigue', 'Backache', 'Swelling'],
        'correct': weekNumber <= 14 ? 0 : (weekNumber <= 27 ? 1 : (weekNumber <= 36 ? 2 : 3)),
        'explanation': 'Pregnancy symptoms evolve as your baby grows.'
      },
      {
        'question': 'What should you avoid eating during pregnancy?',
        'options': ['Cooked fish', 'Raw sushi', 'Cooked eggs', 'Pasteurized milk'],
        'correct': 1,
        'explanation': 'Raw or undercooked foods can contain harmful bacteria.'
      },
      {
        'question': 'How much water should you drink daily during pregnancy?',
        'options': ['4 cups', '6 cups', '8-10 cups', '12+ cups'],
        'correct': 2,
        'explanation': 'Staying hydrated is crucial for both mom and baby.'
      },
    ];

    return baseQuestions;
  }

  void nextQuestion() {
    if (selectedAnswer == questions[currentQuestion]['correct']) {
      score++;
    }

    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
      });
    } else {
      _saveCompletion();
      setState(() => showResult = true);
    }
  }

  Future<void> _saveCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('quiz_completed_week_${widget.weekNumber}', true);
    await prefs.setInt('quiz_score_week_${widget.weekNumber}', score);
  }

  void resetQuiz() {
    setState(() {
      currentQuestion = 0;
      selectedAnswer = null;
      score = 0;
      showResult = false;
      startTime = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showResult) {
      final timeTaken = DateTime.now().difference(startTime).inSeconds;
      final percentage = ((score / questions.length) * 100).toStringAsFixed(0);
      final passed = int.parse(percentage) >= 60;

      return Scaffold(
        backgroundColor: const Color(0xFFF7F7F7),
        appBar: AppBar(
          title: Text('Week ${widget.weekNumber} Result'),
          backgroundColor: const Color(0xFFB794F4),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: passed
                          ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                          : [const Color(0xFFB794F4), const Color(0xFF9F7AEA)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (passed ? const Color(0xFF10B981) : const Color(0xFFB794F4))
                            .withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    passed ? Icons.emoji_events : Icons.thumb_up,
                    color: Colors.white,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  passed ? 'Excellent Work!' : 'Good Effort!',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFB794F4).withOpacity(0.1),
                        const Color(0xFF9F7AEA).withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: passed ? const Color(0xFF10B981) : const Color(0xFFB794F4),
                        ),
                      ),
                      Text(
                        '$score out of ${questions.length} correct',
                        style: const TextStyle(fontSize: 16, color: Colors.black54),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Completed in ${timeTaken ~/ 60}:${(timeTaken % 60).toString().padLeft(2, '0')} min',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: resetQuiz,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB794F4),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Retake Quiz',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFFB794F4), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Back to Journey',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB794F4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final q = questions[currentQuestion];
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: Text('Week ${widget.weekNumber} Quiz'),
        backgroundColor: const Color(0xFFB794F4),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFB794F4),
                  const Color(0xFF9F7AEA),
                ],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${currentQuestion + 1}/${questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / questions.length,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      q['question'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(q['options'].length, (i) {
                    final selected = selectedAnswer == i;
                    return GestureDetector(
                      onTap: () => setState(() => selectedAnswer = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? LinearGradient(
                            colors: [
                              const Color(0xFFB794F4),
                              const Color(0xFF9F7AEA),
                            ],
                          )
                              : null,
                          color: selected ? null : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: selected ? const Color(0xFFB794F4) : Colors.grey[300]!,
                            width: selected ? 2 : 1.5,
                          ),
                          boxShadow: selected
                              ? [
                            BoxShadow(
                              color: const Color(0xFFB794F4).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: selected ? Colors.white : Colors.grey[200],
                                border: Border.all(
                                  color: selected ? Colors.white : Colors.grey[400]!,
                                  width: 2,
                                ),
                              ),
                              child: selected
                                  ? Icon(
                                Icons.check,
                                size: 18,
                                color: const Color(0xFFB794F4),
                              )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                q['options'][i],
                                style: TextStyle(
                                  color: selected ? Colors.white : Colors.black87,
                                  fontSize: 16,
                                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAnswer != null
                      ? const Color(0xFFB794F4)
                      : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: selectedAnswer != null ? 4 : 0,
                ),
                child: Text(
                  currentQuestion < questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                  style: TextStyle(
                    color: selectedAnswer != null ? Colors.white : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WeeklyQuizJourneyScreen extends StatefulWidget {
//   const WeeklyQuizJourneyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<WeeklyQuizJourneyScreen> createState() => _WeeklyQuizJourneyScreenState();
// }
//
// class _WeeklyQuizJourneyScreenState extends State<WeeklyQuizJourneyScreen> {
//   static const int totalWeeks = 42;
//   DateTime? pregnancyStartDate;
//   bool loading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }
//
//   Future<void> _loadData() async {
//     final prefs = await SharedPreferences.getInstance();
//     final dateString = prefs.getString('pregnancy_start_date');
//
//     if (dateString != null) {
//       pregnancyStartDate = DateTime.tryParse(dateString);
//     }
//
//     setState(() => loading = false);
//   }
//
//   Future<void> _setPregnancyDate() async {
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime.now(),
//     );
//
//     if (picked != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('pregnancy_start_date', picked.toIso8601String());
//       setState(() => pregnancyStartDate = picked);
//     }
//   }
//
//   int get currentWeek {
//     if (pregnancyStartDate == null) return 0;
//     final today = DateTime.now();
//     final diff = today.difference(pregnancyStartDate!).inDays;
//     final week = (diff ~/ 7) + 1;
//     if (week < 1) return 0;
//     if (week > totalWeeks) return totalWeeks;
//     return week;
//   }
//
//   Future<bool?> _isQuizCompleted(int weekNumber) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool('quiz_completed_week_$weekNumber');
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     if (pregnancyStartDate == null) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Pregnancy Weekly Quiz'),
//           backgroundColor: const Color(0xFF6366F1),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Text(
//                 'Set Your Pregnancy Start Date',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: _setPregnancyDate,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6366F1),
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                 ),
//                 child: const Text('Select Date', style: TextStyle(color: Colors.white)),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final progress = ((currentWeek) / totalWeeks * 100).toStringAsFixed(1);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Weekly Pregnancy Quiz Journey'),
//         backgroundColor: const Color(0xFF6366F1),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: _setPregnancyDate,
//             tooltip: 'Change Start Date',
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             color: const Color(0xFFF8F9FA),
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Week $currentWeek of $totalWeeks',
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 8),
//                 LinearProgressIndicator(
//                   value: (currentWeek) / totalWeeks,
//                   minHeight: 8,
//                   backgroundColor: Colors.grey[200],
//                   valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   '$progress% completed',
//                   style: const TextStyle(fontSize: 12, color: Colors.black54),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: totalWeeks,
//               itemBuilder: (context, index) {
//                 final weekNum = index + 1;
//                 final isUnlocked = weekNum <= currentWeek;
//
//                 return FutureBuilder<bool?>(
//                   future: _isQuizCompleted(weekNum),
//                   builder: (context, snapshot) {
//                     final isCompleted = snapshot.data ?? false;
//                     final isCurrent = weekNum == currentWeek;
//
//                     return GestureDetector(
//                       onTap: isUnlocked
//                           ? () => Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => WeeklyQuizScreen(weekNumber: weekNum),
//                         ),
//                       ).then((_) => setState(() {}))
//                           : null,
//                       child: Container(
//                         margin: const EdgeInsets.only(bottom: 10),
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: isCurrent
//                               ? const Color(0xFF6366F1).withOpacity(0.1)
//                               : (isCompleted
//                               ? const Color(0xFF10B981).withOpacity(0.08)
//                               : Colors.white),
//                           border: Border.all(
//                             color: isCurrent
//                                 ? const Color(0xFF6366F1)
//                                 : (isCompleted
//                                 ? const Color(0xFF10B981)
//                                 : (isUnlocked
//                                 ? Colors.grey[300]!
//                                 : Colors.grey[200]!)),
//                             width: isCurrent ? 2 : 1,
//                           ),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 50,
//                               height: 50,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: isCompleted
//                                     ? const Color(0xFF10B981)
//                                     : (isCurrent
//                                     ? const Color(0xFF6366F1)
//                                     : (isUnlocked
//                                     ? Colors.grey[300]
//                                     : Colors.grey[200])),
//                               ),
//                               child: Center(
//                                 child: Text(
//                                   'Wk\n$weekNum',
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.bold,
//                                     color: isCurrent || isCompleted
//                                         ? Colors.white
//                                         : Colors.black54,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     'Week $weekNum Quiz',
//                                     style: const TextStyle(
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     isCompleted ? 'Completed' : 'Pregnancy guidance quiz',
//                                     style: TextStyle(
//                                       fontSize: 12,
//                                       color: isCompleted
//                                           ? const Color(0xFF10B981)
//                                           : Colors.grey[600],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             Icon(
//                               isCompleted
//                                   ? Icons.check_circle
//                                   : (isUnlocked
//                                   ? Icons.arrow_forward_ios
//                                   : Icons.lock),
//                               size: 18,
//                               color: isCompleted
//                                   ? const Color(0xFF10B981)
//                                   : (isUnlocked
//                                   ? const Color(0xFF6366F1)
//                                   : Colors.grey),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class WeeklyQuizScreen extends StatefulWidget {
//   final int weekNumber;
//
//   const WeeklyQuizScreen({Key? key, required this.weekNumber}) : super(key: key);
//
//   @override
//   State<WeeklyQuizScreen> createState() => _WeeklyQuizScreenState();
// }
//
// class _WeeklyQuizScreenState extends State<WeeklyQuizScreen> {
//   int currentQuestion = 0;
//   int? selectedAnswer;
//   int score = 0;
//   bool showResult = false;
//   late DateTime startTime;
//   late List<Map<String, dynamic>> questions;
//
//   @override
//   void initState() {
//     super.initState();
//     startTime = DateTime.now();
//     questions = _getQuestionsForWeek(widget.weekNumber);
//   }
//
//   List<Map<String, dynamic>> _getQuestionsForWeek(int weekNumber) {
//     return [
//       {
//         'question': 'Week $weekNumber: What major development occurs this week?',
//         'options': [
//           'Brain development',
//           'Heartbeat begins',
//           'Limbs formation',
//           'Lung maturation'
//         ],
//         'correct': (weekNumber % 4),
//         'explanation': 'Each week brings unique changes in fetal growth.'
//       },
//       {
//         'question': 'What nutrient is most important in week $weekNumber?',
//         'options': ['Iron', 'Calcium', 'Folic acid', 'Vitamin D'],
//         'correct': weekNumber % 4,
//         'explanation': 'Nutrients vary based on the stage of pregnancy.'
//       },
//     ];
//   }
//
//   void nextQuestion() {
//     if (selectedAnswer == questions[currentQuestion]['correct']) {
//       score++;
//     }
//
//     if (currentQuestion < questions.length - 1) {
//       setState(() {
//         currentQuestion++;
//         selectedAnswer = null;
//       });
//     } else {
//       _saveCompletion();
//       setState(() => showResult = true);
//     }
//   }
//
//   Future<void> _saveCompletion() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('quiz_completed_week_${widget.weekNumber}', true);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (showResult) {
//       final percentage = ((score / questions.length) * 100).toStringAsFixed(0);
//       return Scaffold(
//         appBar: AppBar(
//           title: Text('Week ${widget.weekNumber} Result'),
//           backgroundColor: const Color(0xFF6366F1),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('Your Score: $percentage%',
//                     style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => Navigator.pop(context),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFF6366F1),
//                     padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
//                   ),
//                   child: const Text('Back to Journey', style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     final q = questions[currentQuestion];
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Week ${widget.weekNumber} Quiz (${currentQuestion + 1}/${questions.length})'),
//         backgroundColor: const Color(0xFF6366F1),
//       ),
//       body: Column(
//         children: [
//           LinearProgressIndicator(
//             value: (currentQuestion + 1) / questions.length,
//             backgroundColor: Colors.grey[200],
//             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
//             minHeight: 8,
//           ),
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 Text(q['question'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 20),
//                 ...List.generate(q['options'].length, (i) {
//                   final selected = selectedAnswer == i;
//                   return GestureDetector(
//                     onTap: () => setState(() => selectedAnswer = i),
//                     child: Container(
//                       margin: const EdgeInsets.only(bottom: 12),
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: selected ? const Color(0xFF6366F1) : Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         border: Border.all(color: selected ? const Color(0xFF6366F1) : Colors.grey[300]!),
//                       ),
//                       child: Text(q['options'][i],
//                           style: TextStyle(
//                             color: selected ? Colors.white : Colors.black,
//                             fontSize: 16,
//                           )),
//                     ),
//                   );
//                 })
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: selectedAnswer != null ? nextQuestion : null,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6366F1),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                 ),
//                 child: Text(
//                   currentQuestion < questions.length - 1 ? 'Next' : 'Finish',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                 ),
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
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class DailyQuizJourneyScreen extends StatefulWidget {
// //   const DailyQuizJourneyScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<DailyQuizJourneyScreen> createState() => _DailyQuizJourneyScreenState();
// // }
// //
// // class _DailyQuizJourneyScreenState extends State<DailyQuizJourneyScreen> {
// //   static const int daysInJourney = 270;
// //   DateTime? pregnancyStartDate;
// //   bool loading = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData();
// //   }
// //
// //   Future<void> _loadData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final dateString = prefs.getString('pregnancy_start_date');
// //
// //     if (dateString != null) {
// //       pregnancyStartDate = DateTime.tryParse(dateString);
// //     }
// //
// //     setState(() {
// //       loading = false;
// //     });
// //   }
// //
// //   Future<void> _setPregnancyDate() async {
// //     final picked = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.now(),
// //       firstDate: DateTime(2020),
// //       lastDate: DateTime.now(),
// //     );
// //
// //     if (picked != null) {
// //       final prefs = await SharedPreferences.getInstance();
// //       await prefs.setString('pregnancy_start_date', picked.toIso8601String());
// //       setState(() {
// //         pregnancyStartDate = picked;
// //       });
// //     }
// //   }
// //
// //   int get todayDayIndex {
// //     if (pregnancyStartDate == null) return -1;
// //     final today = DateTime.now();
// //     final diff = today.difference(_stripTime(pregnancyStartDate!)).inDays;
// //     if (diff < 0) return -1;
// //     if (diff >= daysInJourney) return daysInJourney - 1;
// //     return diff;
// //   }
// //
// //   DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);
// //
// //   bool _isUnlocked(int dayIndex) => dayIndex <= todayDayIndex;
// //
// //   bool _isToday(int dayIndex) => dayIndex == todayDayIndex;
// //
// //   Future<bool?> _isQuizCompleted(int dayNumber) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     return prefs.getBool('quiz_completed_day_$dayNumber');
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (loading) {
// //       return const Scaffold(
// //         body: Center(child: CircularProgressIndicator()),
// //       );
// //     }
// //
// //     if (pregnancyStartDate == null) {
// //       return Scaffold(
// //         appBar: AppBar(
// //           title: const Text('Pregnancy Quiz Journey'),
// //           backgroundColor: const Color(0xFF6366F1),
// //         ),
// //         body: Center(
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Text(
// //                 'Set Your Pregnancy Start Date',
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //               ),
// //               const SizedBox(height: 20),
// //               ElevatedButton(
// //                 onPressed: _setPregnancyDate,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF6366F1),
// //                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
// //                 ),
// //                 child: const Text('Select Date', style: TextStyle(color: Colors.white)),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }
// //
// //     final progress = ((todayDayIndex + 1) / daysInJourney * 100).toStringAsFixed(1);
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Daily Quiz Journey'),
// //         backgroundColor: const Color(0xFF6366F1),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.edit),
// //             onPressed: _setPregnancyDate,
// //             tooltip: 'Change Start Date',
// //           ),
// //         ],
// //       ),
// //       body: Column(
// //         children: [
// //           Container(
// //             width: double.infinity,
// //             color: const Color(0xFFF8F9FA),
// //             padding: const EdgeInsets.all(16),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Day ${todayDayIndex + 1} of $daysInJourney',
// //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 LinearProgressIndicator(
// //                   value: (todayDayIndex + 1) / daysInJourney,
// //                   minHeight: 8,
// //                   backgroundColor: Colors.grey[200],
// //                   valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 Text(
// //                   '$progress% completed',
// //                   style: const TextStyle(fontSize: 12, color: Colors.black54),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Expanded(
// //             child: ListView.builder(
// //               padding: const EdgeInsets.all(12),
// //               itemCount: daysInJourney,
// //               itemBuilder: (context, index) {
// //                 final dayNum = index + 1;
// //                 final isUnlocked = _isUnlocked(index);
// //                 final isToday = _isToday(index);
// //
// //                 return FutureBuilder<bool?>(
// //                   future: _isQuizCompleted(dayNum),
// //                   builder: (context, snapshot) {
// //                     final isCompleted = snapshot.data ?? false;
// //
// //                     return GestureDetector(
// //                       onTap: isUnlocked
// //                           ? () => Navigator.push(
// //                         context,
// //                         MaterialPageRoute(
// //                           builder: (_) => DailyQuizScreen(
// //                             dayNumber: dayNum,
// //                             dayIndex: index,
// //                           ),
// //                         ),
// //                       ).then((_) => setState(() {}))
// //                           : null,
// //                       child: Container(
// //                         margin: const EdgeInsets.only(bottom: 10),
// //                         padding: const EdgeInsets.all(16),
// //                         decoration: BoxDecoration(
// //                           color: isToday
// //                               ? const Color(0xFF6366F1).withOpacity(0.1)
// //                               : (isCompleted
// //                               ? const Color(0xFF10B981).withOpacity(0.08)
// //                               : Colors.white),
// //                           border: Border.all(
// //                             color: isToday
// //                                 ? const Color(0xFF6366F1)
// //                                 : (isCompleted
// //                                 ? const Color(0xFF10B981)
// //                                 : (isUnlocked
// //                                 ? Colors.grey[300]!
// //                                 : Colors.grey[200]!)),
// //                             width: isToday ? 2 : 1,
// //                           ),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Row(
// //                           children: [
// //                             Container(
// //                               width: 50,
// //                               height: 50,
// //                               decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 color: isCompleted
// //                                     ? const Color(0xFF10B981)
// //                                     : (isToday
// //                                     ? const Color(0xFF6366F1)
// //                                     : (isUnlocked
// //                                     ? Colors.grey[300]
// //                                     : Colors.grey[200])),
// //                               ),
// //                               child: Center(
// //                                 child: isCompleted
// //                                     ? const Icon(Icons.check,
// //                                     color: Colors.white, size: 24)
// //                                     : Text(
// //                                   'Day\n$dayNum',
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                     fontSize: 11,
// //                                     fontWeight: FontWeight.bold,
// //                                     color: isToday
// //                                         ? Colors.white
// //                                         : Colors.black54,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                             const SizedBox(width: 16),
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     'Day $dayNum Quiz',
// //                                     style: const TextStyle(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                   const SizedBox(height: 4),
// //                                   Text(
// //                                     isCompleted ? 'Completed' : 'Pregnancy guidance',
// //                                     style: TextStyle(
// //                                       fontSize: 12,
// //                                       color: isCompleted
// //                                           ? const Color(0xFF10B981)
// //                                           : Colors.grey[600],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                             Icon(
// //                               isCompleted
// //                                   ? Icons.check_circle
// //                                   : (isUnlocked
// //                                   ? Icons.arrow_forward_ios
// //                                   : Icons.lock),
// //                               size: 18,
// //                               color: isCompleted
// //                                   ? const Color(0xFF10B981)
// //                                   : (isUnlocked
// //                                   ? const Color(0xFF6366F1)
// //                                   : Colors.grey),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 );
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class DailyQuizScreen extends StatefulWidget {
// //   final int dayNumber;
// //   final int dayIndex;
// //
// //   const DailyQuizScreen({
// //     Key? key,
// //     required this.dayNumber,
// //     required this.dayIndex,
// //   }) : super(key: key);
// //
// //   @override
// //   State<DailyQuizScreen> createState() => _DailyQuizScreenState();
// // }
// //
// // class _DailyQuizScreenState extends State<DailyQuizScreen> {
// //   int currentQuestion = 0;
// //   int? selectedAnswer;
// //   int score = 0;
// //   bool showResult = false;
// //   bool hasCompleted = false;
// //   late DateTime startTime;
// //   late List<Map<String, dynamic>> questions;
// //   late int savedScore;
// //   late int savedTime;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     startTime = DateTime.now();
// //     questions = _getQuestionsForDay(widget.dayIndex);
// //     _loadQuizData();
// //   }
// //
// //   Future<void> _loadQuizData() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final key = 'quiz_completed_day_${widget.dayNumber}';
// //     final scoreKey = 'quiz_score_day_${widget.dayNumber}';
// //     final timeKey = 'quiz_time_day_${widget.dayNumber}';
// //
// //     final completed = prefs.getBool(key) ?? false;
// //     final savedScoreVal = prefs.getInt(scoreKey) ?? 0;
// //     final savedTimeVal = prefs.getInt(timeKey) ?? 0;
// //
// //     setState(() {
// //       hasCompleted = completed;
// //       savedScore = savedScoreVal;
// //       savedTime = savedTimeVal;
// //     });
// //   }
// //
// //   Future<void> _saveCompletion() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final key = 'quiz_completed_day_${widget.dayNumber}';
// //     final scoreKey = 'quiz_score_day_${widget.dayNumber}';
// //     final timeKey = 'quiz_time_day_${widget.dayNumber}';
// //     final timeTaken = DateTime.now().difference(startTime).inSeconds;
// //
// //     await prefs.setBool(key, true);
// //     await prefs.setInt(scoreKey, score);
// //     await prefs.setInt(timeKey, timeTaken);
// //   }
// //
// //   List<Map<String, dynamic>> _getQuestionsForDay(int dayIndex) {
// //     final pregnancyWeek = (dayIndex ~/ 7) + 1;
// //
// //     return [
// //       {
// //         'question': 'Week $pregnancyWeek: Which nutrient is crucial for fetal brain development?',
// //         'options': ['Calcium', 'Omega-3 fatty acids', 'Vitamin C', 'Iron'],
// //         'correct': 1,
// //         'explanation': 'Omega-3 fatty acids are essential for fetal brain and eye development.'
// //       },
// //       {
// //         'question': 'How many extra calories should you consume daily during pregnancy?',
// //         'options': ['100 calories', '200 calories', '300 calories', '500 calories'],
// //         'correct': 2,
// //         'explanation': 'An additional 300 calories daily supports fetal development.'
// //       },
// //       {
// //         'question': 'What is the recommended daily folic acid intake during pregnancy?',
// //         'options': ['200 mcg', '300 mcg', '400 mcg', '600 mcg'],
// //         'correct': 2,
// //         'explanation': 'CDC recommends 400 mcg daily to prevent neural tube defects.'
// //       },
// //       {
// //         'question': 'Which food should be avoided during pregnancy?',
// //         'options': ['Cooked chicken', 'Raw eggs', 'Yogurt', 'Cooked fish'],
// //         'correct': 1,
// //         'explanation': 'Raw eggs can contain salmonella and should be avoided.'
// //       },
// //       {
// //         'question': 'What is the safe amount of caffeine during pregnancy?',
// //         'options': ['No limit', 'Less than 100 mg', 'Less than 200 mg', 'Less than 400 mg'],
// //         'correct': 2,
// //         'explanation': 'Limit caffeine to less than 200 mg per day.'
// //       },
// //       {
// //         'question': 'How much weight gain is typical in the first trimester?',
// //         'options': ['0-2 lbs', '1-5 lbs', '10-15 lbs', '20-25 lbs'],
// //         'correct': 1,
// //         'explanation': 'Most women gain only 1-5 pounds in the first trimester.'
// //       },
// //       {
// //         'question': 'Which mineral helps prevent leg cramps during pregnancy?',
// //         'options': ['Potassium', 'Magnesium', 'Zinc', 'Copper'],
// //         'correct': 1,
// //         'explanation': 'Magnesium helps reduce muscle cramps and is important for fetal development.'
// //       },
// //       {
// //         'question': 'How many glasses of water should pregnant women drink daily?',
// //         'options': ['6 glasses', '8 glasses', '10 glasses', '12 glasses'],
// //         'correct': 2,
// //         'explanation': 'Pregnant women should drink about 10 cups (80 oz) of water daily.'
// //       },
// //       {
// //         'question': 'What is recommended for managing morning sickness?',
// //         'options': [
// //           'Eat large meals',
// //           'Eat small, frequent meals',
// //           'Avoid eating before bed',
// //           'Drink lots of water'
// //         ],
// //         'correct': 1,
// //         'explanation': 'Small, frequent meals help manage nausea and stabilize blood sugar.'
// //       },
// //       {
// //         'question': 'Is prenatal exercise safe and recommended?',
// //         'options': [
// //           'No, avoid all exercise',
// //           'Yes, 150 minutes per week of moderate activity',
// //           'Only walking is safe',
// //           'Only after 20 weeks'
// //         ],
// //         'correct': 1,
// //         'explanation': 'Moderate exercise for 150 minutes per week is beneficial and safe.'
// //       },
// //     ];
// //   }
// //
// //   void selectAnswer(int index) {
// //     setState(() => selectedAnswer = index);
// //   }
// //
// //   void nextQuestion() {
// //     if (selectedAnswer == questions[currentQuestion]['correct']) {
// //       score++;
// //     }
// //
// //     if (currentQuestion < questions.length - 1) {
// //       setState(() {
// //         currentQuestion++;
// //         selectedAnswer = null;
// //       });
// //     } else {
// //       _saveCompletion();
// //       setState(() => showResult = true);
// //     }
// //   }
// //
// //   void resetQuiz() {
// //     setState(() {
// //       currentQuestion = 0;
// //       selectedAnswer = null;
// //       score = 0;
// //       showResult = false;
// //       startTime = DateTime.now();
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (showResult) {
// //       final timeTaken = DateTime.now().difference(startTime).inSeconds;
// //       final percentage = ((score / questions.length) * 100).toStringAsFixed(0);
// //       final passed = int.parse(percentage) >= 70;
// //
// //       return Scaffold(
// //         appBar: AppBar(
// //           title: Text('Day ${widget.dayNumber} Result'),
// //           backgroundColor: const Color(0xFF6366F1),
// //         ),
// //         body: Center(
// //           child: Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: SingleChildScrollView(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   Container(
// //                     width: 120,
// //                     height: 120,
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: passed
// //                             ? [const Color(0xFF10B981), const Color(0xFF34D399)]
// //                             : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
// //                       ),
// //                       shape: BoxShape.circle,
// //                     ),
// //                     child: Icon(
// //                       passed ? Icons.emoji_events : Icons.check_circle,
// //                       color: Colors.white,
// //                       size: 60,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   Text(
// //                     passed ? 'Excellent!' : 'Good Effort!',
// //                     style: const TextStyle(
// //                       fontSize: 28,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Text(
// //                     'Your Score: $percentage%',
// //                     style: const TextStyle(
// //                       fontSize: 36,
// //                       fontWeight: FontWeight.bold,
// //                       color: Color(0xFF6366F1),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     '$score out of ${questions.length} correct',
// //                     style: const TextStyle(fontSize: 16, color: Colors.black54),
// //                   ),
// //                   const SizedBox(height: 8),
// //                   Text(
// //                     'Time: ${timeTaken ~/ 60} min ${timeTaken % 60} sec',
// //                     style: const TextStyle(fontSize: 14, color: Colors.grey),
// //                   ),
// //                   const SizedBox(height: 32),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: resetQuiz,
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: const Color(0xFF6366F1),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                       ),
// //                       child: const Text(
// //                         'Retake Quiz',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 12),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton(
// //                       onPressed: () => Navigator.pop(context),
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: Colors.grey[300],
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                       ),
// //                       child: const Text(
// //                         'Back to Journey',
// //                         style: TextStyle(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ),
// //       );
// //     }
// //
// //     final question = questions[currentQuestion];
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(
// //           'Day ${widget.dayNumber} (${currentQuestion + 1}/${questions.length})',
// //         ),
// //         backgroundColor: const Color(0xFF6366F1),
// //       ),
// //       body: Column(
// //         children: [
// //           LinearProgressIndicator(
// //             value: (currentQuestion + 1) / questions.length,
// //             backgroundColor: Colors.grey[200],
// //             valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
// //             minHeight: 8,
// //           ),
// //           Expanded(
// //             child: SingleChildScrollView(
// //               padding: const EdgeInsets.all(20),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     question['question'],
// //                     style: const TextStyle(
// //                       fontSize: 20,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   ...List.generate(question['options'].length, (index) {
// //                     final isSelected = selectedAnswer == index;
// //                     return GestureDetector(
// //                       onTap: () => selectAnswer(index),
// //                       child: Container(
// //                         margin: const EdgeInsets.only(bottom: 12),
// //                         padding: const EdgeInsets.all(16),
// //                         decoration: BoxDecoration(
// //                           color: isSelected ? const Color(0xFF6366F1) : Colors.white,
// //                           border: Border.all(
// //                             color: isSelected
// //                                 ? const Color(0xFF6366F1)
// //                                 : Colors.grey[300]!,
// //                             width: 2,
// //                           ),
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                         child: Text(
// //                           question['options'][index],
// //                           style: TextStyle(
// //                             fontSize: 16,
// //                             color: isSelected ? Colors.white : Colors.black,
// //                           ),
// //                         ),
// //                       ),
// //                     );
// //                   }),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           Padding(
// //             padding: const EdgeInsets.all(20),
// //             child: SizedBox(
// //               width: double.infinity,
// //               child: ElevatedButton(
// //                 onPressed: selectedAnswer != null ? nextQuestion : null,
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF6366F1),
// //                   padding: const EdgeInsets.symmetric(vertical: 14),
// //                 ),
// //                 child: Text(
// //                   currentQuestion < questions.length - 1 ? 'Next' : 'Finish',
// //                   style: const TextStyle(
// //                     fontSize: 16,
// //                     fontWeight: FontWeight.bold,
// //                     color: Colors.white,
// //                   ),
// //                 ),
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

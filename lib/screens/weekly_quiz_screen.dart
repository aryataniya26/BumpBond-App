import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyQuizJourneyScreen extends StatefulWidget {
  const DailyQuizJourneyScreen({Key? key}) : super(key: key);

  @override
  State<DailyQuizJourneyScreen> createState() => _DailyQuizJourneyScreenState();
}

class _DailyQuizJourneyScreenState extends State<DailyQuizJourneyScreen> {
  static const int daysInJourney = 270;
  DateTime? pregnancyStartDate;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('pregnancy_start_date');

    if (dateString != null) {
      pregnancyStartDate = DateTime.tryParse(dateString);
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> _setPregnancyDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pregnancy_start_date', picked.toIso8601String());
      setState(() {
        pregnancyStartDate = picked;
      });
    }
  }

  int get todayDayIndex {
    if (pregnancyStartDate == null) return -1;
    final today = DateTime.now();
    final diff = today.difference(_stripTime(pregnancyStartDate!)).inDays;
    if (diff < 0) return -1;
    if (diff >= daysInJourney) return daysInJourney - 1;
    return diff;
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _isUnlocked(int dayIndex) => dayIndex <= todayDayIndex;

  bool _isToday(int dayIndex) => dayIndex == todayDayIndex;

  Future<bool?> _isQuizCompleted(int dayNumber) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('quiz_completed_day_$dayNumber');
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (pregnancyStartDate == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pregnancy Quiz Journey'),
          backgroundColor: const Color(0xFF6366F1),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Set Your Pregnancy Start Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _setPregnancyDate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('Select Date', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    final progress = ((todayDayIndex + 1) / daysInJourney * 100).toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Quiz Journey'),
        backgroundColor: const Color(0xFF6366F1),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _setPregnancyDate,
            tooltip: 'Change Start Date',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: const Color(0xFFF8F9FA),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day ${todayDayIndex + 1} of $daysInJourney',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (todayDayIndex + 1) / daysInJourney,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                ),
                const SizedBox(height: 8),
                Text(
                  '$progress% completed',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: daysInJourney,
              itemBuilder: (context, index) {
                final dayNum = index + 1;
                final isUnlocked = _isUnlocked(index);
                final isToday = _isToday(index);

                return FutureBuilder<bool?>(
                  future: _isQuizCompleted(dayNum),
                  builder: (context, snapshot) {
                    final isCompleted = snapshot.data ?? false;

                    return GestureDetector(
                      onTap: isUnlocked
                          ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DailyQuizScreen(
                            dayNumber: dayNum,
                            dayIndex: index,
                          ),
                        ),
                      ).then((_) => setState(() {}))
                          : null,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isToday
                              ? const Color(0xFF6366F1).withOpacity(0.1)
                              : (isCompleted
                              ? const Color(0xFF10B981).withOpacity(0.08)
                              : Colors.white),
                          border: Border.all(
                            color: isToday
                                ? const Color(0xFF6366F1)
                                : (isCompleted
                                ? const Color(0xFF10B981)
                                : (isUnlocked
                                ? Colors.grey[300]!
                                : Colors.grey[200]!)),
                            width: isToday ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? const Color(0xFF10B981)
                                    : (isToday
                                    ? const Color(0xFF6366F1)
                                    : (isUnlocked
                                    ? Colors.grey[300]
                                    : Colors.grey[200])),
                              ),
                              child: Center(
                                child: isCompleted
                                    ? const Icon(Icons.check,
                                    color: Colors.white, size: 24)
                                    : Text(
                                  'Day\n$dayNum',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isToday
                                        ? Colors.white
                                        : Colors.black54,
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
                                    'Day $dayNum Quiz',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isCompleted ? 'Completed' : 'Pregnancy guidance',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isCompleted
                                          ? const Color(0xFF10B981)
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isCompleted
                                  ? Icons.check_circle
                                  : (isUnlocked
                                  ? Icons.arrow_forward_ios
                                  : Icons.lock),
                              size: 18,
                              color: isCompleted
                                  ? const Color(0xFF10B981)
                                  : (isUnlocked
                                  ? const Color(0xFF6366F1)
                                  : Colors.grey),
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

class DailyQuizScreen extends StatefulWidget {
  final int dayNumber;
  final int dayIndex;

  const DailyQuizScreen({
    Key? key,
    required this.dayNumber,
    required this.dayIndex,
  }) : super(key: key);

  @override
  State<DailyQuizScreen> createState() => _DailyQuizScreenState();
}

class _DailyQuizScreenState extends State<DailyQuizScreen> {
  int currentQuestion = 0;
  int? selectedAnswer;
  int score = 0;
  bool showResult = false;
  bool hasCompleted = false;
  late DateTime startTime;
  late List<Map<String, dynamic>> questions;
  late int savedScore;
  late int savedTime;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    questions = _getQuestionsForDay(widget.dayIndex);
    _loadQuizData();
  }

  Future<void> _loadQuizData() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_completed_day_${widget.dayNumber}';
    final scoreKey = 'quiz_score_day_${widget.dayNumber}';
    final timeKey = 'quiz_time_day_${widget.dayNumber}';

    final completed = prefs.getBool(key) ?? false;
    final savedScoreVal = prefs.getInt(scoreKey) ?? 0;
    final savedTimeVal = prefs.getInt(timeKey) ?? 0;

    setState(() {
      hasCompleted = completed;
      savedScore = savedScoreVal;
      savedTime = savedTimeVal;
    });
  }

  Future<void> _saveCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'quiz_completed_day_${widget.dayNumber}';
    final scoreKey = 'quiz_score_day_${widget.dayNumber}';
    final timeKey = 'quiz_time_day_${widget.dayNumber}';
    final timeTaken = DateTime.now().difference(startTime).inSeconds;

    await prefs.setBool(key, true);
    await prefs.setInt(scoreKey, score);
    await prefs.setInt(timeKey, timeTaken);
  }

  List<Map<String, dynamic>> _getQuestionsForDay(int dayIndex) {
    final pregnancyWeek = (dayIndex ~/ 7) + 1;

    return [
      {
        'question': 'Week $pregnancyWeek: Which nutrient is crucial for fetal brain development?',
        'options': ['Calcium', 'Omega-3 fatty acids', 'Vitamin C', 'Iron'],
        'correct': 1,
        'explanation': 'Omega-3 fatty acids are essential for fetal brain and eye development.'
      },
      {
        'question': 'How many extra calories should you consume daily during pregnancy?',
        'options': ['100 calories', '200 calories', '300 calories', '500 calories'],
        'correct': 2,
        'explanation': 'An additional 300 calories daily supports fetal development.'
      },
      {
        'question': 'What is the recommended daily folic acid intake during pregnancy?',
        'options': ['200 mcg', '300 mcg', '400 mcg', '600 mcg'],
        'correct': 2,
        'explanation': 'CDC recommends 400 mcg daily to prevent neural tube defects.'
      },
      {
        'question': 'Which food should be avoided during pregnancy?',
        'options': ['Cooked chicken', 'Raw eggs', 'Yogurt', 'Cooked fish'],
        'correct': 1,
        'explanation': 'Raw eggs can contain salmonella and should be avoided.'
      },
      {
        'question': 'What is the safe amount of caffeine during pregnancy?',
        'options': ['No limit', 'Less than 100 mg', 'Less than 200 mg', 'Less than 400 mg'],
        'correct': 2,
        'explanation': 'Limit caffeine to less than 200 mg per day.'
      },
      {
        'question': 'How much weight gain is typical in the first trimester?',
        'options': ['0-2 lbs', '1-5 lbs', '10-15 lbs', '20-25 lbs'],
        'correct': 1,
        'explanation': 'Most women gain only 1-5 pounds in the first trimester.'
      },
      {
        'question': 'Which mineral helps prevent leg cramps during pregnancy?',
        'options': ['Potassium', 'Magnesium', 'Zinc', 'Copper'],
        'correct': 1,
        'explanation': 'Magnesium helps reduce muscle cramps and is important for fetal development.'
      },
      {
        'question': 'How many glasses of water should pregnant women drink daily?',
        'options': ['6 glasses', '8 glasses', '10 glasses', '12 glasses'],
        'correct': 2,
        'explanation': 'Pregnant women should drink about 10 cups (80 oz) of water daily.'
      },
      {
        'question': 'What is recommended for managing morning sickness?',
        'options': [
          'Eat large meals',
          'Eat small, frequent meals',
          'Avoid eating before bed',
          'Drink lots of water'
        ],
        'correct': 1,
        'explanation': 'Small, frequent meals help manage nausea and stabilize blood sugar.'
      },
      {
        'question': 'Is prenatal exercise safe and recommended?',
        'options': [
          'No, avoid all exercise',
          'Yes, 150 minutes per week of moderate activity',
          'Only walking is safe',
          'Only after 20 weeks'
        ],
        'correct': 1,
        'explanation': 'Moderate exercise for 150 minutes per week is beneficial and safe.'
      },
    ];
  }

  void selectAnswer(int index) {
    setState(() => selectedAnswer = index);
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
      final passed = int.parse(percentage) >= 70;

      return Scaffold(
        appBar: AppBar(
          title: Text('Day ${widget.dayNumber} Result'),
          backgroundColor: const Color(0xFF6366F1),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: passed
                            ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                            : [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      passed ? Icons.emoji_events : Icons.check_circle,
                      color: Colors.white,
                      size: 60,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    passed ? 'Excellent!' : 'Good Effort!',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your Score: $percentage%',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$score out of ${questions.length} correct',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Time: ${timeTaken ~/ 60} min ${timeTaken % 60} sec',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: resetQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'Back to Journey',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Day ${widget.dayNumber} (${currentQuestion + 1}/${questions.length})',
        ),
        backgroundColor: const Color(0xFF6366F1),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentQuestion + 1) / questions.length,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
            minHeight: 8,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question['question'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(question['options'].length, (index) {
                    final isSelected = selectedAnswer == index;
                    return GestureDetector(
                      onTap: () => selectAnswer(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question['options'][index],
                          style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAnswer != null ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  currentQuestion < questions.length - 1 ? 'Next' : 'Finish',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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



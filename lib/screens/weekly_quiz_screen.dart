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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshWeekCalculation();
  }
  void _refreshWeekCalculation() {
    setState(() {
    });
  }
  Future<void> _unlockQuizzesUpToCurrentWeek() async {
    final prefs = await SharedPreferences.getInstance();
    for (int week = 1; week <= currentWeek; week++) {
    }
  }
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = prefs.getString('lastPeriodDate');

    if (dateString != null) {
      lastPeriodDate = DateTime.tryParse(dateString);
    }

    if (lastPeriodDate != null) {
      print('Last period date: $lastPeriodDate');
      print('Current week calculated: $currentWeek');

      // Ensure all quizzes up to current week are accessible
      for (int week = 1; week <= currentWeek; week++) {
        // Add any additional unlocking logic here if needed
        print('Week $week should be unlocked');
      }
    }

    setState(() => loading = false);
  }

  int get currentWeek {
    if (lastPeriodDate == null) return 0;
    final today = DateTime.now();
    final diff = today.difference(lastPeriodDate!).inDays;
    final week = (diff ~/ 7) + 1;

    // Ensure week is within valid range
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
                final isPastWeek = weekNum < currentWeek;
                final isFutureWeek = weekNum > currentWeek;

                print('Week $weekNum: currentWeek=$currentWeek, unlocked=$isUnlocked');
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
  bool showCorrectAnswer = false;
  late DateTime startTime;
  late List<Map<String, dynamic>> questions;

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();
    questions = _getQuestionsForWeek(widget.weekNumber);
  }

  List<Map<String, dynamic>> _getQuestionsForWeek(int weekNumber) {
    // Get all questions for the specific week from the complete dataset
    final weekQuestions = _getAllQuestionsData()
        .where((q) => q['week'] == weekNumber)
        .toList();

    // If we have questions for this week, use them
    if (weekQuestions.isNotEmpty) {
      // Take up to 5 questions for the quiz
      return weekQuestions.take(5).toList();
    }

    // Fallback to general pregnancy questions if no week-specific questions
    return _getGeneralPregnancyQuestions();
  }

  // Complete dataset of 200 questions from your provided data
  List<Map<String, dynamic>> _getAllQuestionsData() {
    return [
      // Week 1 Questions
      {
        'week': 1,
        'question': 'What is happening during Week 1 of pregnancy?',
        'options': [
          'A) The baby\'s heart starts beating',
          'B) This is actually your menstrual period; you\'re not pregnant yet',
          'C) Implantation occurs',
          'D) The neural tube forms'
        ],
        'correct': 1,
        'explanation': 'Week 1 marks the beginning of your last menstrual period. Conception hasn\'t occurred yet, but this week is counted as part of the 40-week pregnancy timeline.'
      },
      {
        'week': 1,
        'question': 'How is pregnancy timing calculated?',
        'options': [
          'A) From the date of conception',
          'B) From the first day of your last menstrual period',
          'C) From the date of implantation',
          'D) From when the pregnancy test is positive'
        ],
        'correct': 1,
        'explanation': 'Pregnancy is calculated from the first day of your last menstrual period (LMP), meaning you\'re counted as \'pregnant\' even before conception occurs.'
      },
      {
        'week': 1,
        'question': 'What hormonal changes occur during Week 1?',
        'options': [
          'A) Estrogen levels spike dramatically',
          'B) Progesterone begins declining before period starts',
          'C) FSH (follicle-stimulating hormone) levels begin rising',
          'D) HCG is being produced'
        ],
        'correct': 2,
        'explanation': 'During Week 1, FSH levels begin rising to prepare the ovaries for ovulation. This marks the beginning of the menstrual cycle.'
      },
      {
        'week': 1,
        'question': 'Approximately how many eggs are in a woman\'s ovaries at the start of her menstrual cycle?',
        'options': [
          'A) 100-200 eggs',
          'B) 1-2 eggs',
          'C) About 400,000 eggs',
          'D) Millions of eggs'
        ],
        'correct': 2,
        'explanation': 'A woman is born with approximately 1-2 million eggs, and by puberty, this number has decreased to about 400,000 eggs in the ovaries.'
      },
      {
        'week': 1,
        'question': 'What is the average length of a menstrual cycle?',
        'options': [
          'A) 14 days',
          'B) 21 days',
          'C) 28 days',
          'D) 35 days'
        ],
        'correct': 2,
        'explanation': 'The average menstrual cycle is 28 days, though it can range from 21 to 35 days. Week 1-5 of pregnancy corresponds to the menstrual phase and follicular phase.'
      },

      // Week 2 Questions
      {
        'week': 2,
        'question': 'What typically happens during Week 2 of pregnancy?',
        'options': [
          'A) The baby\'s organs form',
          'B) Ovulation and potential fertilization occur',
          'C) Morning sickness begins',
          'D) The baby starts moving'
        ],
        'correct': 1,
        'explanation': 'Week 2 is when ovulation typically occurs. If the egg is fertilized during this time, conception happens, usually around the end of this week.'
      },
      {
        'week': 2,
        'question': 'Are you actually pregnant during Week 2?',
        'options': [
          'A) Yes, fully pregnant',
          'B) No, pregnancy hasn\'t started yet',
          'C) Only if conception occurs late in the week',
          'D) Yes, but the baby hasn\'t formed'
        ],
        'correct': 2,
        'explanation': 'Conception typically occurs around day 14 (end of week 2), so you\'re preparing for pregnancy but only become pregnant if fertilization occurs.'
      },
      {
        'week': 2,
        'question': 'What hormone surge triggers ovulation?',
        'options': [
          'A) Estrogen surge',
          'B) LH (luteinizing hormone) surge',
          'C) Progesterone surge',
          'D) HCG surge'
        ],
        'correct': 1,
        'explanation': 'A surge in LH (luteinizing hormone) triggers the release of the egg from the ovary, typically occurring around day 14 of the menstrual cycle.'
      },
      {
        'week': 2,
        'question': 'How long can sperm survive in the female reproductive tract?',
        'options': [
          'A) 12 hours',
          'B) 24 hours',
          'C) 3-5 days',
          'D) 1-2 weeks'
        ],
        'correct': 2,
        'explanation': 'Sperm can survive in the female reproductive tract for 3-5 days, which means conception can occur several days before or after ovulation.'
      },
      {
        'week': 2,
        'question': 'What is the fertile window during a 28-day menstrual cycle?',
        'options': [
          'A) Day 7-9',
          'B) Day 10-14',
          'C) Day 12-16',
          'D) Day 20-28'
        ],
        'correct': 2,
        'explanation': 'The fertile window typically spans 5 days before ovulation and the day of ovulation. In a 28-day cycle, this is usually around days 12-16.'
      },

      // Week 3 Questions
      {
        'week': 3,
        'question': 'What major event occurs during Week 3?',
        'options': [
          'A) The baby\'s heart starts beating',
          'B) Fertilization - sperm and egg unite',
          'C) The baby can hear sounds',
          'D) Fingers and toes form'
        ],
        'correct': 1,
        'explanation': 'During Week 3, fertilization occurs when the sperm and egg unite in the fallopian tube to form a zygote, which then begins dividing and traveling toward the uterus.'
      },
      {
        'week': 3,
        'question': 'What is the fertilized egg called immediately after conception?',
        'options': [
          'A) Embryo',
          'B) Fetus',
          'C) Zygote',
          'D) Blastocyst'
        ],
        'correct': 2,
        'explanation': 'The fertilized egg is called a zygote. It contains 46 chromosomes (23 from each parent) and begins dividing as it travels down the fallopian tube.'
      },
      {
        'week': 3,
        'question': 'How many chromosomes does a zygote contain?',
        'options': [
          'A) 23 chromosomes',
          'B) 46 chromosomes',
          'C) 92 chromosomes',
          'D) 138 chromosomes'
        ],
        'correct': 1,
        'explanation': 'A zygote contains 46 chromosomes - 23 from the mother\'s egg and 23 from the father\'s sperm. This determines the baby\'s genetic makeup.'
      },
      {
        'week': 3,
        'question': 'How long does it take for the zygote to reach the uterus?',
        'options': [
          'A) 1-2 days',
          'B) 3-4 days',
          'C) 5-6 days',
          'D) 7-8 days'
        ],
        'correct': 2,
        'explanation': 'The zygote travels through the fallopian tube dividing into a blastocyst, taking about 5-6 days to reach the uterus for implantation.'
      },
      {
        'week': 3,
        'question': 'During Week 3, the zygote undergoes rapid cell division. What is this process called?',
        'options': [
          'A) Mitosis',
          'B) Cleavage',
          'C) Differentiation',
          'D) Implantation'
        ],
        'correct': 1,
        'explanation': 'The rapid cell division of the zygote is called cleavage. By day 3-4, the zygote has divided into about 16-32 cells called a morula.'
      },

      // Week 4 Questions
      {
        'week': 4,
        'question': 'What important process occurs during Week 4?',
        'options': [
          'A) The baby\'s eyes open',
          'B) Implantation into the uterine lining',
          'C) The baby can hear your voice',
          'D) Fingernails develop'
        ],
        'correct': 1,
        'explanation': 'During Week 4, the blastocyst burrows into the uterine lining in a process called implantation. This is when pregnancy truly begins.'
      },
      {
        'week': 4,
        'question': 'How big is the developing baby at Week 4?',
        'options': [
          'A) Size of a grape',
          'B) Size of a lemon',
          'C) Tinier than a grain of rice',
          'D) Size of an apple'
        ],
        'correct': 2,
        'explanation': 'At Week 4, the developing baby (now a blastocyst) is tinier than a grain of rice, and cells are rapidly dividing to form various body systems.'
      },
      {
        'week': 4,
        'question': 'What does a positive pregnancy test detect?',
        'options': [
          'A) The baby\'s heartbeat',
          'B) HCG (Human Chorionic Gonadotropin) hormone',
          'C) The embryo\'s neural tube',
          'D) The baby\'s movement'
        ],
        'correct': 1,
        'explanation': 'A positive pregnancy test detects HCG hormone in blood or urine. HCG is produced after the blastocyst implants into the uterine lining.'
      },
      {
        'week': 4,
        'question': 'When can a pregnancy test typically detect HCG?',
        'options': [
          'A) At the moment of fertilization',
          'B) After implantation (around Week 4)',
          'C) At Week 6 of pregnancy',
          'D) At Week 8 of pregnancy'
        ],
        'correct': 1,
        'explanation': 'HCG is detectable in blood about 6-8 days after ovulation (around Week 4), and in urine about 12-14 days after ovulation for sensitive tests.'
      },
      {
        'week': 4,
        'question': 'What is forming inside the blastocyst during Week 4?',
        'options': [
          'A) The heart',
          'B) The brain',
          'C) Germ layers (future body systems)',
          'D) The limbs'
        ],
        'correct': 2,
        'explanation': 'During Week 4, the blastocyst organizes into germ layers - the ectoderm, mesoderm, and endoderm - which will form all body systems.'
      },

      // Week 5 Questions
      {
        'week': 5,
        'question': 'What begins to form during Week 5?',
        'options': [
          'A) Fingernails',
          'B) The neural tube (future brain and spinal cord)',
          'C) Teeth',
          'D) Hair'
        ],
        'correct': 1,
        'explanation': 'The neural tube begins forming during Week 5, which will eventually become the baby\'s central nervous system (brain and spinal cord).'
      },
      {
        'week': 5,
        'question': 'What hormone rises significantly during Week 5?',
        'options': [
          'A) Testosterone',
          'B) Insulin',
          'C) HCG (Human Chorionic Gonadotropin)',
          'D) Cortisol'
        ],
        'correct': 2,
        'explanation': 'HCG levels rise quickly during Week 5, signaling the ovaries to stop releasing eggs and produce more estrogen and progesterone to support the pregnancy.'
      },
      {
        'week': 5,
        'question': 'What are common symptoms mothers experience during Week 5?',
        'options': [
          'A) Baby\'s movements',
          'B) Chest pain',
          'C) Missed period and breast tenderness',
          'D) Heartburn'
        ],
        'correct': 2,
        'explanation': 'Common symptoms at Week 5 include a missed period, breast tenderness, fatigue, and possibly mild nausea as hormone levels surge.'
      },
      {
        'week': 5,
        'question': 'What is the role of progesterone during Week 5?',
        'options': [
          'A) To trigger baby\'s heartbeat',
          'B) To maintain the uterine lining and support early pregnancy',
          'C) To form the baby\'s bones',
          'D) To develop the baby\'s organs'
        ],
        'correct': 1,
        'explanation': 'Progesterone production increases during Week 5 to maintain the thick uterine lining (endometrium) and support the developing pregnancy.'
      },
      {
        'week': 5,
        'question': 'How large is the embryo at Week 5?',
        'options': [
          'A) Visible to the naked eye (about 1 mm)',
          'B) About the size of a sesame seed (2-3 mm)',
          'C) About the size of a pea (5 mm)',
          'D) About the size of a marble'
        ],
        'correct': 1,
        'explanation': 'At Week 5, the embryo is about 2-3 mm long, roughly the size of a sesame seed, though it\'s rapidly growing and developing.'
      },

      // Week 6 Questions
      {
        'week': 6,
        'question': 'What milestone occurs with the neural tube in Week 6?',
        'options': [
          'A) It opens',
          'B) It closes',
          'C) It splits into two',
          'D) It disappears'
        ],
        'correct': 1,
        'explanation': 'The neural tube closes during Week 6. This is crucial for proper brain and spinal cord development. The heart and other organs also start forming.'
      },
      {
        'week': 6,
        'question': 'What begins to appear during Week 6?',
        'options': [
          'A) Teeth',
          'B) Hair',
          'C) Small buds that will become arms',
          'D) Eyelashes'
        ],
        'correct': 2,
        'explanation': 'Small buds appear during Week 6 that will soon develop into arms. The baby\'s body also begins to take on a C-shaped curve.'
      },
      {
        'week': 6,
        'question': 'What is the importance of folic acid during Week 6?',
        'options': [
          'A) It increases baby\'s appetite',
          'B) It helps prevent neural tube defects',
          'C) It speeds up baby\'s growth',
          'D) It improves mother\'s energy'
        ],
        'correct': 1,
        'explanation': 'Folic acid is crucial during this period to help prevent neural tube defects like spina bifida. It\'s recommended that women take folic acid before and during early pregnancy.'
      },
      {
        'week': 6,
        'question': 'What can be seen on an ultrasound during Week 6?',
        'options': [
          'A) The baby\'s gender',
          'B) The baby\'s face',
          'C) A gestational sac and possibly a yolk sac',
          'D) The baby\'s heartbeat clearly'
        ],
        'correct': 2,
        'explanation': 'During Week 6, ultrasound may show a gestational sac and a yolk sac. The embryonic disc is visible but the baby is still very small.'
      },
      {
        'week': 6,
        'question': 'What is the size of the embryo at Week 6?',
        'options': [
          'A) About 1 mm',
          'B) About 4-5 mm (size of a lentil)',
          'C) About 1 cm',
          'D) About 2 cm'
        ],
        'correct': 1,
        'explanation': 'At Week 6, the embryo is about 4-5 mm long, roughly the size of a lentil, and growth is accelerating rapidly.'
      },

      // Week 7 Questions
      {
        'week': 7,
        'question': 'What is the main focus of development during Week 7?',
        'options': [
          'A) Digestive system',
          'B) Brain and face',
          'C) Limbs and fingers',
          'D) Reproductive organs'
        ],
        'correct': 1,
        'explanation': 'Week 7 focuses on brain and face development. Depressions that will become nostrils appear, and the retinas begin forming.'
      },
      {
        'week': 7,
        'question': 'What significant cardiovascular milestone occurs around Week 7?',
        'options': [
          'A) Blood vessels form',
          'B) The heart starts beating',
          'C) Blood type is determined',
          'D) The heart completes development'
        ],
        'correct': 1,
        'explanation': 'The heart begins beating around Week 7. The placenta is also burrowing into the uterine wall to access oxygen and nutrients.'
      },
      {
        'week': 7,
        'question': 'What appears on the baby\'s face during Week 7?',
        'options': [
          'A) Eyes',
          'B) Ears',
          'C) Eyes, ears, and nostril depressions',
          'D) Mouth and teeth'
        ],
        'correct': 2,
        'explanation': 'During Week 7, the baby\'s face is taking shape with eye regions forming, ear buds appearing, and depressions that will become nostrils visible.'
      },
      {
        'week': 7,
        'question': 'What is the heartbeat rate of the embryo around Week 7?',
        'options': [
          'A) 50-60 bpm',
          'B) 100-120 bpm',
          'C) 150-160 bpm',
          'D) 180-200 bpm'
        ],
        'correct': 1,
        'explanation': 'The embryo\'s heart begins beating around Week 7, initially at about 100-120 bpm, which is faster than an adult\'s resting heart rate.'
      },
      {
        'week': 7,
        'question': 'What maternal symptom typically peaks around Week 7?',
        'options': [
          'A) Weight gain',
          'B) Morning sickness and nausea',
          'C) Leg cramps',
          'D) Heartburn'
        ],
        'correct': 1,
        'explanation': 'Week 7 is when morning sickness typically peaks for many pregnant women due to rising HCG levels and hormonal changes.'
      },

      // Week 8 Questions
      {
        'week': 8,
        'question': 'Approximately how long is the baby at Week 8?',
        'options': [
          'A) 1/4 inch',
          'B) 1/2 inch (11-14 mm)',
          'C) 1 inch',
          'D) 2 inches'
        ],
        'correct': 1,
        'explanation': 'By Week 8, the baby is about 1/2 inch (11-14 millimeters) long from crown to rump. Fingers have begun forming.'
      },
      {
        'week': 8,
        'question': 'What happens to the limbs during Week 8?',
        'options': [
          'A) They fall off',
          'B) Leg buds take the shape of paddles',
          'C) They become fully functional',
          'D) They stop growing'
        ],
        'correct': 1,
        'explanation': 'During Week 8, leg buds take the shape of paddles, and fingers have begun to form. The eyes become noticeable and the upper lip and nose are formed.'
      },
      {
        'week': 8,
        'question': 'What is a crown-rump length (CRL)?',
        'options': [
          'A) The baby\'s total arm span',
          'B) The measurement from top of head to bottom of buttocks',
          'C) The baby\'s head circumference',
          'D) The measurement of the placenta'
        ],
        'correct': 1,
        'explanation': 'Crown-rump length (CRL) is the standard measurement from the top of the baby\'s head (crown) to the bottom of the buttocks (rump) used in early pregnancy.'
      },
      {
        'week': 8,
        'question': 'What begins to form in the baby\'s abdomen during Week 8?',
        'options': [
          'A) The liver and kidneys',
          'B) Intestines',
          'C) The stomach',
          'D) The pancreas'
        ],
        'correct': 1,
        'explanation': 'During Week 8, the intestines begin forming. They\'re still too large for the baby\'s abdomen, so they extend into the umbilical cord temporarily.'
      },
      {
        'week': 8,
        'question': 'How is the baby connected to the placenta during Week 8?',
        'options': [
          'A) Through blood vessels only',
          'B) Through the umbilical cord',
          'C) The placenta is just forming',
          'D) Not yet connected'
        ],
        'correct': 1,
        'explanation': 'By Week 8, the umbilical cord connects the baby to the placenta. This will deliver oxygen and nutrients and remove waste products.'
      },

      // Week 9 Questions
      {
        'week': 9,
        'question': 'What becomes visible during Week 9?',
        'options': [
          'A) Hair on the head',
          'B) Toes and eyelids',
          'C) Fingernails',
          'D) Teeth'
        ],
        'correct': 1,
        'explanation': 'Toes become visible and eyelids form during Week 9. The baby\'s arms grow and elbows appear, allowing for more movement.'
      },
      {
        'week': 9,
        'question': 'What important development occurs with muscles in Week 9?',
        'options': [
          'A) They stop developing',
          'B) Tiny muscles allow the embryo to start moving',
          'C) They become fully formed',
          'D) They produce blood cells'
        ],
        'correct': 1,
        'explanation': 'Tiny muscles develop during Week 9, allowing the embryo to start moving about. Blood cells are also being made by the liver.'
      },
      {
        'week': 9,
        'question': 'What is forming inside the baby\'s mouth during Week 9?',
        'options': [
          'A) Actual teeth',
          'B) Taste buds',
          'C) The palate (roof of mouth)',
          'D) Salivary glands'
        ],
        'correct': 2,
        'explanation': 'During Week 9, the palate (roof of the mouth) is forming. It will typically fuse completely by Week 12.'
      },
      {
        'week': 9,
        'question': 'What is occurring with the baby\'s genitals during Week 9?',
        'options': [
          'A) Gender can be determined by ultrasound',
          'B) Genitals are beginning to form',
          'C) The baby\'s sex is fully developed',
          'D) Genitals are visible on ultrasound'
        ],
        'correct': 1,
        'explanation': 'During Week 9, the baby\'s genitals are beginning to form, but they won\'t be visually distinguishable until much later in pregnancy.'
      },
      {
        'week': 9,
        'question': 'Approximately how much does the baby weigh at Week 9?',
        'options': [
          'A) Less than 1 gram',
          'B) About 1-2 grams',
          'C) About 5 grams',
          'D) About 10 grams'
        ],
        'correct': 1,
        'explanation': 'At Week 9, the baby weighs approximately 1-2 grams and measures about 16 mm (head to rump).'
      },

      // Week 10 Questions
      {
        'week': 10,
        'question': 'What major transition occurs during Week 10?',
        'options': [
          'A) Embryo becomes a fetus',
          'B) Baby can breathe',
          'C) Baby can see',
          'D) Baby can hear'
        ],
        'correct': 0,
        'explanation': 'At Week 10, the embryo is now called a fetus. All bodily organs are formed, and the brain is active with brain waves.'
      },
      {
        'week': 10,
        'question': 'What happens to fingers and toes in Week 10?',
        'options': [
          'A) They fall off',
          'B) They lose their webbing and become longer',
          'C) They start forming',
          'D) They develop nails'
        ],
        'correct': 1,
        'explanation': 'Fingers and toes continue developing and lose their webbing during Week 10, becoming longer and more distinct.'
      },
      {
        'week': 10,
        'question': 'What is the size of the fetus at Week 10?',
        'options': [
          'A) About 3 cm (the size of a prune)',
          'B) About 5 cm (the size of a strawberry)',
          'C) About 7 cm',
          'D) About 10 cm'
        ],
        'correct': 0,
        'explanation': 'At Week 10, the fetus is about 3 cm long from crown to rump, roughly the size of a prune, and weighs about 4 grams.'
      },
      {
        'week': 10,
        'question': 'What is a significant milestone regarding the fetus\'s head at Week 10?',
        'options': [
          'A) The head is fully formed',
          'B) The head is half the body length',
          'C) The head features are recognizable',
          'D) The fontanels close'
        ],
        'correct': 1,
        'explanation': 'At Week 10, the fetus\'s head is about half the body length. This proportion will change as the body grows faster than the head.'
      },
      {
        'week': 10,
        'question': 'What medical milestone happens around Week 10?',
        'options': [
          'A) First ultrasound typically done',
          'B) Gender is visually determined',
          'C) Amniocentesis is performed',
          'D) The baby is full term'
        ],
        'correct': 0,
        'explanation': 'Around Week 10, the first ultrasound (dating scan) is typically performed to confirm pregnancy dating and viability.'
      },

      // Week 11 Questions
      {
        'week': 11,
        'question': 'What begins developing inside the gums during Week 11?',
        'options': [
          'A) Taste buds',
          'B) Teeth buds',
          'C) Salivary glands',
          'D) Tongue'
        ],
        'correct': 1,
        'explanation': 'Teeth buds begin forming inside the gums during Week 11. The baby is now officially called a fetus, and the outer genitals start developing.'
      },
      {
        'week': 11,
        'question': 'Approximately how long is the baby at Week 11?',
        'options': [
          'A) 1 inch',
          'B) 2 inches (50 mm)',
          'C) 3 inches',
          'D) 4 inches'
        ],
        'correct': 1,
        'explanation': 'By Week 11, the baby measures about 2 inches (50 millimeters) long from crown to rump and weighs about 1/3 ounce.'
      },
      {
        'week': 11,
        'question': 'What is forming beneath the baby\'s skin during Week 11?',
        'options': [
          'A) Muscles',
          'B) Bones',
          'C) Hair follicles',
          'D) Fat stores'
        ],
        'correct': 2,
        'explanation': 'Hair follicles are beginning to form beneath the baby\'s skin during Week 11, though no visible hair yet.'
      },
      {
        'week': 11,
        'question': 'What significant reflex is developing during Week 11?',
        'options': [
          'A) Grasping reflex',
          'B) Startle reflex',
          'C) Sucking reflex',
          'D) Rooting reflex'
        ],
        'correct': 0,
        'explanation': 'The grasping reflex begins developing during Week 11. The baby can start to make a fist with their hands.'
      },
      {
        'week': 11,
        'question': 'What happens to the placenta during Week 11?',
        'options': [
          'A) It starts forming',
          'B) It is fully formed and mature',
          'C) It continues to develop and become more efficient',
          'D) It stops growing'
        ],
        'correct': 2,
        'explanation': 'The placenta continues to develop and become more efficient during Week 11, taking over more hormonal production.'
      },

      // Week 12 Questions
      {
        'week': 12,
        'question': 'What develops on the fingers during Week 12?',
        'options': [
          'A) Bones',
          'B) Muscles',
          'C) Fingernails',
          'D) Fingerprints'
        ],
        'correct': 2,
        'explanation': 'Fingernails begin sprouting during Week 12. The baby\'s face has a more developed profile, and intestines are now in the abdomen.'
      },
      {
        'week': 12,
        'question': 'What screening test may be offered around Week 12?',
        'options': [
          'A) Glucose tolerance test',
          'B) First trimester combined screening test',
          'C) Amniocentesis',
          'D) Gender reveal test'
        ],
        'correct': 1,
        'explanation': 'The first trimester combined screening test (blood test + ultrasound) can be done around Week 12 to check for chromosomal conditions like Down syndrome.'
      },
      {
        'week': 12,
        'question': 'What is measured during the first trimester ultrasound at Week 12?',
        'options': [
          'A) Baby\'s weight only',
          'B) Nuchal translucency (thickness at back of neck)',
          'C) Baby\'s gender only',
          'D) Placental thickness'
        ],
        'correct': 1,
        'explanation': 'The nuchal translucency (measurement of fluid at the back of the fetus\'s neck) is measured at Week 12 to screen for chromosome abnormalities.'
      },
      {
        'week': 12,
        'question': 'Approximately how long is the baby at Week 12?',
        'options': [
          'A) 2 inches',
          'B) 2.5-3 inches (61 mm)',
          'C) 4 inches',
          'D) 5 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 12, the baby measures about 2.5-3 inches long and weighs about 0.5 ounces.'
      },
      {
        'week': 12,
        'question': 'What is the baby\'s heartbeat rate at Week 12?',
        'options': [
          'A) 80-90 bpm',
          'B) 110-160 bpm',
          'C) 180-200 bpm',
          'D) Over 200 bpm'
        ],
        'correct': 1,
        'explanation': 'The baby\'s heartbeat is now 110-160 bpm, which is normal for a fetus and much faster than an adult\'s heart rate.'
      },

      // Week 13 Questions
      {
        'week': 13,
        'question': 'What trimester begins at Week 13?',
        'options': [
          'A) First trimester',
          'B) Second trimester',
          'C) Third trimester',
          'D) Fourth trimester'
        ],
        'correct': 1,
        'explanation': 'Week 13 marks the beginning of the second trimester. The baby can swim quite vigorously and is more than 7 cm long.'
      },
      {
        'week': 13,
        'question': 'What begins to harden during Week 13?',
        'options': [
          'A) Skin',
          'B) Muscles',
          'C) Bones in the skeleton',
          'D) Organs'
        ],
        'correct': 2,
        'explanation': 'Bones start to harden in the skeleton during Week 13, especially in the skull and long bones of the arms and legs.'
      },
      {
        'week': 13,
        'question': 'What hormone does the placenta now primarily produce during Week 13?',
        'options': [
          'A) HCG',
          'B) FSH',
          'C) Progesterone',
          'D) LH'
        ],
        'correct': 2,
        'explanation': 'By Week 13, the placenta has taken over most progesterone production from the corpus luteum, making miscarriage risk significantly lower.'
      },
      {
        'week': 13,
        'question': 'What typically improves for mothers as they enter the second trimester?',
        'options': [
          'A) Morning sickness often decreases',
          'B) Weight gain accelerates',
          'C) Fatigue increases dramatically',
          'D) Hormonal surges increase'
        ],
        'correct': 0,
        'explanation': 'As many mothers enter the second trimester around Week 13, morning sickness often improves, and energy levels typically increase.'
      },
      {
        'week': 13,
        'question': 'What can be seen on ultrasound at Week 13?',
        'options': [
          'A) The baby\'s gender clearly',
          'B) Baby\'s features: nose, ears, lips, chin',
          'C) Baby\'s fingerprints',
          'D) Baby\'s hair color'
        ],
        'correct': 1,
        'explanation': 'At Week 13, ultrasound can show the baby\'s developing facial features including nose, ears, lips, and chin with more detail.'
      },

      // Week 14 Questions
      {
        'week': 14,
        'question': 'What new abilities does the baby develop in Week 14?',
        'options': [
          'A) Can hear sounds',
          'B) Can open and close hands and bring them to mouth',
          'C) Can digest food',
          'D) Can breathe air'
        ],
        'correct': 1,
        'explanation': 'During Week 14, the baby starts moving their eyes, and can open/close hands and bring them to their mouth. Skin starts to thicken.'
      },
      {
        'week': 14,
        'question': 'What develops under the skin in Week 14?',
        'options': [
          'A) Fat cells',
          'B) Blood vessels',
          'C) Hair follicles',
          'D) Sweat glands'
        ],
        'correct': 2,
        'explanation': 'Hair follicles begin to grow under the skin during Week 14. The vocal cords are also developing, though the baby can only cry mutely.'
      },
      {
        'week': 14,
        'question': 'What is the baby\'s approximate length at Week 14?',
        'options': [
          'A) 2 inches',
          'B) 3.4 inches (85 mm)',
          'C) 4 inches',
          'D) 5 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 14, the baby is approximately 3.4 inches long and weighs about 1.5 ounces.'
      },
      {
        'week': 14,
        'question': 'What can be identified on ultrasound during Week 14?',
        'options': [
          'A) Baby\'s gender with more accuracy',
          'B) Baby\'s face shape',
          'C) Baby\'s spine clearly',
          'D) Baby\'s movement patterns'
        ],
        'correct': 0,
        'explanation': 'While not always reliable at Week 14, the baby\'s gender may begin to be identifiable via ultrasound, though most do it later.'
      },
      {
        'week': 14,
        'question': 'What common maternal symptom often starts around Week 14?',
        'options': [
          'A) Morning sickness',
          'B) Quickening (feeling baby move)',
          'C) Preeclampsia',
          'D) Gestational diabetes'
        ],
        'correct': 1,
        'explanation': 'Around Week 14, first-time mothers may start feeling the first fluttering movements (quickening), though it varies by individual.'
      },

      // Week 15 Questions
      {
        'week': 15,
        'question': 'What sense begins to develop around Week 15?',
        'options': [
          'A) Sight',
          'B) Hearing',
          'C) Taste',
          'D) Smell'
        ],
        'correct': 1,
        'explanation': 'Around Week 15, the baby starts to hear muted sounds from the outside world and noises from your digestive system.'
      },
      {
        'week': 15,
        'question': 'What continues to develop rapidly in Week 15?',
        'options': [
          'A) Fingernails',
          'B) Bone development',
          'C) Eyelashes',
          'D) Toenails'
        ],
        'correct': 1,
        'explanation': 'Bone development continues rapidly in Week 15. The bones are growing strong, and the scalp hair pattern is forming.'
      },
      {
        'week': 15,
        'question': 'What is beginning to form on the baby\'s scalp during Week 15?',
        'options': [
          'A) Hair',
          'B) Hair follicles with hair growing',
          'C) Lanugo (fine downy hair)',
          'D) Hair color'
        ],
        'correct': 2,
        'explanation': 'Fine downy hair called lanugo is beginning to cover the baby\'s body, including the scalp, during Week 15.'
      },
      {
        'week': 15,
        'question': 'Approximately how long is the baby at Week 15?',
        'options': [
          'A) 3 inches',
          'B) 4 inches (10 cm)',
          'C) 5 inches',
          'D) 6 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 15, the baby is approximately 4 inches long and weighs about 2.5 ounces.'
      },
      {
        'week': 15,
        'question': 'What can mothers often do now that wasn\'t possible before Week 15?',
        'options': [
          'A) See the baby clearly on ultrasound',
          'B) Hear baby\'s heartbeat with stethoscope',
          'C) Feel baby\'s kicks',
          'D) Give birth safely'
        ],
        'correct': 2,
        'explanation': 'By Week 15, most mothers can feel the baby\'s movements as gentle kicks or fluttering sensations, though timing varies.'
      },

      // Week 16 Questions
      {
        'week': 16,
        'question': 'What can the baby\'s eyes do during Week 16?',
        'options': [
          'A) See colors',
          'B) Move slowly',
          'C) Open fully',
          'D) Focus on objects'
        ],
        'correct': 1,
        'explanation': 'By Week 16, the baby\'s eyes can move slowly, and ears are close to reaching their final position. Eyelashes and eyebrows have appeared.'
      },
      {
        'week': 16,
        'question': 'What new feature appears on the tongue during Week 16?',
        'options': [
          'A) Muscles',
          'B) Taste buds',
          'C) Salivary glands',
          'D) Papillae'
        ],
        'correct': 1,
        'explanation': 'Taste buds form on the tongue around Week 16. The baby is about 4 3/4 inches long and weighs about 4 ounces.'
      },
      {
        'week': 16,
        'question': 'What reflex might be observed during Week 16?',
        'options': [
          'A) Grasping',
          'B) Swallowing',
          'C) Stepping reflex',
          'D) Rooting'
        ],
        'correct': 1,
        'explanation': 'The swallowing reflex develops during Week 16. The baby practices swallowing amniotic fluid.'
      },
      {
        'week': 16,
        'question': 'What is happening with the baby\'s ears during Week 16?',
        'options': [
          'A) They are starting to form',
          'B) They are closing up',
          'C) They have reached their final size and position',
          'D) They are starting to function'
        ],
        'correct': 2,
        'explanation': 'By Week 16, the ears have reached approximately their final size and position on the sides of the head.'
      },
      {
        'week': 16,
        'question': 'What can be assessed with the quad screen test around Week 16?',
        'options': [
          'A) Baby\'s weight',
          'B) Risk of chromosome abnormalities and neural tube defects',
          'C) Baby\'s gender',
          'D) Placental health'
        ],
        'correct': 1,
        'explanation': 'The quad screen (triple screen) maternal blood test around Week 15-22 assesses risk for Down syndrome and neural tube defects.'
      },

      // Week 17 Questions
      {
        'week': 17,
        'question': 'What starts developing on the baby\'s toes in Week 17?',
        'options': [
          'A) Bones',
          'B) Skin',
          'C) Toenails',
          'D) Muscles'
        ],
        'correct': 2,
        'explanation': 'Toenails start developing during Week 17. The baby is becoming more active with rolling and flipping movements.'
      },
      {
        'week': 17,
        'question': 'What might you feel for the first time around Week 17?',
        'options': [
          'A) Contractions',
          'B) Baby hiccupping',
          'C) Baby\'s heartbeat',
          'D) Kicks'
        ],
        'correct': 1,
        'explanation': 'Around Week 17, you might feel the baby hiccupping, which causes small jerking movements. Some women may also start feeling movement.'
      },
      {
        'week': 17,
        'question': 'What is the baby\'s approximate size at Week 17?',
        'options': [
          'A) 3 inches',
          'B) 5 inches (13 cm)',
          'C) 7 inches',
          'D) 9 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 17, the baby is approximately 5 inches long and weighs about 5 ounces.'
      },
      {
        'week': 17,
        'question': 'What is growing rapidly on the baby\'s head during Week 17?',
        'options': [
          'A) Eyebrows',
          'B) Hair',
          'C) Scalp skin',
          'D) The brain'
        ],
        'correct': 1,
        'explanation': 'Hair is growing on the baby\'s head during Week 17, though it\'s very fine and may not all be visible until birth.'
      },
      {
        'week': 17,
        'question': 'What is the baby\'s fat composition percentage at Week 17?',
        'options': [
          'A) Less than 1%',
          'B) About 2-3%',
          'C) About 10%',
          'D) About 15%'
        ],
        'correct': 0,
        'explanation': 'The baby has less than 1% body fat at Week 17, but this will increase significantly as the pregnancy progresses.'
      },

      // Week 18 Questions
      {
        'week': 18,
        'question': 'What organs are functioning well by Week 18?',
        'options': [
          'A) Lungs and liver',
          'B) Kidneys and heart',
          'C) Stomach and intestines',
          'D) Brain and spinal cord'
        ],
        'correct': 1,
        'explanation': 'The baby\'s kidneys and heart are functioning well by Week 18. The baby is around 14.2 cm (about the size of a sweet potato).'
      },
      {
        'week': 18,
        'question': 'What movement practice occurs during Week 18?',
        'options': [
          'A) Walking',
          'B) Swallowing',
          'C) Breathing amniotic fluid in and out',
          'D) Kicking'
        ],
        'correct': 2,
        'explanation': 'During Week 18, the baby practices breathing by moving amniotic fluid in and out of the lungs, preparing for breathing after birth.'
      },
      {
        'week': 18,
        'question': 'What is the baby\'s approximate length at Week 18?',
        'options': [
          'A) 4 inches',
          'B) 5.5 inches (14 cm)',
          'C) 7 inches',
          'D) 9 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 18, the baby is approximately 5.5 inches long and weighs about 6.4 ounces.'
      },
      {
        'week': 18,
        'question': 'What is the mid-pregnancy anatomy scan (Level 2 ultrasound) checking for?',
        'options': [
          'A) Baby\'s weight gain',
          'B) Fetal anatomy, growth, and development',
          'C) Baby\'s gender only',
          'D) Placental thickness'
        ],
        'correct': 1,
        'explanation': 'The mid-pregnancy anatomy scan around Week 18-22 checks the baby\'s anatomy, growth, and development for any abnormalities.'
      },
      {
        'week': 18,
        'question': 'What can be evaluated on the anatomy ultrasound at Week 18?',
        'options': [
          'A) Only the baby\'s length',
          'B) Brain, spine, heart, limbs, and face',
          'C) Only the placenta',
          'D) Only amniotic fluid volume'
        ],
        'correct': 1,
        'explanation': 'The anatomy scan evaluates the baby\'s brain, spine, heart, limbs, face, and other structures for normal development.'
      },

      // Week 19 Questions
      {
        'week': 19,
        'question': 'What protective layer develops on the skin in Week 19?',
        'options': [
          'A) Epidermis',
          'B) Vernix caseosa',
          'C) Lanugo',
          'D) Melanin'
        ],
        'correct': 1,
        'explanation': 'A protective waxy coating called vernix caseosa begins covering the skin during Week 19 to protect it in the amniotic fluid.'
      },
      {
        'week': 19,
        'question': 'What important reflex may develop around Week 19?',
        'options': [
          'A) Grasping reflex',
          'B) Rooting reflex',
          'C) Sucking (may suck thumb)',
          'D) Startle reflex'
        ],
        'correct': 2,
        'explanation': 'The baby learns how to suck around Week 19 and may even suck their thumb in the womb, an important skill for feeding after birth.'
      },
      {
        'week': 19,
        'question': 'What is the baby\'s approximate size at Week 19?',
        'options': [
          'A) 3 inches',
          'B) 6 inches (15 cm)',
          'C) 8 inches',
          'D) 10 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 19, the baby is approximately 6 inches long and weighs about 8.5 ounces.'
      },
      {
        'week': 19,
        'question': 'What can be detected on ultrasound at Week 19?',
        'options': [
          'A) Baby\'s facial expressions',
          'B) Baby\'s crying',
          'C) Baby\'s yawning movements',
          'D) Baby\'s personality'
        ],
        'correct': 2,
        'explanation': 'At Week 19, the baby can be seen yawning on ultrasound, one of the many movements the baby is practicing.'
      },
      {
        'week': 19,
        'question': 'What continues to increase during Week 19?',
        'options': [
          'A) The baby\'s weight only',
          'B) Baby\'s awareness and responsiveness to stimuli',
          'C) Lanugo coverage',
          'D) Vernix caseosa layer'
        ],
        'correct': 1,
        'explanation': 'The baby\'s awareness and responsiveness to stimuli continues to increase during Week 19.'
      },

      // Week 20 Questions
      {
        'week': 20,
        'question': 'What milestone does Week 20 represent?',
        'options': [
          'A) End of second trimester',
          'B) Halfway point of pregnancy',
          'C) Beginning of third trimester',
          'D) Full term'
        ],
        'correct': 1,
        'explanation': 'Week 20 marks the halfway point of pregnancy. You might start feeling your baby\'s movements (quickening) if you haven\'t already.'
      },
      {
        'week': 20,
        'question': 'What can the baby\'s ears do by Week 20?',
        'options': [
          'A) They are fully formed',
          'B) They can hear muffled sounds from outside',
          'C) They can distinguish voices',
          'D) They can hear high-frequency sounds'
        ],
        'correct': 1,
        'explanation': 'By Week 20, the baby\'s ears are fully functioning and can hear muffled sounds from the outside world. The baby is about 10 inches long.'
      },
      {
        'week': 20,
        'question': 'What is the baby\'s approximate weight at Week 20?',
        'options': [
          'A) 4 ounces',
          'B) 8 ounces',
          'C) 10 ounces',
          'D) 12 ounces'
        ],
        'correct': 2,
        'explanation': 'At Week 20 (halfway point), the baby is approximately 10 inches long and weighs about 10 ounces.'
      },
      {
        'week': 20,
        'question': 'What is being observed more frequently by mothers at Week 20?',
        'options': [
          'A) Cramping',
          'B) Baby\'s movements (kicks and flutters)',
          'C) Bleeding',
          'D) Severe pain'
        ],
        'correct': 1,
        'explanation': 'At Week 20, mothers are observing baby\'s movements more frequently and starting to recognize the baby\'s activity patterns.'
      },
      {
        'week': 20,
        'question': 'What maternal changes are common at Week 20?',
        'options': [
          'A) Extreme nausea',
          'B) Weight gain and beginning of skin changes',
          'C) Loss of appetite',
          'D) Severe fatigue'
        ],
        'correct': 1,
        'explanation': 'At Week 20, mothers typically show more visible weight gain, and skin changes like darkened nipples or a linea nigra may appear.'
      },
      // Week 21 Questions
      {
        'week': 21,
        'question': 'What unique identifiers are fully developed by Week 21?',
        'options': [
          'A) DNA patterns',
          'B) Eye color',
          'C) Fingerprints and toe prints',
          'D) Blood type'
        ],
        'correct': 2,
        'explanation': 'Fingerprints and toe prints are fully formed by Week 21, making each baby unique. The baby can now swallow.'
      },
      {
        'week': 21,
        'question': 'What regular, jerky movements might you feel in Week 21?',
        'options': [
          'A) Kicks',
          'B) Hiccups',
          'C) Stretches',
          'D) Rolls'
        ],
        'correct': 1,
        'explanation': 'You may feel hiccups as regular, jerky movements during Week 21. The baby\'s fingers and toes are also fully formed.'
      },
      {
        'week': 21,
        'question': 'What is the baby\'s approximate size at Week 21?',
        'options': [
          'A) 8 inches',
          'B) 10.5 inches (27 cm)',
          'C) 12 inches',
          'D) 14 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 21, the baby is approximately 10.5 inches long and weighs about 12.7 ounces (just under 1 pound).'
      },
      {
        'week': 21,
        'question': 'What is developing in the baby\'s stomach at Week 21?',
        'options': [
          'A) Digestive enzymes',
          'B) Meconium (first poop)',
          'C) Acid for digestion',
          'D) Bile'
        ],
        'correct': 1,
        'explanation': 'Meconium, the baby\'s first stool, is beginning to accumulate in the baby\'s intestines during Week 21.'
      },
      {
        'week': 21,
        'question': 'What can be evaluated in the baby\'s blood at Week 21?',
        'options': [
          'A) Intelligence level',
          'B) RBC production and hemoglobin levels',
          'C) Future health conditions',
          'D) Personality traits'
        ],
        'correct': 1,
        'explanation': 'The baby\'s blood is now producing red blood cells, and hemoglobin levels can be assessed if needed for fetal health monitoring.'
      },

      // Week 22 Questions
      {
        'week': 22,
        'question': 'What can the baby\'s eyes do behind closed eyelids in Week 22?',
        'options': [
          'A) See shapes',
          'B) Move',
          'C) Change color',
          'D) Focus'
        ],
        'correct': 1,
        'explanation': 'The baby\'s eyes can move behind the closed eyelids during Week 22. Tear ducts start developing and eyebrows may appear.'
      },
      {
        'week': 22,
        'question': 'How does the baby respond to stimuli in Week 22?',
        'options': [
          'A) Closes eyes',
          'B) Stops moving',
          'C) Moves suddenly when hearing loud sounds',
          'D) Changes position'
        ],
        'correct': 2,
        'explanation': 'The baby may move suddenly when hearing loud sounds during Week 22. The baby\'s muscles are getting stronger every week.'
      },
      {
        'week': 22,
        'question': 'What is the baby\'s approximate weight at Week 22?',
        'options': [
          'A) 6 ounces',
          'B) 10 ounces',
          'C) 1 pound (454 grams)',
          'D) 1.5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 22, the baby weighs approximately 1 pound and measures about 11 inches from head to toe.'
      },
      {
        'week': 22,
        'question': 'What is happening with the baby\'s lungs during Week 22?',
        'options': [
          'A) They are fully mature',
          'B) They are starting to produce surfactant',
          'C) They can breathe independently',
          'D) They are not developing yet'
        ],
        'correct': 1,
        'explanation': 'The baby\'s lungs are starting to produce surfactant, a substance needed for breathing after birth.'
      },
      {
        'week': 22,
        'question': 'What is the survival rate if delivery occurs at Week 22 with medical care?',
        'options': [
          'A) Nearly 100%',
          'B) About 50-60%',
          'C) About 0-10%',
          'D) Impossible to survive'
        ],
        'correct': 1,
        'explanation': 'Babies born at Week 22 with intensive medical care have survival rates of about 50-60%, though longer gestation improves outcomes.'
      },

      // Week 23 Questions
      {
        'week': 23,
        'question': 'What can the baby recognize during Week 23?',
        'options': [
          'A) Faces',
          'B) Music',
          'C) Sounds, like your voice',
          'D) Light patterns'
        ],
        'correct': 2,
        'explanation': 'The baby may recognize sounds like your voice during Week 23. You may feel the baby move in response to talking or singing.'
      },
      {
        'week': 23,
        'question': 'What important lung development occurs in Week 23?',
        'options': [
          'A) Lungs fully mature',
          'B) Ridges form in palms and soles (fingerprints/footprints foundation)',
          'C) Baby can breathe air',
          'D) Lung sacs open'
        ],
        'correct': 1,
        'explanation': 'Ridges form in the palms and soles during Week 23, creating the foundation for fingerprints and footprints. Lungs start making surfactant.'
      },
      {
        'week': 23,
        'question': 'What is the baby\'s approximate size at Week 23?',
        'options': [
          'A) 8 inches',
          'B) 11 inches (29 cm)',
          'C) 13 inches',
          'D) 15 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 23, the baby is approximately 11 inches long and weighs about 1.1 pounds.'
      },
      {
        'week': 23,
        'question': 'What is being stored in the baby\'s body during Week 23?',
        'options': [
          'A) Fat only',
          'B) Iron, calcium, and phosphorus',
          'C) Glucose only',
          'D) Vitamin D only'
        ],
        'correct': 1,
        'explanation': 'The baby is storing essential minerals like iron, calcium, and phosphorus, which are crucial for development.'
      },
      {
        'week': 23,
        'question': 'What can be heard with a Doppler device during Week 23?',
        'options': [
          'A) Baby\'s crying',
          'B) Baby\'s hiccupping',
          'C) Baby\'s heartbeat clearly',
          'D) Baby\'s breathing sounds'
        ],
        'correct': 2,
        'explanation': 'The baby\'s heartbeat can be clearly heard with a Doppler device during Week 23.'
      },

      // Week 24 Questions
      {
        'week': 24,
        'question': 'What survival milestone occurs around Week 24?',
        'options': [
          'A) Baby can regulate temperature',
          'B) Baby can first potentially survive outside the womb with medical help',
          'C) Baby can breathe independently',
          'D) Baby\'s organs are fully mature'
        ],
        'correct': 1,
        'explanation': 'Week 24 is when a baby might first survive outside the womb with intensive medical care, though longer gestation greatly improves outcomes.'
      },
      {
        'week': 24,
        'question': 'What new cells does the baby start making in Week 24?',
        'options': [
          'A) Brain cells',
          'B) Skin cells',
          'C) White blood cells',
          'D) Muscle cells'
        ],
        'correct': 2,
        'explanation': 'The baby starts making white blood cells around Week 24, which help fight disease and infection. The baby is about 12.5 inches long.'
      },
      {
        'week': 24,
        'question': 'What is the baby\'s approximate weight at Week 24?',
        'options': [
          'A) 0.5 pounds',
          'B) 1 pound',
          'C) 1.3 pounds (600 grams)',
          'D) 2 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 24, the baby weighs approximately 1.3 pounds and measures about 12.5 inches.'
      },
      {
        'week': 24,
        'question': 'What reflex is developing during Week 24?',
        'options': [
          'A) Startle reflex',
          'B) Breathing reflex and lung maturation',
          'C) Walking reflex',
          'D) Chewing reflex'
        ],
        'correct': 1,
        'explanation': 'The breathing reflex and lung structures continue to develop during Week 24, crucial for potential viability.'
      },
      {
        'week': 24,
        'question': 'What test might be done around Week 24 for women at risk?',
        'options': [
          'A) Glucose tolerance test',
          'B) Fetal non-stress test',
          'C) Amniocentesis',
          'D) Cordocentesis'
        ],
        'correct': 0,
        'explanation': 'The glucose tolerance test (screening for gestational diabetes) is typically done around Week 24-28 for all pregnant women.'
      },

      // Week 25 Questions
      {
        'week': 25,
        'question': 'What happens to the baby\'s skin in Week 25?',
        'options': [
          'A) It becomes transparent',
          'B) It becomes opaque instead of transparent',
          'C) It develops wrinkles',
          'D) It changes color'
        ],
        'correct': 1,
        'explanation': 'The baby\'s skin becomes opaque (not transparent) during Week 25. The baby still has skin folds and needs to grow into its skin.'
      },
      {
        'week': 25,
        'question': 'What can be heard through a stethoscope at Week 25?',
        'options': [
          'A) Baby\'s breathing',
          'B) Baby\'s hiccups',
          'C) Baby\'s heartbeat',
          'D) Baby\'s movements'
        ],
        'correct': 2,
        'explanation': 'The baby\'s heartbeat can be heard through a stethoscope during Week 25, and others might hear it by putting an ear to your belly.'
      },
      {
        'week': 25,
        'question': 'What is the baby\'s approximate size at Week 25?',
        'options': [
          'A) 10 inches',
          'B) 12 inches (30.6 cm)',
          'C) 14 inches',
          'D) 16 inches'
        ],
        'correct': 1,
        'explanation': 'At Week 25, the baby is approximately 12 inches long and weighs about 1.5 pounds.'
      },
      {
        'week': 25,
        'question': 'What is beginning to form under the baby\'s skin at Week 25?',
        'options': [
          'A) Bones',
          'B) More fat deposits',
          'C) Muscles',
          'D) Tendons'
        ],
        'correct': 1,
        'explanation': 'More fat is being deposited under the baby\'s skin during Week 25, which will help regulate body temperature after birth.'
      },
      {
        'week': 25,
        'question': 'What maternal discomfort might start around Week 25?',
        'options': [
          'A) Severe morning sickness',
          'B) Braxton-Hicks contractions',
          'C) Preeclampsia',
          'D) Gestational diabetes'
        ],
        'correct': 1,
        'explanation': 'Braxton-Hicks contractions (practice contractions) may start around Week 25, which are usually painless and irregular.'
      },

      // Week 26 Questions
      {
        'week': 26,
        'question': 'What facial features are well-formed by Week 26?',
        'options': [
          'A) Nose and mouth',
          'B) Eyebrows and eyelashes',
          'C) Ears and chin',
          'D) Cheeks and jaw'
        ],
        'correct': 1,
        'explanation': 'Eyebrows and eyelashes are well-formed by Week 26. All parts of the baby\'s eyes are developed.'
      },
      {
        'week': 26,
        'question': 'What might cause the baby to startle in Week 26?',
        'options': [
          'A) Bright lights',
          'B) Cold temperatures',
          'C) Loud noises',
          'D) Spicy foods'
        ],
        'correct': 2,
        'explanation': 'The baby may startle in response to loud noises during Week 26. Air sacs are forming in the lungs, though they\'re not ready to work outside the womb.'
      },
      {
        'week': 26,
        'question': 'What is the baby\'s approximate weight at Week 26?',
        'options': [
          'A) 1 pound',
          'B) 1.5 pounds',
          'C) 1.7 pounds (760 grams)',
          'D) 2 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 26, the baby weighs approximately 1.7 pounds and measures about 13 inches.'
      },
      {
        'week': 26,
        'question': 'What is the baby practicing with their eyelids at Week 26?',
        'options': [
          'A) Keeping them closed',
          'B) Opening and closing them',
          'C) Blinking',
          'D) Squinting'
        ],
        'correct': 1,
        'explanation': 'The baby is practicing opening and closing their eyelids at Week 26, preparing for life outside the womb.'
      },
      {
        'week': 26,
        'question': 'What can develop if the mother is Rh-negative at Week 26?',
        'options': [
          'A) Nothing, it\'s not a concern',
          'B) Rh antibodies if sensitized',
          'C) Immediate complications',
          'D) Premature labor'
        ],
        'correct': 1,
        'explanation': 'If an Rh-negative mother is not sensitized, Rh immunoglobulin is given around Week 28 to prevent sensitization.'
      },

      // Week 27 Questions
      {
        'week': 27,
        'question': 'What trimester ends at Week 27?',
        'options': [
          'A) First trimester',
          'B) Second trimester',
          'C) Third trimester',
          'D) None - it\'s mid-trimester'
        ],
        'correct': 1,
        'explanation': 'Week 27 marks the end of the second trimester. The baby\'s nervous system continues maturing, and fat gain increases.'
      },
      {
        'week': 27,
        'question': 'What major system continues to mature in Week 27?',
        'options': [
          'A) Digestive system',
          'B) Reproductive system',
          'C) Nervous system',
          'D) Skeletal system'
        ],
        'correct': 2,
        'explanation': 'The nervous system continues to mature during Week 27. The baby is also gaining fat, which helps the skin look smoother.'
      },
      {
        'week': 27,
        'question': 'What is the baby\'s approximate size at Week 27?',
        'options': [
          'A) 10 inches',
          'B) 13 inches',
          'C) 14.5 inches (36.5 cm)',
          'D) 16 inches'
        ],
        'correct': 2,
        'explanation': 'At Week 27, the baby is approximately 14.5 inches long and weighs about 1.9 pounds.'
      },
      {
        'week': 27,
        'question': 'What movement pattern might be noticed at Week 27?',
        'options': [
          'A) Less movement',
          'B) More organized movements and patterns',
          'C) Random jerky movements only',
          'D) No movement'
        ],
        'correct': 1,
        'explanation': 'At Week 27, the baby\'s movements become more organized and the mother can recognize activity patterns.'
      },
      {
        'week': 27,
        'question': 'What brain development is significant at Week 27?',
        'options': [
          'A) Brain is fully developed',
          'B) Brain is starting to grow',
          'C) Brain is rapidly organizing and continuing to grow',
          'D) No brain development'
        ],
        'correct': 2,
        'explanation': 'The baby\'s brain is rapidly organizing with increasing brain wave activity and continued growth at Week 27.'
      },

      // Week 28 Questions
      {
        'week': 28,
        'question': 'What trimester begins at Week 28?',
        'options': [
          'A) First trimester',
          'B) Second trimester',
          'C) Third trimester',
          'D) Final trimester'
        ],
        'correct': 2,
        'explanation': 'Week 28 marks the beginning of the third trimester. The baby\'s eyelids can partially open, and breathing movements can be seen on ultrasound.'
      },
      {
        'week': 28,
        'question': 'What can the central nervous system do by Week 28?',
        'options': [
          'A) Control all reflexes',
          'B) Control body temperature and trigger breathing movements',
          'C) Process complex thoughts',
          'D) Coordinate all movements'
        ],
        'correct': 1,
        'explanation': 'By Week 28, the central nervous system can control body temperature and trigger breathing movements. The baby weighs about 2 1/4 pounds.'
      },
      {
        'week': 28,
        'question': 'What is the baby\'s approximate size at Week 28?',
        'options': [
          'A) 12 inches',
          'B) 14.5 inches',
          'C) 16 inches (37.6 cm)',
          'D) 18 inches'
        ],
        'correct': 2,
        'explanation': 'At Week 28, the baby is approximately 16 inches long and weighs about 2.25 pounds.'
      },
      {
        'week': 28,
        'question': 'What test is commonly done around Week 28?',
        'options': [
          'A) First trimester screening',
          'B) Glucose tolerance test for gestational diabetes',
          'C) Amniocentesis',
          'D) Cordocentesis'
        ],
        'correct': 1,
        'explanation': 'The glucose tolerance test is commonly done around Week 28 to screen for gestational diabetes.'
      },
      {
        'week': 28,
        'question': 'What happens with Rh-negative mothers at Week 28?',
        'options': [
          'A) Nothing is done',
          'B) Rh immunoglobulin is given to prevent sensitization',
          'C) Immediate labor is induced',
          'D) Fetal monitoring begins'
        ],
        'correct': 1,
        'explanation': 'Rh-negative mothers receive Rh immunoglobulin around Week 28 to prevent sensitization from fetal blood cells.'
      },

      // Week 29 Questions
      {
        'week': 29,
        'question': 'What movements can the baby make during Week 29?',
        'options': [
          'A) Walking motions',
          'B) Kicking, stretching, and grasping',
          'C) Swimming',
          'D) Clapping'
        ],
        'correct': 1,
        'explanation': 'By Week 29, the baby can kick, stretch, and make grasping movements. The digestive system is functional.'
      },
      {
        'week': 29,
        'question': 'What begins to show during Week 29?',
        'options': [
          'A) Hair color',
          'B) Eye color',
          'C) Sleep and wake cycles with rhythm',
          'D) Personality traits'
        ],
        'correct': 2,
        'explanation': 'Sleep and wake cycles begin to show rhythm during Week 29. The baby weighs around 1.2 kg (about 2.6 pounds).'
      },
      {
        'week': 29,
        'question': 'What is the baby\'s approximate size at Week 29?',
        'options': [
          'A) 14 inches',
          'B) 16 inches',
          'C) 17 inches (42 cm)',
          'D) 19 inches'
        ],
        'correct': 2,
        'explanation': 'At Week 29, the baby is approximately 17 inches long and weighs about 2.7 pounds.'
      },
      {
        'week': 29,
        'question': 'What is accumulating in the baby\'s brain during Week 29?',
        'options': [
          'A) Cerebrospinal fluid',
          'B) Brain ridges and grooves',
          'C) Brain cells',
          'D) Fat deposits'
        ],
        'correct': 1,
        'explanation': 'Brain ridges and grooves (sulci and gyri) are accumulating, increasing the baby\'s brain complexity and surface area.'
      },
      {
        'week': 29,
        'question': 'What can mothers expect regarding fetal movements at Week 29?',
        'options': [
          'A) Very frequent powerful kicks',
          'B) Fewer but stronger movements',
          'C) Rolling and shifting positions',
          'D) No movements'
        ],
        'correct': 2,
        'explanation': 'At Week 29, mothers feel rolling and shifting positions as the baby moves within the limited space of the uterus.'
      },

      // Week 30 Questions
      {
        'week': 30,
        'question': 'What can the baby\'s eyes do by Week 30?',
        'options': [
          'A) See colors',
          'B) Open wide',
          'C) Focus on objects',
          'D) Blink rapidly'
        ],
        'correct': 1,
        'explanation': 'The baby\'s eyes can open wide by Week 30. The baby might have a good head of hair, and red blood cells form in the bone marrow.'
      },
      {
        'week': 30,
        'question': 'What is the baby\'s vision range at Week 30?',
        'options': [
          'A) 1-5 cm',
          'B) 20-30 cm in front of them',
          'C) Unlimited',
          'D) Only light and dark'
        ],
        'correct': 1,
        'explanation': 'By Week 30, the baby can see about 20-30 cm in front of them, though vision is still limited.'
      },
      {
        'week': 30,
        'question': 'What is the baby\'s approximate weight at Week 30?',
        'options': [
          'A) 1.5 pounds',
          'B) 2 pounds',
          'C) 3 pounds (1.36 kg)',
          'D) 4 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 30, the baby weighs approximately 3 pounds and measures about 17.5 inches.'
      },
      {
        'week': 30,
        'question': 'What is the baby\'s skin appearance at Week 30?',
        'options': [
          'A) Still very wrinkled',
          'B) Becoming smoother and more pink',
          'C) Turning purple',
          'D) Covered in thick hair'
        ],
        'correct': 1,
        'explanation': 'The baby\'s skin is becoming smoother and more pink at Week 30 as more fat is stored under the skin.'
      },
      {
        'week': 30,
        'question': 'What reflex is more developed at Week 30?',
        'options': [
          'A) Startle reflex',
          'B) Sucking reflex',
          'C) Rooting reflex',
          'D) All of the above'
        ],
        'correct': 3,
        'explanation': 'By Week 30, all basic reflexes are becoming more developed and coordinated, preparing for feeding after birth.'
      },

      // Week 31 Questions
      {
        'week': 31,
        'question': 'What major phase of development is mostly complete by Week 31?',
        'options': [
          'A) Brain development',
          'B) Organ development',
          'C) Major development - now time for rapid weight gain',
          'D) Skeletal development'
        ],
        'correct': 2,
        'explanation': 'By Week 31, most major development is finished and it\'s time for rapid weight gain. The baby weighs around 1.5 kg (about 3.3 pounds).'
      },
      {
        'week': 31,
        'question': 'What can the central nervous system regulate by Week 31?',
        'options': [
          'A) Emotions',
          'B) Body temperature',
          'C) Hunger',
          'D) Sleep patterns'
        ],
        'correct': 1,
        'explanation': 'The central nervous system can now regulate body temperature by Week 31. Many babies are already positioned head-down.'
      },
      {
        'week': 31,
        'question': 'What is the baby\'s approximate size at Week 31?',
        'options': [
          'A) 15 inches',
          'B) 17 inches',
          'C) 18 inches (43.7 cm)',
          'D) 20 inches'
        ],
        'correct': 2,
        'explanation': 'At Week 31, the baby is approximately 18 inches long and weighs about 3.3 pounds.'
      },
      {
        'week': 31,
        'question': 'What is happening with the baby\'s position at Week 31?',
        'options': [
          'A) Baby is still moving around freely',
          'B) Baby is starting to move into head-down position',
          'C) Baby must be head-down by now',
          'D) Baby\'s position doesn\'t matter'
        ],
        'correct': 1,
        'explanation': 'Many babies are starting to move into the head-down position by Week 31, though some may turn later.'
      },
      {
        'week': 31,
        'question': 'What mineral is the baby absorbing most at Week 31?',
        'options': [
          'A) Iron',
          'B) Calcium',
          'C) Phosphorus',
          'D) Magnesium'
        ],
        'correct': 1,
        'explanation': 'The baby is absorbing large amounts of calcium at Week 31 for bone hardening and development.'
      },

      // Week 32 Questions
      {
        'week': 32,
        'question': 'What begins to disappear during Week 32?',
        'options': [
          'A) Vernix caseosa',
          'B) Lanugo (fine body hair)',
          'C) Wrinkles',
          'D) Fat'
        ],
        'correct': 1,
        'explanation': 'Lanugo, the soft downy hair covering the baby\'s body, starts to fall off during Week 32. The baby\'s bones are fully formed but still soft.'
      },
      {
        'week': 32,
        'question': 'What becomes visible on the toes in Week 32?',
        'options': [
          'A) Bones',
          'B) Skin patterns',
          'C) Toenails',
          'D) Wrinkles'
        ],
        'correct': 2,
        'explanation': 'Toenails become visible during Week 32. The baby weighs about 3 3/4 pounds and measures about 11 inches from crown to rump.'
      },
      {
        'week': 32,
        'question': 'What is the baby\'s approximate weight at Week 32?',
        'options': [
          'A) 2 pounds',
          'B) 3 pounds',
          'C) 3.75 pounds (1.7 kg)',
          'D) 4.5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 32, the baby weighs approximately 3.75 pounds and measures about 19 inches total length.'
      },
      {
        'week': 32,
        'question': 'What is happening with the baby\'s lungs at Week 32?',
        'options': [
          'A) They are fully mature',
          'B) Air sacs are rapidly forming',
          'C) Surfactant is being produced',
          'D) They have stopped developing'
        ],
        'correct': 2,
        'explanation': 'Surfactant production continues at Week 32, which is crucial for the baby\'s breathing after birth.'
      },
      {
        'week': 32,
        'question': 'What is the baby\'s immunity status at Week 32?',
        'options': [
          'A) Baby has no immunity',
          'B) Baby is receiving antibodies from mother',
          'C) Baby has full immunity',
          'D) Baby\'s immune system is not developing'
        ],
        'correct': 1,
        'explanation': 'The baby is receiving maternal antibodies at Week 32, which will provide temporary immunity after birth.'
      },

      // Week 33 Questions
      {
        'week': 33,
        'question': 'What can the baby\'s eyes detect by Week 33?',
        'options': [
          'A) Colors',
          'B) Shapes',
          'C) Light - pupils can change size',
          'D) Distance'
        ],
        'correct': 2,
        'explanation': 'By Week 33, the baby\'s pupils can change size in response to light. Bones are hardening, but the skull remains flexible.'
      },
      {
        'week': 33,
        'question': 'Why does the skull remain soft and flexible at Week 33?',
        'options': [
          'A) It\'s not fully developed',
          'B) To allow passage through the birth canal',
          'C) To protect the brain',
          'D) To allow brain growth'
        ],
        'correct': 1,
        'explanation': 'The skull remains flexible and soft to allow the baby to pass through the birth canal during delivery, even though other bones are hardening.'
      },
      {
        'week': 33,
        'question': 'What is the baby\'s approximate weight at Week 33?',
        'options': [
          'A) 2.5 pounds',
          'B) 3.5 pounds',
          'C) 4.2 pounds (1.9 kg)',
          'D) 5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 33, the baby weighs approximately 4.2 pounds and measures about 19.4 inches total length.'
      },
      {
        'week': 33,
        'question': 'What is the baby practicing at Week 33?',
        'options': [
          'A) Walking',
          'B) Breathing movements and mouth movements',
          'C) Crying',
          'D) Chewing'
        ],
        'correct': 1,
        'explanation': 'The baby is practicing breathing movements and mouth movements like sucking at Week 33.'
      },
      {
        'week': 33,
        'question': 'What is becoming tighter at Week 33?',
        'options': [
          'A) Baby\'s grip',
          'B) Mother\'s skin',
          'C) The uterus is becoming increasingly crowded',
          'D) Baby\'s movements'
        ],
        'correct': 2,
        'explanation': 'The uterus is becoming increasingly crowded at Week 33, and movements may feel less pronounced but stronger.'
      },

      // Week 34 Questions
      {
        'week': 34,
        'question': 'What reaches the fingertips by Week 34?',
        'options': [
          'A) Bones',
          'B) Fingernails',
          'C) Skin',
          'D) Blood vessels'
        ],
        'correct': 1,
        'explanation': 'Fingernails reach the fingertips by Week 34. The baby weighs more than 4 1/2 pounds and measures nearly 12 inches from crown to rump.'
      },
      {
        'week': 34,
        'question': 'What happens to the baby\'s skin in Week 34?',
        'options': [
          'A) It becomes transparent',
          'B) It turns pink and smooths out',
          'C) It develops wrinkles',
          'D) It becomes covered in hair'
        ],
        'correct': 1,
        'explanation': 'The baby\'s skin is turning pink and smoothing out during Week 34 as more fat is deposited under the skin.'
      },
      {
        'week': 34,
        'question': 'What is the baby\'s approximate weight at Week 34?',
        'options': [
          'A) 3 pounds',
          'B) 4 pounds',
          'C) 4.7 pounds (2.1 kg)',
          'D) 5.5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 34, the baby weighs approximately 4.7 pounds and measures about 19.8 inches total length.'
      },
      {
        'week': 34,
        'question': 'What is the baby\'s position preference at Week 34?',
        'options': [
          'A) Still moving around',
          'B) Most babies are head-down',
          'C) Breech position is still possible',
          'D) Position doesn\'t matter'
        ],
        'correct': 1,
        'explanation': 'By Week 34, most babies have settled into a head-down position, though some may still turn.'
      },
      {
        'week': 34,
        'question': 'What can be measured with ultrasound at Week 34?',
        'options': [
          'A) Baby\'s future intelligence',
          'B) Baby\'s estimated weight and amniotic fluid volume',
          'C) Baby\'s gender',
          'D) Baby\'s personality'
        ],
        'correct': 1,
        'explanation': 'Ultrasound at Week 34 can measure the baby\'s estimated weight and amniotic fluid volume to monitor health.'
      },

      // Week 35 Questions
      {
        'week': 35,
        'question': 'How much space does the baby occupy in Week 35?',
        'options': [
          'A) About half the amniotic sac',
          'B) Most of the amniotic sac - less room to move',
          'C) A quarter of the sac',
          'D) Still has plenty of room'
        ],
        'correct': 1,
        'explanation': 'By Week 35, the baby fills most of the amniotic sac and has less room to move, though you\'ll still feel stretches, rolls, and wiggles.'
      },
      {
        'week': 35,
        'question': 'What important systems reach maturity by Week 35?',
        'options': [
          'A) Lungs and liver',
          'B) Heart and kidneys',
          'C) Brain and immune system',
          'D) Digestive and nervous system'
        ],
        'correct': 2,
        'explanation': 'The brain and immune system reach maturity by Week 35, two very important structures for life outside the womb.'
      },
      {
        'week': 35,
        'question': 'What is the baby\'s approximate weight at Week 35?',
        'options': [
          'A) 3.5 pounds',
          'B) 4.5 pounds',
          'C) 5.2 pounds (2.3 kg)',
          'D) 6 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 35, the baby weighs approximately 5.2 pounds and measures about 20.2 inches total length.'
      },
      {
        'week': 35,
        'question': 'What is the baby\'s lung maturity at Week 35?',
        'options': [
          'A) Not mature yet',
          'B) Becoming increasingly mature',
          'C) Fully mature and ready for breathing',
          'D) Stopped developing'
        ],
        'correct': 1,
        'explanation': 'The baby\'s lungs are becoming increasingly mature at Week 35, with good surfactant production for breathing.'
      },
      {
        'week': 35,
        'question': 'What medical test might be done at Week 35?',
        'options': [
          'A) Group B Streptococcus (GBS) screening',
          'B) Glucose test',
          'C) First trimester screening',
          'D) Amniocentesis'
        ],
        'correct': 0,
        'explanation': 'Group B Streptococcus (GBS) screening is typically done around Week 35-37 to check for bacteria that could affect the baby.'
      },

      // Week 36 Questions
      {
        'week': 36,
        'question': 'What position have most babies assumed by Week 36?',
        'options': [
          'A) Breech (feet first)',
          'B) Transverse (sideways)',
          'C) Head down',
          'D) Diagonal'
        ],
        'correct': 2,
        'explanation': 'Most babies have turned head down by Week 36 in preparation for birth. The skin is becoming smooth as more fat is added.'
      },
      {
        'week': 36,
        'question': 'What happens to the limbs in Week 36?',
        'options': [
          'A) They stop growing',
          'B) They become fully functional',
          'C) They start to look chubby',
          'D) They lose muscle'
        ],
        'correct': 2,
        'explanation': 'The limbs start to look chubby during Week 36 as more fat is added under the skin. The baby weighs around 6 to 6½ pounds.'
      },
      {
        'week': 36,
        'question': 'What is the baby\'s approximate weight at Week 36?',
        'options': [
          'A) 4 pounds',
          'B) 5 pounds',
          'C) 6 pounds (2.7 kg)',
          'D) 7 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 36, the baby weighs approximately 6 pounds and measures about 20.7 inches total length.'
      },
      {
        'week': 36,
        'question': 'What milestone is Week 36 often considered?',
        'options': [
          'A) Baby can be delivered anytime now',
          'B) Baby is considered viable',
          'C) Full term',
          'D) Baby is overdue'
        ],
        'correct': 0,
        'explanation': 'Week 36 is when delivery at any time would not be considered premature for most situations; baby is well-developed.'
      },
      {
        'week': 36,
        'question': 'What maternal preparation is important around Week 36?',
        'options': [
          'A) Stopping all exercise',
          'B) Labor sign recognition and final preparations',
          'C) Bed rest',
          'D) No special preparations'
        ],
        'correct': 1,
        'explanation': 'Around Week 36, mothers should familiarize themselves with labor signs and make final preparations for delivery.'
      },

      // Week 37 Questions
      {
        'week': 37,
        'question': 'What term classification does the baby reach at Week 37?',
        'options': [
          'A) Preterm',
          'B) Early term',
          'C) Full term',
          'D) Late term'
        ],
        'correct': 1,
        'explanation': 'At Week 37, the baby is considered \'early term.\' The baby can grasp things firmly, and the head may start moving into the pelvis.'
      },
      {
        'week': 37,
        'question': 'What might happen to prepare for birth in Week 37?',
        'options': [
          'A) Baby gains more weight',
          'B) Baby\'s head starts going down into the pelvis',
          'C) Baby opens eyes',
          'D) Baby starts crying'
        ],
        'correct': 1,
        'explanation': 'To prepare for birth, the baby\'s head might start going down into the pelvis during Week 37. This is called \'lightening\' or \'dropping.\''
      },
      {
        'week': 37,
        'question': 'What is the baby\'s approximate weight at Week 37?',
        'options': [
          'A) 5 pounds',
          'B) 6 pounds',
          'C) 6.3 pounds (2.85 kg)',
          'D) 7.5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 37, the baby weighs approximately 6.3 pounds and measures about 21.1 inches total length.'
      },
      {
        'week': 37,
        'question': 'What reflex is now well-developed at Week 37?',
        'options': [
          'A) Startle reflex only',
          'B) Sucking and rooting reflexes',
          'C) Walking reflex',
          'D) No reflexes yet'
        ],
        'correct': 1,
        'explanation': 'Sucking and rooting reflexes are now well-developed at Week 37, crucial for feeding after birth.'
      },
      {
        'week': 37,
        'question': 'What maternal symptoms might increase at Week 37?',
        'options': [
          'A) Nausea and vomiting',
          'B) Braxton-Hicks contractions and pelvic pressure',
          'C) Dizziness',
          'D) Shortness of breath only'
        ],
        'correct': 1,
        'explanation': 'Braxton-Hicks contractions and pelvic pressure often increase at Week 37 as the baby descends into the pelvis.'
      },

      // Week 38 Questions
      {
        'week': 38,
        'question': 'What measurement milestone occurs in Week 38?',
        'options': [
          'A) Baby reaches maximum length',
          'B) Head circumference equals belly circumference',
          'C) Baby weighs 10 pounds',
          'D) Baby is 20 inches long'
        ],
        'correct': 1,
        'explanation': 'By Week 38, the measurement around the baby\'s head and belly are about the same. Most lanugo is gone, and toenails reach toe tips.'
      },
      {
        'week': 38,
        'question': 'What is the typical weight range at Week 38?',
        'options': [
          'A) 3-4 pounds',
          'B) 4-5 pounds',
          'C) 5-6 pounds',
          'D) 6.5 pounds or more (some up to 9 pounds)'
        ],
        'correct': 3,
        'explanation': 'By Week 38, the baby might weigh about 6 1/2 pounds, though size varies and some babies may weigh nearly 9 pounds or more.'
      },
      {
        'week': 38,
        'question': 'What is the baby\'s approximate weight at Week 38?',
        'options': [
          'A) 5 pounds',
          'B) 6 pounds',
          'C) 6.8 pounds (3.1 kg)',
          'D) 8 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 38, the baby weighs approximately 6.8 pounds and measures about 21.6 inches total length.'
      },
      {
        'week': 38,
        'question': 'What is disappearing from the baby\'s body at Week 38?',
        'options': [
          'A) All lanugo',
          'B) Remaining lanugo is mostly gone',
          'C) Vernix caseosa',
          'D) Fingernails'
        ],
        'correct': 1,
        'explanation': 'Most lanugo is gone by Week 38, though some may remain in body folds. Vernix caseosa is still present in some areas.'
      },
      {
        'week': 38,
        'question': 'What medical check typically happens at Week 38?',
        'options': [
          'A) First ultrasound',
          'B) Cervical exam and position confirmation',
          'C) Amniocentesis',
          'D) No checks needed'
        ],
        'correct': 1,
        'explanation': 'At Week 38, cervical exams and position confirmation are part of regular prenatal visits to prepare for labor.'
      },

      // Week 39 Questions
      {
        'week': 39,
        'question': 'What term classification does the baby reach at Week 39?',
        'options': [
          'A) Early term',
          'B) Full term',
          'C) Late term',
          'D) Post term'
        ],
        'correct': 1,
        'explanation': 'At Week 39, the baby is considered \'full term.\' Fat is being added all over the body to keep the baby warm after birth.'
      },
      {
        'week': 39,
        'question': 'What gets larger during Week 39?',
        'options': [
          'A) Head',
          'B) Limbs',
          'C) Chest',
          'D) Eyes'
        ],
        'correct': 2,
        'explanation': 'The chest is getting larger during Week 39. Fat continues to be added all over the body to help with temperature regulation after birth.'
      },
      {
        'week': 39,
        'question': 'What is the baby\'s approximate weight at Week 39?',
        'options': [
          'A) 6 pounds',
          'B) 7 pounds',
          'C) 7.3 pounds (3.3 kg)',
          'D) 8.5 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 39, the baby weighs approximately 7.3 pounds and measures about 22 inches total length.'
      },
      {
        'week': 39,
        'question': 'What is the baby\'s appearance at Week 39?',
        'options': [
          'A) Very thin and wrinkled',
          'B) Round and chubby with smooth skin',
          'C) Bald',
          'D) Hairy all over'
        ],
        'correct': 1,
        'explanation': 'The baby has a round, chubby appearance with smooth skin by Week 39, ready for life outside the womb.'
      },
      {
        'week': 39,
        'question': 'What can mothers expect at Week 39?',
        'options': [
          'A) Labor could start anytime',
          'B) Guaranteed delivery this week',
          'C) No labor until Week 42',
          'D) Must be induced immediately'
        ],
        'correct': 0,
        'explanation': 'At Week 39, labor could start anytime, though the due date is only an estimate and many babies arrive after Week 40.'
      },

      // Week 40 Questions
      {
        'week': 40,
        'question': 'What does Week 40 represent?',
        'options': [
          'A) The earliest safe delivery date',
          'B) Your estimated due date',
          'C) The latest possible delivery date',
          'D) The start of post-term pregnancy'
        ],
        'correct': 1,
        'explanation': 'Week 40 is your estimated due date! However, this is just an estimate, and many people give birth before or after this date.'
      },
      {
        'week': 40,
        'question': 'What is the typical weight of a baby at Week 40?',
        'options': [
          'A) 5-6 pounds',
          'B) 6-7 pounds',
          'C) About 7 1/2 pounds (but healthy babies vary widely)',
          'D) 8-9 pounds'
        ],
        'correct': 2,
        'explanation': 'At Week 40, the baby typically weighs about 7 1/2 pounds and measures around 14 inches from crown to rump, though healthy babies come in many sizes.'
      },
      {
        'week': 40,
        'question': 'What is the baby\'s approximate total length at Week 40?',
        'options': [
          'A) 18 inches',
          'B) 20 inches',
          'C) 22 inches (50.8 cm)',
          'D) 24 inches'
        ],
        'correct': 2,
        'explanation': 'At Week 40, the baby measures approximately 22 inches total length from head to toe.'
      },
      {
        'week': 40,
        'question': 'Is delivery guaranteed at Week 40?',
        'options': [
          'A) Yes, all babies arrive at Week 40',
          'B) No, the due date is an estimate',
          'C) Only if induced',
          'D) Only for girls'
        ],
        'correct': 1,
        'explanation': 'Week 40 is an estimate only. Only about 5% of babies arrive on their due date, and many arrive in the weeks before or after.'
      },
      {
        'week': 40,
        'question': 'What is the baby\'s readiness at Week 40?',
        'options': [
          'A) Baby is not ready yet',
          'B) Baby is fully developed and ready for life outside the womb',
          'C) Baby needs more time',
          'D) Baby cannot survive outside the womb'
        ],
        'correct': 1,
        'explanation': 'By Week 40, the baby is fully developed with all systems mature and ready for life outside the womb. Labor can begin anytime!'
      },
    ];
  }



  List<Map<String, dynamic>> _getGeneralPregnancyQuestions() {
    return [
      {
        'question': 'What is the most important nutrient during pregnancy?',
        'options': ['Folic Acid', 'Iron', 'Calcium', 'All of the above'],
        'correct': 3,
        'explanation': 'All these nutrients are crucial for a healthy pregnancy.'
      },
      {
        'question': 'What should you avoid during pregnancy?',
        'options': ['Raw sushi', 'Alcohol', 'Unpasteurized milk', 'All of the above'],
        'correct': 3,
        'explanation': 'These can contain harmful bacteria or affect fetal development.'
      },
    ];
  }

  void selectAnswer(int answerIndex) {
    if (showCorrectAnswer) return; // Prevent multiple selections

    setState(() {
      selectedAnswer = answerIndex;
      showCorrectAnswer = true;

      // Update score if correct
      if (answerIndex == questions[currentQuestion]['correct']) {
        score++;
      }
    });
  }

  void nextQuestion() {
    if (currentQuestion < questions.length - 1) {
      setState(() {
        currentQuestion++;
        selectedAnswer = null;
        showCorrectAnswer = false;
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
      showCorrectAnswer = false;
      startTime = DateTime.now();
    });
  }

  Widget _buildAnswerOption(int index, String option, bool isSelected, bool showCorrect) {
    final isCorrectAnswer = index == questions[currentQuestion]['correct'];
    final isWrongSelection = isSelected && !isCorrectAnswer;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey[300]!;
    Color textColor = Colors.black87;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (showCorrect) {
      if (isCorrectAnswer) {
        backgroundColor = const Color(0xFF10B981);
        borderColor = const Color(0xFF10B981);
        textColor = Colors.white;
        icon = Icons.check_circle;
        iconColor = Colors.white;
      } else if (isWrongSelection) {
        backgroundColor = const Color(0xFFEF4444);
        borderColor = const Color(0xFFEF4444);
        textColor = Colors.white;
        icon = Icons.cancel;
        iconColor = Colors.white;
      }
    } else if (isSelected) {
      backgroundColor = const Color(0xFFB794F4);
      borderColor = const Color(0xFFB794F4);
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => selectAnswer(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.white : Colors.grey[200],
                border: Border.all(
                  color: isSelected ? borderColor : Colors.grey[400]!,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: 18,
                color: borderColor,
              )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
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

                  // Answer Options
                  ...List.generate(q['options'].length, (i) {
                    return _buildAnswerOption(
                      i,
                      q['options'][i],
                      selectedAnswer == i,
                      showCorrectAnswer,
                    );
                  }),

                  // Explanation (shown after answer selection)
                  if (showCorrectAnswer) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedAnswer == q['correct']
                            ? const Color(0xFF10B981).withOpacity(0.1)
                            : const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedAnswer == q['correct']
                              ? const Color(0xFF10B981).withOpacity(0.3)
                              : const Color(0xFFEF4444).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            selectedAnswer == q['correct']
                                ? Icons.check_circle
                                : Icons.info,
                            color: selectedAnswer == q['correct']
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedAnswer == q['correct']
                                      ? 'Correct!'
                                      : 'Explanation:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: selectedAnswer == q['correct']
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  q['explanation'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                onPressed: showCorrectAnswer ? nextQuestion : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: showCorrectAnswer
                      ? const Color(0xFFB794F4)
                      : Colors.grey[300],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: showCorrectAnswer ? 4 : 0,
                ),
                child: Text(
                  currentQuestion < questions.length - 1 ? 'Next Question' : 'Finish Quiz',
                  style: TextStyle(
                    color: showCorrectAnswer ? Colors.white : Colors.grey[600],
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

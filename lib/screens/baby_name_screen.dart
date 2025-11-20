import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

class BabyNameScreen extends StatefulWidget {
  const BabyNameScreen({super.key});

  @override
  State<BabyNameScreen> createState() => _BabyNameScreenState();
}

class _BabyNameScreenState extends State<BabyNameScreen> {
  final String apiKey = "AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE";
  late GeminiService geminiService;

  int currentQuestion = 0;
  bool showResults = false;
  bool loading = false;
  List<Map<String, String>> generatedNames = [];
  Set<String> favoriteNames = {};

  // User answers
  String selectedGender = '';
  String selectedCulture = '';
  String selectedLength = '';
  String selectedMeaning = '';
  String selectedStyle = '';
  String selectedReligion = '';

  final List<Map<String, dynamic>> questions = [
    {
      'title': 'What gender are you planning for?',
      'options': [
        {'label': 'Boy', 'value': 'boy'},
        {'label': 'Girl', 'value': 'girl'},
        {'label': 'Gender Neutral', 'value': 'neutral'},
        {'label': 'It\'s a surprise!', 'value': 'surprise'},
      ],
    },
    {
      'title': 'Which religion would you prefer?',
      'options': [
        {'label': 'Hindu', 'value': 'hindu'},
        {'label': 'Muslim', 'value': 'muslim'},
        {'label': 'Christian', 'value': 'christian'},
        {'label': 'Sikh', 'value': 'sikh'},
        {'label': 'Jain', 'value': 'jain'},
        {'label': 'Buddhist', 'value': 'buddhist'},
        {'label': 'Any Religion', 'value': 'any'},
      ],
    },
    {
      'title': 'Which cultural origin resonates with you?',
      'options': [
        {'label': 'Traditional/Cultural', 'value': 'traditional'},
        {'label': 'Modern/Contemporary', 'value': 'modern'},
        {'label': 'International', 'value': 'international'},
        {'label': 'Mix of different origins', 'value': 'mixed'},
      ],
    },
    {
      'title': 'What length of name do you prefer?',
      'options': [
        {'label': 'Short (2-4 letters)', 'value': 'short'},
        {'label': 'Medium (5-7 letters)', 'value': 'medium'},
        {'label': 'Long (8+ letters)', 'value': 'long'},
        {'label': 'Any length is fine', 'value': 'any'},
      ],
    },
    {
      'title': 'What kind of meaning appeals to you?',
      'options': [
        {'label': 'Nature & Elements', 'value': 'nature'},
        {'label': 'Strength & Power', 'value': 'strength'},
        {'label': 'Love & Joy', 'value': 'love'},
        {'label': 'Wisdom & Intelligence', 'value': 'wisdom'},
        {'label': 'Spiritual & Divine', 'value': 'spiritual'},
      ],
    },
    {
      'title': 'What style reflects your personality?',
      'options': [
        {'label': 'Classic & Timeless', 'value': 'classic'},
        {'label': 'Unique & Rare', 'value': 'unique'},
        {'label': 'Trendy & Popular', 'value': 'trendy'},
        {'label': 'Family Heritage', 'value': 'heritage'},
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    geminiService = GeminiService(apiKey);
  }

  void _selectOption(String value) {
    setState(() {
      switch (currentQuestion) {
        case 0:
          selectedGender = value;
          break;
        case 1:
          selectedReligion = value;
          break;
        case 2:
          selectedCulture = value;
          break;
        case 3:
          selectedLength = value;
          break;
        case 4:
          selectedMeaning = value;
          break;
        case 5:
          selectedStyle = value;
          break;
      }
    });

    // Wait a bit then move to next question or generate results
    Future.delayed(const Duration(milliseconds: 400), () {
      if (currentQuestion < questions.length - 1) {
        setState(() {
          currentQuestion++;
        });
      } else {
        _generateNames();
      }
    });
  }

  Future<void> _generateNames() async {
    setState(() {
      loading = true;
    });

    String genderText = selectedGender == 'surprise' ? 'gender neutral' : selectedGender;
    String religionText = selectedReligion == 'any' ? 'any religion' : selectedReligion;

    String prompt = """Generate 12 baby names based on these preferences:
- Gender: $genderText
- Religion: $religionText
- Cultural Style: $selectedCulture
- Length Preference: $selectedLength
- Meaning Type: $selectedMeaning
- Name Style: $selectedStyle

Please provide exactly 12 names with their meanings and origins.
Format STRICTLY as:
Name|Meaning|Origin

Example:
Aria|Melody, air|Italian
Leo|Lion|Latin
Maya|Illusion, dream|Sanskrit

Generate 12 names now:""";

    try {
      String response = await geminiService.getResponse(prompt);

      List<Map<String, String>> names = [];
      List<String> lines = response.split('\n');

      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty || line.length < 3) continue;

        // Remove common formatting
        line = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');
        line = line.replaceAll(RegExp(r'^[-•*]\s*'), '');

        List<String> parts = line.split('|');

        if (parts.length >= 3) {
          String name = parts[0].trim().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
          String meaning = parts[1].trim();
          String origin = parts[2].trim();

          if (name.isNotEmpty && name.length > 1 && !RegExp(r'\d').hasMatch(name)) {
            names.add({
              'name': name,
              'meaning': meaning,
              'origin': origin,
            });
          }
        }
      }

      setState(() {
        generatedNames = names.take(12).toList();
        loading = false;
        showResults = true;
      });

      if (generatedNames.isEmpty) {
        _showSnackbar('Unable to generate names. Please try again.');
        setState(() {
          showResults = false;
          currentQuestion = 0;
        });
      }

    } catch (e) {
      setState(() {
        loading = false;
      });
      _showSnackbar('Error generating names: ${e.toString()}');
    }
  }

  void _toggleFavorite(String name) {
    setState(() {
      if (favoriteNames.contains(name)) {
        favoriteNames.remove(name);
      } else {
        favoriteNames.add(name);
      }
    });
  }

  void _retakeQuiz() {
    setState(() {
      currentQuestion = 0;
      showResults = false;
      generatedNames.clear();
      favoriteNames.clear();
      selectedGender = '';
      selectedReligion = '';
      selectedCulture = '';
      selectedLength = '';
      selectedMeaning = '';
      selectedStyle = '';
    });
  }

  void _suggestMoreNames() {
    setState(() {
      showResults = false;
      loading = false;
    });
    _generateNames();
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF2C3E50),
      ),
    );
  }

  double _getProgress() {
    return (currentQuestion + 1) / questions.length;
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3E5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFB794F4),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Baby Names',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFB794F4),
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                'Finding perfect names for you...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (showResults) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3E5F5),
        appBar: AppBar(
          backgroundColor: const Color(0xFFB794F4),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Baby Names',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          actions: [
            // Suggest More Names Button in AppBar
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                onPressed: _suggestMoreNames,
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: 'Suggest More Names',
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Results Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB794F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.card_giftcard,
                      size: 40,
                      color: Color(0xFFB794F4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Personalized Names',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on your preferences for ${selectedGender == "surprise" ? "surprise gender" : selectedGender} names, $selectedReligion religion, $selectedStyle style',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: _retakeQuiz,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFB794F4)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'Retake Quiz',
                          style: TextStyle(
                            color: Color(0xFFB794F4),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: _suggestMoreNames,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB794F4),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 18, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              'More Names',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search names or meanings...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Name Suggestions Title with Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Name Suggestions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB794F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${generatedNames.length} names',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFB794F4),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Names List
            Expanded(
              child: generatedNames.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      size: 60,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No names generated yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _suggestMoreNames,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB794F4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Generate Names',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: generatedNames.length,
                itemBuilder: (context, index) {
                  final nameData = generatedNames[index];
                  final name = nameData['name']!;
                  final meaning = nameData['meaning']!;
                  final origin = nameData['origin']!;
                  final isFavorite = favoriteNames.contains(name);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Name Initial Circle
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB794F4).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              name.substring(0, 1).toUpperCase(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFB794F4),
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
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2C3E50),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                meaning,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                origin,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleFavorite(name),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[400],
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Suggest More Names Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _suggestMoreNames,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB794F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 2,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Suggest More Names',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Questions Screen
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB794F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Baby Names',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB794F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(
                      Icons.face_retouching_natural,
                      size: 40,
                      color: Color(0xFFB794F4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Let\'s Find Your Perfect Name!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Answer a few questions to get personalized suggestions',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Question Card
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Question ${currentQuestion + 1} of ${questions.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(_getProgress() * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFFB794F4),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _getProgress(),
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFB794F4),
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      questions[currentQuestion]['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E50),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: questions[currentQuestion]['options'].length,
                        itemBuilder: (context, index) {
                          final option = questions[currentQuestion]['options'][index];
                          return GestureDetector(
                            onTap: () => _selectOption(option['value']),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      option['label'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF2C3E50),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import '../services/gemini_service.dart';
//
// class BabyNameScreen extends StatefulWidget {
//   const BabyNameScreen({super.key});
//
//   @override
//   State<BabyNameScreen> createState() => _BabyNameScreenState();
// }
//
// class _BabyNameScreenState extends State<BabyNameScreen> {
//   final String apiKey = "AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE";
//   late GeminiService geminiService;
//
//   int currentQuestion = 0;
//   bool showResults = false;
//   bool loading = false;
//   List<Map<String, String>> generatedNames = [];
//   Set<String> favoriteNames = {};
//
//   // User answers
//   String selectedGender = '';
//   String selectedCulture = '';
//   String selectedLength = '';
//   String selectedMeaning = '';
//   String selectedStyle = '';
//
//   final List<Map<String, dynamic>> questions = [
//     {
//       'title': 'What gender are you planning for?',
//       'options': [
//         {'label': 'Boy', 'value': 'boy'},
//         {'label': 'Girl', 'value': 'girl'},
//         {'label': 'Gender Neutral', 'value': 'neutral'},
//         {'label': 'It\'s a surprise!', 'value': 'surprise'},
//       ],
//     },
//     {
//       'title': 'Which cultural origin resonates with you?',
//       'options': [
//         {'label': 'Traditional/Cultural', 'value': 'traditional'},
//         {'label': 'Modern/Contemporary', 'value': 'modern'},
//         {'label': 'International', 'value': 'international'},
//         {'label': 'Mix of different origins', 'value': 'mixed'},
//       ],
//     },
//     {
//       'title': 'What length of name do you prefer?',
//       'options': [
//         {'label': 'Short (2-4 letters)', 'value': 'short'},
//         {'label': 'Medium (5-7 letters)', 'value': 'medium'},
//         {'label': 'Long (8+ letters)', 'value': 'long'},
//         {'label': 'Any length is fine', 'value': 'any'},
//       ],
//     },
//     {
//       'title': 'What kind of meaning appeals to you?',
//       'options': [
//         {'label': 'Nature & Elements', 'value': 'nature'},
//         {'label': 'Strength & Power', 'value': 'strength'},
//         {'label': 'Love & Joy', 'value': 'love'},
//         {'label': 'Wisdom & Intelligence', 'value': 'wisdom'},
//         {'label': 'Spiritual & Divine', 'value': 'spiritual'},
//       ],
//     },
//     {
//       'title': 'What style reflects your personality?',
//       'options': [
//         {'label': 'Classic & Timeless', 'value': 'classic'},
//         {'label': 'Unique & Rare', 'value': 'unique'},
//         {'label': 'Trendy & Popular', 'value': 'trendy'},
//         {'label': 'Family Heritage', 'value': 'heritage'},
//       ],
//     },
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     geminiService = GeminiService(apiKey);
//   }
//
//   void _selectOption(String value) {
//     setState(() {
//       switch (currentQuestion) {
//         case 0:
//           selectedGender = value;
//           break;
//         case 1:
//           selectedCulture = value;
//           break;
//         case 2:
//           selectedLength = value;
//           break;
//         case 3:
//           selectedMeaning = value;
//           break;
//         case 4:
//           selectedStyle = value;
//           break;
//       }
//     });
//
//     // Wait a bit then move to next question or generate results
//     Future.delayed(const Duration(milliseconds: 400), () {
//       if (currentQuestion < questions.length - 1) {
//         setState(() {
//           currentQuestion++;
//         });
//       } else {
//         _generateNames();
//       }
//     });
//   }
//
//   Future<void> _generateNames() async {
//     setState(() {
//       loading = true;
//     });
//
//     String genderText = selectedGender == 'surprise' ? 'gender neutral' : selectedGender;
//
//     String prompt = """Generate 10 baby names based on these preferences:
// - Gender: $genderText
// - Cultural Style: $selectedCulture
// - Length Preference: $selectedLength
// - Meaning Type: $selectedMeaning
// - Name Style: $selectedStyle
//
// Please provide exactly 10 names with their meanings and origins.
// Format STRICTLY as:
// Name|Meaning|Origin
//
// Example:
// Aria|Melody, air|Italian
// Leo|Lion|Latin
// Maya|Illusion, dream|Sanskrit
//
// Generate 10 names now:""";
//
//     try {
//       String response = await geminiService.getResponse(prompt);
//
//       List<Map<String, String>> names = [];
//       List<String> lines = response.split('\n');
//
//       for (String line in lines) {
//         line = line.trim();
//         if (line.isEmpty || line.length < 3) continue;
//
//         // Remove common formatting
//         line = line.replaceAll(RegExp(r'^\d+[\.\)]\s*'), '');
//         line = line.replaceAll(RegExp(r'^[-•*]\s*'), '');
//
//         List<String> parts = line.split('|');
//
//         if (parts.length >= 3) {
//           String name = parts[0].trim().replaceAll(RegExp(r'[^a-zA-Z\s]'), '');
//           String meaning = parts[1].trim();
//           String origin = parts[2].trim();
//
//           if (name.isNotEmpty && name.length > 1 && !RegExp(r'\d').hasMatch(name)) {
//             names.add({
//               'name': name,
//               'meaning': meaning,
//               'origin': origin,
//             });
//           }
//         }
//       }
//
//       setState(() {
//         generatedNames = names.take(10).toList();
//         loading = false;
//         showResults = true;
//       });
//
//       if (generatedNames.isEmpty) {
//         _showSnackbar('Unable to generate names. Please try again.');
//         setState(() {
//           showResults = false;
//           currentQuestion = 0;
//         });
//       }
//
//     } catch (e) {
//       setState(() {
//         loading = false;
//       });
//       _showSnackbar('Error generating names: ${e.toString()}');
//     }
//   }
//
//   void _toggleFavorite(String name) {
//     setState(() {
//       if (favoriteNames.contains(name)) {
//         favoriteNames.remove(name);
//       } else {
//         favoriteNames.add(name);
//       }
//     });
//   }
//
//   void _retakeQuiz() {
//     setState(() {
//       currentQuestion = 0;
//       showResults = false;
//       generatedNames.clear();
//       favoriteNames.clear();
//       selectedGender = '';
//       selectedCulture = '';
//       selectedLength = '';
//       selectedMeaning = '';
//       selectedStyle = '';
//     });
//   }
//
//   void _suggestMoreNames() {
//     setState(() {
//       showResults = false;
//       loading = false;
//     });
//     _generateNames();
//   }
//
//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//         backgroundColor: const Color(0xFF2C3E50),
//       ),
//     );
//   }
//
//   double _getProgress() {
//     return (currentQuestion + 1) / questions.length;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF3E5F5),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFB794F4),
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'Baby Names',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(
//                 color: Color(0xFFB794F4),
//                 strokeWidth: 3,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Finding perfect names for you...',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey[700],
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (showResults) {
//       return Scaffold(
//         backgroundColor: const Color(0xFFF3E5F5),
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFB794F4),
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: const Text(
//             'Baby Names',
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//           ),
//         ),
//         body: Column(
//           children: [
//             // Results Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFB794F4).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: const Icon(
//                       Icons.card_giftcard,
//                       size: 40,
//                       color: Color(0xFFB794F4),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Your Personalized Names',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2C3E50),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Based on your preferences for ${selectedGender == "surprise" ? "surprise gender" : selectedGender} names, $selectedStyle style, $selectedMeaning meanings, here are some perfect matches:',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 16),
//                   OutlinedButton(
//                     onPressed: _retakeQuiz,
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Color(0xFFB794F4)),
//                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(25),
//                       ),
//                     ),
//                     child: const Text(
//                       'Retake Quiz',
//                       style: TextStyle(
//                         color: Color(0xFFB794F4),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//             // Search Bar
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(30),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search names or meanings...',
//                     hintStyle: TextStyle(color: Colors.grey[400]),
//                     prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                     border: InputBorder.none,
//                     contentPadding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 15,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 20),
//
//             // Name Suggestions Title
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: Text(
//                   'Name Suggestions',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Names List
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 itemCount: generatedNames.length,
//                 itemBuilder: (context, index) {
//                   final nameData = generatedNames[index];
//                   final name = nameData['name']!;
//                   final meaning = nameData['meaning']!;
//                   final origin = nameData['origin']!;
//                   final isFavorite = favoriteNames.contains(name);
//
//                   return Container(
//                     margin: const EdgeInsets.only(bottom: 12),
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(16),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.05),
//                           blurRadius: 8,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 name,
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF2C3E50),
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 meaning,
//                                 style: TextStyle(
//                                   fontSize: 14,
//                                   color: Colors.grey[700],
//                                   height: 1.3,
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 origin,
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         IconButton(
//                           onPressed: () => _toggleFavorite(name),
//                           icon: Icon(
//                             isFavorite ? Icons.favorite : Icons.favorite_border,
//                             color: isFavorite ? Colors.red : Colors.grey[400],
//                             size: 24,
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//
//             // Suggest More Names Button
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: SizedBox(
//                 width: double.infinity,
//                 height: 50,
//                 child: ElevatedButton(
//                   onPressed: _suggestMoreNames,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xFFB794F4),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     elevation: 2,
//                   ),
//                   child: const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.refresh, color: Colors.white),
//                       SizedBox(width: 8),
//                       Text(
//                         'Suggest More Names',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // Questions Screen
//     return Scaffold(
//       backgroundColor: const Color(0xFFF3E5F5),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFB794F4),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Baby Names',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(24),
//               margin: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 4),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFB794F4).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(50),
//                     ),
//                     child: const Icon(
//                       Icons.card_giftcard,
//                       size: 40,
//                       color: Color(0xFFB794F4),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   const Text(
//                     'Let\'s Find Your Perfect Name!',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF2C3E50),
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Answer a few questions to get personalized suggestions',
//                     style: TextStyle(
//                       fontSize: 13,
//                       color: Colors.grey[600],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//
//             // Question Card
//             Expanded(
//               child: Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(24),
//                 margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.05),
//                       blurRadius: 10,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Question ${currentQuestion + 1} of ${questions.length}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[600],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           '${(_getProgress() * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Color(0xFFB794F4),
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: LinearProgressIndicator(
//                         value: _getProgress(),
//                         backgroundColor: Colors.grey[200],
//                         valueColor: const AlwaysStoppedAnimation<Color>(
//                           Color(0xFFB794F4),
//                         ),
//                         minHeight: 8,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                     Text(
//                       questions[currentQuestion]['title'],
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF2C3E50),
//                         height: 1.3,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Expanded(
//                       child: ListView.builder(
//                         itemCount: questions[currentQuestion]['options'].length,
//                         itemBuilder: (context, index) {
//                           final option = questions[currentQuestion]['options'][index];
//                           return GestureDetector(
//                             onTap: () => _selectOption(option['value']),
//                             child: Container(
//                               margin: const EdgeInsets.only(bottom: 12),
//                               padding: const EdgeInsets.all(18),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFF8F9FA),
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(
//                                   color: Colors.grey[200]!,
//                                   width: 1.5,
//                                 ),
//                               ),
//                               child: Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       option['label'],
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         color: Color(0xFF2C3E50),
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.chevron_right,
//                                     color: Colors.grey[400],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import '../services/gemini_service.dart';
// //
// // class BabyNameScreen extends StatefulWidget {
// //   const BabyNameScreen({super.key});
// //
// //   @override
// //   State<BabyNameScreen> createState() => _BabyNameScreenState();
// // }
// //
// // class _BabyNameScreenState extends State<BabyNameScreen> {
// //   final TextEditingController _startingLetterController = TextEditingController();
// //
// //   String selectedGender = '';
// //   String selectedReligion = '';
// //   List<String> generatedNames = [];
// //   bool loading = false;
// //   String errorMessage = '';
// //
// //   final String apiKey = "AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE";
// //   late GeminiService geminiService;
// //
// //   final List<Map<String, dynamic>> religions = [
// //     {'name': 'Hindu', 'icon': Icons.self_improvement, 'color': Color(0xFFFF9800)},
// //     {'name': 'Muslim', 'icon': Icons.mosque, 'color': Color(0xFF4CAF50)},
// //     {'name': 'Christian', 'icon': Icons.church, 'color': Color(0xFF9C27B0)},
// //     {'name': 'Sikh', 'icon': Icons.account_balance, 'color': Color(0xFF2196F3)},
// //   ];
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     geminiService = GeminiService(apiKey);
// //   }
// //
// //   Future<void> generateNames() async {
// //     final gender = selectedGender.toLowerCase();
// //     final religion = selectedReligion;
// //     final letter = _startingLetterController.text.trim().toUpperCase();
// //
// //     if (gender.isEmpty) {
// //       _showSnackbar('Please select a gender (Boy/Girl).');
// //       return;
// //     }
// //     if (religion.isEmpty) {
// //       _showSnackbar('Please select a religion.');
// //       return;
// //     }
// //     if (letter.isEmpty) {
// //       _showSnackbar('Please enter a starting letter.');
// //       return;
// //     }
// //
// //     setState(() {
// //       loading = true;
// //       generatedNames = [];
// //       errorMessage = '';
// //     });
// //
// //     String prompt = """Generate 8 authentic $religion baby $gender names that start with the letter '$letter'.
// // These should be traditional and culturally appropriate $religion names.
// // Format: Only comma-separated names, no numbers, no explanations.
// // Example: Aarav, Arjun, Aditya, Aayush, Aryan, Arnav, Advait, Ansh
// //
// // $religion $gender names starting with '$letter':""";
// //
// //     try {
// //       String response = await geminiService.getResponse(prompt);
// //
// //       List<String> names = response
// //           .split(RegExp(r'[,\n]'))
// //           .map((e) => e.trim())
// //           .where((e) => e.isNotEmpty && e.length > 1)
// //           .toList();
// //
// //       names = names.map((name) {
// //         return name.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').trim();
// //       }).where((name) =>
// //       name.length > 1 &&
// //           name[0].toUpperCase() == letter &&
// //           !RegExp(r'\d').hasMatch(name)
// //       ).take(8).toList();
// //
// //       setState(() {
// //         generatedNames = names.isNotEmpty ? names : [];
// //         loading = false;
// //         if (names.isEmpty) {
// //           errorMessage = 'Unable to generate names. Please try a different letter.';
// //         }
// //       });
// //
// //     } catch (e) {
// //       setState(() {
// //         loading = false;
// //         errorMessage = 'Error: ${e.toString()}';
// //         generatedNames = [];
// //       });
// //       _showSnackbar('Error generating names: ${e.toString()}');
// //     }
// //   }
// //
// //   void _showSnackbar(String message) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
// //         backgroundColor: const Color(0xFF2C3E50),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   void dispose() {
// //     _startingLetterController.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF8F9FA),
// //       appBar: AppBar(
// //         elevation: 0,
// //         title: Text(
// //           "Baby Name Generator",
// //           style: GoogleFonts.poppins(
// //             fontWeight: FontWeight.w700,
// //             fontSize: 20,
// //             color: Colors.white,
// //           ),
// //         ),
// //         centerTitle: true,
// //         flexibleSpace: Container(
// //           decoration: const BoxDecoration(
// //             gradient: LinearGradient(
// //               colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
// //               begin: Alignment.topLeft,
// //               end: Alignment.bottomRight,
// //             ),
// //           ),
// //         ),
// //       ),
// //       body: SingleChildScrollView(
// //         child: Padding(
// //           padding: const EdgeInsets.all(20),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.stretch,
// //             children: [
// //               // Header Card
// //               Card(
// //                 elevation: 4,
// //                 shape: RoundedRectangleBorder(
// //                   borderRadius: BorderRadius.circular(16),
// //                 ),
// //                 child: Padding(
// //                   padding: const EdgeInsets.all(20),
// //                   child: Column(
// //                     children: [
// //                       Icon(
// //                         Icons.child_care_outlined,
// //                         size: 48,
// //                         color: const Color(0xFF3498DB),
// //                       ),
// //                       const SizedBox(height: 10),
// //                       Text(
// //                         "Find the Perfect Name",
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 22,
// //                           fontWeight: FontWeight.bold,
// //                           color: const Color(0xFF2C3E50),
// //                         ),
// //                       ),
// //                       const SizedBox(height: 6),
// //                       Text(
// //                         "AI-powered culturally authentic name suggestions",
// //                         textAlign: TextAlign.center,
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 13,
// //                           color: Colors.grey[600],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 28),
// //
// //               // Gender Selection
// //               Text(
// //                 "Select Gender",
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 15,
// //                   fontWeight: FontWeight.w600,
// //                   color: const Color(0xFF2C3E50),
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               Row(
// //                 children: [
// //                   Expanded(
// //                     child: GestureDetector(
// //                       onTap: () => setState(() => selectedGender = 'boy'),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         decoration: BoxDecoration(
// //                           color: selectedGender == 'boy'
// //                               ? const Color(0xFF5DADE2)
// //                               : Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           border: Border.all(
// //                             color: selectedGender == 'boy'
// //                                 ? const Color(0xFF3498DB)
// //                                 : Colors.grey[300]!,
// //                             width: 1.5,
// //                           ),
// //                           boxShadow: [
// //                             if (selectedGender == 'boy')
// //                               BoxShadow(
// //                                 color: const Color(0xFF3498DB).withOpacity(0.2),
// //                                 blurRadius: 6,
// //                                 offset: const Offset(0, 3),
// //                               ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           children: [
// //                             Icon(
// //                               Icons.boy_outlined,
// //                               size: 36,
// //                               color: selectedGender == 'boy'
// //                                   ? Colors.white
// //                                   : const Color(0xFF5DADE2),
// //                             ),
// //                             const SizedBox(height: 6),
// //                             Text(
// //                               "Boy",
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 15,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: selectedGender == 'boy'
// //                                     ? Colors.white
// //                                     : const Color(0xFF2C3E50),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 16),
// //                   Expanded(
// //                     child: GestureDetector(
// //                       onTap: () => setState(() => selectedGender = 'girl'),
// //                       child: AnimatedContainer(
// //                         duration: const Duration(milliseconds: 200),
// //                         padding: const EdgeInsets.symmetric(vertical: 14),
// //                         decoration: BoxDecoration(
// //                           color: selectedGender == 'girl'
// //                               ? const Color(0xFFF06292)
// //                               : Colors.white,
// //                           borderRadius: BorderRadius.circular(12),
// //                           border: Border.all(
// //                             color: selectedGender == 'girl'
// //                                 ? const Color(0xFFE91E63)
// //                                 : Colors.grey[300]!,
// //                             width: 1.5,
// //                           ),
// //                           boxShadow: [
// //                             if (selectedGender == 'girl')
// //                               BoxShadow(
// //                                 color: const Color(0xFFE91E63).withOpacity(0.2),
// //                                 blurRadius: 6,
// //                                 offset: const Offset(0, 3),
// //                               ),
// //                           ],
// //                         ),
// //                         child: Column(
// //                           children: [
// //                             Icon(
// //                               Icons.girl_outlined,
// //                               size: 36,
// //                               color: selectedGender == 'girl'
// //                                   ? Colors.white
// //                                   : const Color(0xFFF06292),
// //                             ),
// //                             const SizedBox(height: 6),
// //                             Text(
// //                               "Girl",
// //                               style: GoogleFonts.poppins(
// //                                 fontSize: 15,
// //                                 fontWeight: FontWeight.w600,
// //                                 color: selectedGender == 'girl'
// //                                     ? Colors.white
// //                                     : const Color(0xFF2C3E50),
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 24),
// //
// //               // Religion Selection
// //               Text(
// //                 "Select Religion",
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 15,
// //                   fontWeight: FontWeight.w600,
// //                   color: const Color(0xFF2C3E50),
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               GridView.builder(
// //                 shrinkWrap: true,
// //                 physics: const NeverScrollableScrollPhysics(),
// //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                   crossAxisCount: 2,
// //                   crossAxisSpacing: 12,
// //                   mainAxisSpacing: 12,
// //                   childAspectRatio: 1.4,
// //                 ),
// //                 itemCount: religions.length,
// //                 itemBuilder: (context, index) {
// //                   final religion = religions[index];
// //                   final isSelected = selectedReligion == religion['name'];
// //
// //                   return GestureDetector(
// //                     onTap: () => setState(() => selectedReligion = religion['name']),
// //                     child: AnimatedContainer(
// //                       duration: const Duration(milliseconds: 200),
// //                       decoration: BoxDecoration(
// //                         color: isSelected ? religion['color'] : Colors.white,
// //                         borderRadius: BorderRadius.circular(12),
// //                         border: Border.all(
// //                           color: isSelected
// //                               ? religion['color']
// //                               : Colors.grey[300]!,
// //                           width: 1.5,
// //                         ),
// //                         boxShadow: [
// //                           if (isSelected)
// //                             BoxShadow(
// //                               color: (religion['color'] as Color).withOpacity(0.3),
// //                               blurRadius: 6,
// //                               offset: const Offset(0, 3),
// //                             ),
// //                         ],
// //                       ),
// //                       child: Column(
// //                         mainAxisAlignment: MainAxisAlignment.center,
// //                         children: [
// //                           Icon(
// //                             religion['icon'],
// //                             size: 32,
// //                             color: isSelected ? Colors.white : religion['color'],
// //                           ),
// //                           const SizedBox(height: 8),
// //                           Text(
// //                             religion['name'],
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 14,
// //                               fontWeight: FontWeight.w600,
// //                               color: isSelected ? Colors.white : const Color(0xFF2C3E50),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //               const SizedBox(height: 24),
// //
// //               // Starting Letter Input
// //               Text(
// //                 "Starting Letter",
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 15,
// //                   fontWeight: FontWeight.w600,
// //                   color: const Color(0xFF2C3E50),
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               TextField(
// //                 controller: _startingLetterController,
// //                 maxLength: 1,
// //                 textCapitalization: TextCapitalization.characters,
// //                 style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
// //                 decoration: InputDecoration(
// //                   hintText: "e.g., A",
// //                   hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
// //                   prefixIcon: const Icon(Icons.abc, color: Color(0xFF5DADE2)),
// //                   filled: true,
// //                   fillColor: Colors.white,
// //                   counterText: "",
// //                   contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 28),
// //
// //               // Generate Button
// //               Container(
// //                 height: 52,
// //                 decoration: BoxDecoration(
// //                   gradient: const LinearGradient(
// //                     colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
// //                     begin: Alignment.topLeft,
// //                     end: Alignment.bottomRight,
// //                   ),
// //                   borderRadius: BorderRadius.circular(12),
// //                   boxShadow: [
// //                     BoxShadow(
// //                       color: const Color(0xFF3498DB).withOpacity(0.3),
// //                       blurRadius: 8,
// //                       offset: const Offset(0, 4),
// //                     ),
// //                   ],
// //                 ),
// //                 child: ElevatedButton(
// //                   onPressed: loading ? null : generateNames,
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Colors.transparent,
// //                     shadowColor: Colors.transparent,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                     ),
// //                     padding: EdgeInsets.zero,
// //                   ),
// //                   child: loading
// //                       ? const SizedBox(
// //                     height: 24,
// //                     width: 24,
// //                     child: CircularProgressIndicator(
// //                       color: Colors.white,
// //                       strokeWidth: 2.5,
// //                     ),
// //                   )
// //                       : Row(
// //                     mainAxisAlignment: MainAxisAlignment.center,
// //                     children: [
// //                       const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
// //                       const SizedBox(width: 8),
// //                       Text(
// //                         "Generate Names",
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.w600,
// //                           color: Colors.white,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //               const SizedBox(height: 28),
// //
// //               // Error Message Display
// //               if (errorMessage.isNotEmpty)
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.red[50],
// //                     borderRadius: BorderRadius.circular(12),
// //                     border: Border.all(color: Colors.red[200]!),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Icon(Icons.error_outline, color: Colors.red[700], size: 20),
// //                       const SizedBox(width: 8),
// //                       Expanded(
// //                         child: Text(
// //                           errorMessage,
// //                           style: GoogleFonts.poppins(
// //                             fontSize: 12,
// //                             color: Colors.red[700],
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //
// //               // Generated Names Display
// //               if (generatedNames.isNotEmpty) ...[
// //                 const SizedBox(height: 16),
// //                 Card(
// //                   elevation: 4,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(20),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Row(
// //                           children: [
// //                             Container(
// //                               padding: const EdgeInsets.all(8),
// //                               decoration: BoxDecoration(
// //                                 color: const Color(0xFFE3F2FD),
// //                                 borderRadius: BorderRadius.circular(8),
// //                               ),
// //                               child: const Icon(
// //                                 Icons.stars,
// //                                 color: Color(0xFF3498DB),
// //                                 size: 22,
// //                               ),
// //                             ),
// //                             const SizedBox(width: 12),
// //                             Expanded(
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Text(
// //                                     "Suggested Names",
// //                                     style: GoogleFonts.poppins(
// //                                       fontSize: 18,
// //                                       fontWeight: FontWeight.bold,
// //                                       color: const Color(0xFF2C3E50),
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     "$selectedReligion • $selectedGender",
// //                                     style: GoogleFonts.poppins(
// //                                       fontSize: 12,
// //                                       color: Colors.grey[600],
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                         const SizedBox(height: 16),
// //                         ...generatedNames.asMap().entries.map((entry) {
// //                           return Container(
// //                             margin: const EdgeInsets.only(bottom: 10),
// //                             padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF8F9FA),
// //                               borderRadius: BorderRadius.circular(10),
// //                               border: Border.all(
// //                                 color: Colors.grey[200]!,
// //                                 width: 1,
// //                               ),
// //                             ),
// //                             child: Row(
// //                               children: [
// //                                 Container(
// //                                   width: 32,
// //                                   height: 32,
// //                                   decoration: BoxDecoration(
// //                                     gradient: const LinearGradient(
// //                                       colors: [Color(0xFF5DADE2), Color(0xFF3498DB)],
// //                                     ),
// //                                     borderRadius: BorderRadius.circular(8),
// //                                   ),
// //                                   child: Center(
// //                                     child: Text(
// //                                       "${entry.key + 1}",
// //                                       style: GoogleFonts.poppins(
// //                                         color: Colors.white,
// //                                         fontWeight: FontWeight.bold,
// //                                         fontSize: 14,
// //                                       ),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 const SizedBox(width: 14),
// //                                 Expanded(
// //                                   child: Text(
// //                                     entry.value,
// //                                     style: GoogleFonts.poppins(
// //                                       fontSize: 16,
// //                                       fontWeight: FontWeight.w600,
// //                                       color: const Color(0xFF2C3E50),
// //                                     ),
// //                                   ),
// //                                 ),
// //                                 Icon(
// //                                   Icons.favorite_border,
// //                                   color: Colors.grey[400],
// //                                   size: 22,
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         }).toList(),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// //

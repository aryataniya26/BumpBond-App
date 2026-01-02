import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/gemini_service.dart';
import '../services/subscription_service.dart';
import '../screens/subscription_plan_screen.dart';

class BabyNameScreen extends StatefulWidget {
  const BabyNameScreen({super.key});

  @override
  State<BabyNameScreen> createState() => _BabyNameScreenState();
}

class _BabyNameScreenState extends State<BabyNameScreen> {
  final String apiKey = "AIzaSyBe7ILdpBBgHZZpWJRQXm-aIDH7iGGZe-A";
  late GeminiService geminiService;
  String _currentUserPlan = 'free';
  int _nameGenerationCount = 0;
  DateTime? _lastGenerationReset;

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
    _loadUserPlan();
    _loadGenerationCount();
  }

  // ==================== SUBSCRIPTION LOGIC ====================
  Future<void> _loadUserPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    setState(() {
      _currentUserPlan = plan;
    });
  }

  Future<void> _loadGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastReset = prefs.getString('last_name_generation_reset');

    if (lastReset != today) {
      await prefs.setInt('name_generation_count', 0);
      await prefs.setString('last_name_generation_reset', today);
      setState(() {
        _nameGenerationCount = 0;
        _lastGenerationReset = DateTime.now();
      });
    } else {
      setState(() {
        _nameGenerationCount = prefs.getInt('name_generation_count') ?? 0;
      });
    }
  }

  Future<void> _incrementGenerationCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameGenerationCount++;
    });
    await prefs.setInt('name_generation_count', _nameGenerationCount);
  }

  bool _hasAccess(String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(_currentUserPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);
    return userIndex >= requiredIndex;
  }

  bool _canGenerateNames() {
    if (_hasAccess('premium')) {
      return true; // Unlimited for premium users
    }

    // Free users: 2 name generations per day
    if (_nameGenerationCount < 2) {
      return true;
    }

    return false;
  }

  void _showGenerationLimitDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Daily Limit Reached',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Free plan includes 2 name generations per day\nUpgrade to Premium for unlimited baby name suggestions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Maybe Later'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4B5E8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Upgrade Now',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionIndicator() {
    if (_hasAccess('premium')) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD4B5E8).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.star, color: const Color(0xFFD4B5E8), size: 14),
            const SizedBox(width: 4),
            Text(
              'UNLIMITED NAMES',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFD4B5E8),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$_nameGenerationCount/2',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'generations today',
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      );
    }
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
    // Check subscription limits
    if (!_canGenerateNames()) {
      _showGenerationLimitDialog();
      return;
    }

    setState(() {
      loading = true;
    });

    // Increment counter for free users
    if (!_hasAccess('premium')) {
      await _incrementGenerationCount();
    }

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
    if (!_canGenerateNames()) {
      _showGenerationLimitDialog();
      return;
    }

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
          actions: [
            _buildSubscriptionIndicator(),
          ],
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
              // Subscription info
              if (!_hasAccess('premium'))
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Free Plan: 2 generations per day',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Upgrade for unlimited name suggestions',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange[700],
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
            _buildSubscriptionIndicator(),
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
                  // Subscription warning for free users
                  if (!_hasAccess('premium') && _nameGenerationCount >= 1)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${2 - _nameGenerationCount} generation${2 - _nameGenerationCount == 1 ? '' : 's'} remaining today',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // ... Rest of your existing results UI remains the same
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB794F4),
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
        actions: [
          _buildSubscriptionIndicator(),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header Card with subscription info
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
                  // Subscription info for free users
                  if (!_hasAccess('premium'))
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            'Free: 2 name generations per day',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
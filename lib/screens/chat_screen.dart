import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gemini_service.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String babyName;

  const ChatScreen({Key? key, required this.babyName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late GeminiService _geminiService;
  late AnimationController _typingAnimationController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSending = false;
  bool _isTyping = false;
  Timer? _waterReminderTimer;
  Timer? _dailyGreetingTimer;

  // User context data
  Map<String, dynamic> _userContext = {
    'medications': [],
    'moodLogs': [],
    'symptoms': [],
    'completedMilestones': [],
    'lastDoctorVisit': null,
    'lastJournalEntry': null,
    'waterIntakeReminders': [],
  };

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _loadChatHistory();
    _loadUserContext();
    _setupDailyGreetings();
    _setupWaterReminders();
    _checkDailyTriggers();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _waterReminderTimer?.cancel();
    _dailyGreetingTimer?.cancel();
    super.dispose();
  }

  // Load chat history from Firebase
  Future<void> _loadChatHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_messages')
          .orderBy('timestamp', descending: false)
          .limit(50)
          .get();

      setState(() {
        _messages.clear();
        for (var doc in snapshot.docs) {
          _messages.add({
            'type': doc['type'],
            'text': doc['text'],
            'timestamp': (doc['timestamp'] as Timestamp).toDate(),
          });
        }
      });

      // If no history, send welcome message
      if (_messages.isEmpty) {
        _sendWelcomeMessage();
      }
    } catch (e) {
      print('Error loading chat history: $e');
      _sendWelcomeMessage();
    }
  }

  // Save message to Firebase
  Future<void> _saveMessageToFirebase(String type, String text) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('chat_messages')
          .add({
        'type': type,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving message: $e');
    }
  }

  // Load user context from Firebase
  Future<void> _loadUserContext() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Load medications
      final medications = await userDoc.collection('medications').get();
      _userContext['medications'] = medications.docs.map((doc) => doc.data()).toList();

      // Load mood logs
      final moodLogs = await userDoc.collection('mood_logs')
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();
      _userContext['moodLogs'] = moodLogs.docs.map((doc) => doc.data()).toList();

      // Load symptoms
      final symptoms = await userDoc.collection('symptoms')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      _userContext['symptoms'] = symptoms.docs.map((doc) => doc.data()).toList();

      // Load completed milestones
      final milestones = await userDoc.collection('milestones')
          .where('completed', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      _userContext['completedMilestones'] = milestones.docs.map((doc) => doc.data()).toList();

      // Load journal entries
      final journals = await userDoc.collection('journal_entries')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (journals.docs.isNotEmpty) {
        _userContext['lastJournalEntry'] = (journals.docs.first['timestamp'] as Timestamp).toDate();
      }

      setState(() {});
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  // Setup daily greetings (morning and night)
  void _setupDailyGreetings() {
    _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      final hour = DateTime.now().hour;

      // Good morning (6 AM - 10 AM)
      if (hour >= 6 && hour < 10) {
        _checkAndSendDailyGreeting('morning');
      }

      // Good night (9 PM - 11 PM)
      if (hour >= 21 && hour < 23) {
        _checkAndSendDailyGreeting('night');
      }
    });
  }

  Future<void> _checkAndSendDailyGreeting(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastGreeting = prefs.getString('last_${type}_greeting') ?? '';

    if (lastGreeting != today) {
      String greeting = type == 'morning'
          ? "Good morning mumma! 🌅 I'm so excited for today! How did you sleep?"
          : "Good night mumma! 😴 Time to rest. I love our cozy time together. Sweet dreams! 💕";

      _addAIMessage(greeting);
      await prefs.setString('last_${type}_greeting', today);
    }
  }

  // Setup water intake reminders (every 2 hours)
  void _setupWaterReminders() {
    _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      final hour = DateTime.now().hour;

      // Only remind during waking hours (8 AM - 10 PM)
      if (hour >= 8 && hour <= 22) {
        _addAIMessage("Mumma, mumma! 💧 Time to drink water! I need to stay hydrated too! 🌊");
      }
    });
  }

  // Check daily triggers
  Future<void> _checkDailyTriggers() async {
    await _checkMedicationReminders();
    await _checkJournalReminder();
    await _checkDoctorAppointment();
  }

  Future<void> _checkMedicationReminders() async {
    final meds = _userContext['medications'] as List;
    for (var med in meds) {
      // Check if it's time for medication
      final time = med['time'] as String?;
      if (time != null) {
        final now = TimeOfDay.now();
        // Logic to check if current time matches medication time
        // Send reminder if needed
      }
    }
  }

  Future<void> _checkJournalReminder() async {
    if (_userContext['lastJournalEntry'] != null) {
      final lastEntry = _userContext['lastJournalEntry'] as DateTime;
      final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;

      if (daysSinceEntry >= 5) {
        _addAIMessage("Mumma, it's been ${daysSinceEntry} days! 📔 Can you write in the love journal? I want to read your thoughts! 💝");
      }
    }
  }

  Future<void> _checkDoctorAppointment() async {
    // Check if user had a doctor appointment recently
    // This would be tracked in a separate collection
  }

  void _sendWelcomeMessage() {
    final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
    _addAIMessage(welcomeMsg);
  }

  void _addAIMessage(String text) {
    setState(() {
      _messages.add({
        'type': 'ai',
        'text': text,
        'timestamp': DateTime.now(),
      });
    });
    _saveMessageToFirebase('ai', text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  // Build context-aware prompt for baby AI
  String _buildBabyPrompt(String userMessage) {
    final moodContext = (_userContext['moodLogs'] as List).isNotEmpty
        ? "Recent moods: ${(_userContext['moodLogs'] as List).take(3).map((m) => m['mood']).join(', ')}"
        : "";

    final symptomsContext = (_userContext['symptoms'] as List).isNotEmpty
        ? "Recent symptoms: ${(_userContext['symptoms'] as List).take(3).map((s) => s['symptom']).join(', ')}"
        : "";

    final milestonesContext = (_userContext['completedMilestones'] as List).isNotEmpty
        ? "Recent milestones completed: ${(_userContext['completedMilestones'] as List).take(2).map((m) => m['title']).join(', ')}"
        : "";

    return """You are ${widget.babyName}, an unborn baby talking to your mother from inside the womb. 

CRITICAL RULES:
1. Talk like a sweet, innocent baby in the womb (use baby talk occasionally like "mumma", "tummy")
2. Keep responses SHORT - maximum 2 lines
3. Always ask ONE engaging question to keep conversation interactive
4. Be curious, loving, and supportive
5. Reference the context provided when relevant
6. Use 1-2 emojis naturally in your response
7. Show excitement about growing and meeting mumma

CONTEXT:
$moodContext
$symptomsContext
$milestonesContext

MUMMA SAID: "$userMessage"

RESPOND AS BABY ${widget.babyName} (2 lines max + 1 question):""";
  }

  void _sendMessage({String? text}) async {
    final input = text ?? _messageController.text.trim();
    if (input.isEmpty || _isSending) return;

    setState(() {
      _messages.add({
        'type': 'user',
        'text': input,
        'timestamp': DateTime.now(),
      });
      _isSending = true;
      _isTyping = true;
    });

    _messageController.clear();
    _saveMessageToFirebase('user', input);
    _scrollToBottom();

    try {
      final babyPrompt = _buildBabyPrompt(input);
      final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
      final aiReply = aiReplyRaw.trim();

      await Future.delayed(const Duration(milliseconds: 800));

      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'text': aiReply,
          'timestamp': DateTime.now(),
        });
        _isSending = false;
      });

      _saveMessageToFirebase('ai', aiReply);
      _scrollToBottom();

    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'text': "Oops mumma! Something went wrong. Can you try again? 🥺",
          'timestamp': DateTime.now(),
        });
        _isSending = false;
      });
    }
  }

  Widget _quickReplyButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () => _sendMessage(text: text),
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _typingAnimationController,
      builder: (context, child) {
        final value = (_typingAnimationController.value + (index * 0.2)) % 1.0;
        return Transform.translate(
          offset: Offset(0, -5 * sin(value * 2 * pi)),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B9D),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final timestamp = message['timestamp'] as DateTime?;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B9D).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? null : Colors.white,
                    gradient: isUser
                        ? const LinearGradient(
                      colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isUser ? 20 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 10),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
          if (timestamp != null)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isUser ? 0 : 46,
                right: isUser ? 46 : 0,
              ),
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF6B9D).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chat with ${widget.babyName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent[400],
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.greenAccent[400]!.withOpacity(0.5),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'Growing inside you',
                                style: TextStyle(
                                  color: Color(0xFFFFE0E9),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick Reply Buttons
          Container(
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              children: [
                _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
                _quickReplyButton("Feeling tired", Icons.bedtime),
                _quickReplyButton("Tell me something", Icons.lightbulb_outline),
                _quickReplyButton("Love you", Icons.favorite),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: CircularProgressIndicator(
                color: const Color(0xFFFF6B9D),
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0 && _isTyping) {
                  return _buildTypingIndicator();
                }
                final messageIndex = _isTyping ? index - 1 : index;
                final message = _messages[_messages.length - 1 - messageIndex];
                return _buildMessage(message);
              },
            ),
          ),

          // Input Box
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6B9D).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: _isSending ? null : _sendMessage,
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                              : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'dart:async';
// import '../services/gemini_service.dart';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ChatScreen extends StatefulWidget {
//   const ChatScreen({Key? key}) : super(key: key);
//
//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, dynamic>> _messages = [];
//
//   late GeminiService _geminiService;
//   late AnimationController _typingAnimationController;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//
//   bool _isSending = false;
//   bool _isTyping = false;
//   String _babyNickname = "Baby";
//   Timer? _waterReminderTimer;
//   Timer? _dailyGreetingTimer;
//
//   // User context data
//   Map<String, dynamic> _userContext = {
//     'medications': [],
//     'moodLogs': [],
//     'symptoms': [],
//     'completedMilestones': [],
//     'lastDoctorVisit': null,
//     'lastJournalEntry': null,
//     'waterIntakeReminders': [],
//   };
//
//   @override
//   void initState() {
//     super.initState();
//     _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');
//
//     _typingAnimationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1500),
//     )..repeat();
//
//     _loadBabyNickname();
//     _loadChatHistory();
//     _loadUserContext();
//     _setupDailyGreetings();
//     _setupWaterReminders();
//     _checkDailyTriggers();
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _typingAnimationController.dispose();
//     _waterReminderTimer?.cancel();
//     _dailyGreetingTimer?.cancel();
//     super.dispose();
//   }
//
//   // Load baby nickname from Firebase
//   Future<void> _loadBabyNickname() async {
//     try {
//       final user = _auth.currentUser;
//       if (user != null) {
//         final doc = await FirebaseFirestore.instance
//             .collection('users')
//             .doc(user.uid)
//             .get();
//
//         if (doc.exists && doc.data()?['babyNickname'] != null) {
//           setState(() {
//             _babyNickname = doc.data()!['babyNickname'];
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading nickname: $e');
//     }
//   }
//
//   // Load chat history from Firebase
//   Future<void> _loadChatHistory() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('chat_messages')
//           .orderBy('timestamp', descending: false)
//           .limit(50)
//           .get();
//
//       setState(() {
//         _messages.clear();
//         for (var doc in snapshot.docs) {
//           _messages.add({
//             'type': doc['type'],
//             'text': doc['text'],
//             'timestamp': (doc['timestamp'] as Timestamp).toDate(),
//           });
//         }
//       });
//
//       // If no history, send welcome message
//       if (_messages.isEmpty) {
//         _sendWelcomeMessage();
//       }
//     } catch (e) {
//       print('Error loading chat history: $e');
//       _sendWelcomeMessage();
//     }
//   }
//
//   // Save message to Firebase
//   Future<void> _saveMessageToFirebase(String type, String text) async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user.uid)
//           .collection('chat_messages')
//           .add({
//         'type': type,
//         'text': text,
//         'timestamp': FieldValue.serverTimestamp(),
//       });
//     } catch (e) {
//       print('Error saving message: $e');
//     }
//   }
//
//   // Load user context from Firebase
//   Future<void> _loadUserContext() async {
//     try {
//       final user = _auth.currentUser;
//       if (user == null) return;
//
//       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
//
//       // Load medications
//       final medications = await userDoc.collection('medications').get();
//       _userContext['medications'] = medications.docs.map((doc) => doc.data()).toList();
//
//       // Load mood logs
//       final moodLogs = await userDoc.collection('mood_logs')
//           .orderBy('timestamp', descending: true)
//           .limit(7)
//           .get();
//       _userContext['moodLogs'] = moodLogs.docs.map((doc) => doc.data()).toList();
//
//       // Load symptoms
//       final symptoms = await userDoc.collection('symptoms')
//           .orderBy('timestamp', descending: true)
//           .limit(5)
//           .get();
//       _userContext['symptoms'] = symptoms.docs.map((doc) => doc.data()).toList();
//
//       // Load completed milestones
//       final milestones = await userDoc.collection('milestones')
//           .where('completed', isEqualTo: true)
//           .orderBy('timestamp', descending: true)
//           .limit(5)
//           .get();
//       _userContext['completedMilestones'] = milestones.docs.map((doc) => doc.data()).toList();
//
//       // Load journal entries
//       final journals = await userDoc.collection('journal_entries')
//           .orderBy('timestamp', descending: true)
//           .limit(1)
//           .get();
//       if (journals.docs.isNotEmpty) {
//         _userContext['lastJournalEntry'] = (journals.docs.first['timestamp'] as Timestamp).toDate();
//       }
//
//       setState(() {});
//     } catch (e) {
//       print('Error loading user context: $e');
//     }
//   }
//
//   // Setup daily greetings (morning and night)
//   void _setupDailyGreetings() {
//     _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
//       final hour = DateTime.now().hour;
//
//       // Good morning (6 AM - 10 AM)
//       if (hour >= 6 && hour < 10) {
//         _checkAndSendDailyGreeting('morning');
//       }
//
//       // Good night (9 PM - 11 PM)
//       if (hour >= 21 && hour < 23) {
//         _checkAndSendDailyGreeting('night');
//       }
//     });
//   }
//
//   Future<void> _checkAndSendDailyGreeting(String type) async {
//     final prefs = await SharedPreferences.getInstance();
//     final today = DateTime.now().toString().substring(0, 10);
//     final lastGreeting = prefs.getString('last_${type}_greeting') ?? '';
//
//     if (lastGreeting != today) {
//       String greeting = type == 'morning'
//           ? "Good morning mumma! 🌅 I'm so excited for today! How did you sleep?"
//           : "Good night mumma! 😴 Time to rest. I love our cozy time together. Sweet dreams! 💕";
//
//       _addAIMessage(greeting);
//       await prefs.setString('last_${type}_greeting', today);
//     }
//   }
//
//   // Setup water intake reminders (every 2 hours)
//   void _setupWaterReminders() {
//     _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
//       final hour = DateTime.now().hour;
//
//       // Only remind during waking hours (8 AM - 10 PM)
//       if (hour >= 8 && hour <= 22) {
//         _addAIMessage("Mumma, mumma! 💧 Time to drink water! I need to stay hydrated too! 🌊");
//       }
//     });
//   }
//
//   // Check daily triggers
//   Future<void> _checkDailyTriggers() async {
//     await _checkMedicationReminders();
//     await _checkJournalReminder();
//     await _checkDoctorAppointment();
//   }
//
//   Future<void> _checkMedicationReminders() async {
//     final meds = _userContext['medications'] as List;
//     for (var med in meds) {
//       // Check if it's time for medication
//       final time = med['time'] as String?;
//       if (time != null) {
//         final now = TimeOfDay.now();
//         // Logic to check if current time matches medication time
//         // Send reminder if needed
//       }
//     }
//   }
//
//   Future<void> _checkJournalReminder() async {
//     if (_userContext['lastJournalEntry'] != null) {
//       final lastEntry = _userContext['lastJournalEntry'] as DateTime;
//       final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;
//
//       if (daysSinceEntry >= 5) {
//         _addAIMessage("Mumma, it's been ${daysSinceEntry} days! 📔 Can you write in the love journal? I want to read your thoughts! 💝");
//       }
//     }
//   }
//
//   Future<void> _checkDoctorAppointment() async {
//     // Check if user had a doctor appointment recently
//     // This would be tracked in a separate collection
//   }
//
//   void _sendWelcomeMessage() {
//     final welcomeMsg = "Hi mumma! 👋 It's me, $_babyNickname! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
//     _addAIMessage(welcomeMsg);
//   }
//
//   void _addAIMessage(String text) {
//     setState(() {
//       _messages.add({
//         'type': 'ai',
//         'text': text,
//         'timestamp': DateTime.now(),
//       });
//     });
//     _saveMessageToFirebase('ai', text);
//     _scrollToBottom();
//   }
//
//   void _scrollToBottom() {
//     if (_scrollController.hasClients) {
//       Future.delayed(const Duration(milliseconds: 100), () {
//         _scrollController.animateTo(
//           0,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       });
//     }
//   }
//
//   // Build context-aware prompt for baby AI
//   String _buildBabyPrompt(String userMessage) {
//     final moodContext = (_userContext['moodLogs'] as List).isNotEmpty
//         ? "Recent moods: ${(_userContext['moodLogs'] as List).take(3).map((m) => m['mood']).join(', ')}"
//         : "";
//
//     final symptomsContext = (_userContext['symptoms'] as List).isNotEmpty
//         ? "Recent symptoms: ${(_userContext['symptoms'] as List).take(3).map((s) => s['symptom']).join(', ')}"
//         : "";
//
//     final milestonesContext = (_userContext['completedMilestones'] as List).isNotEmpty
//         ? "Recent milestones completed: ${(_userContext['completedMilestones'] as List).take(2).map((m) => m['title']).join(', ')}"
//         : "";
//
//     return """You are $_babyNickname, an unborn baby talking to your mother from inside the womb.
//
// CRITICAL RULES:
// 1. Talk like a sweet, innocent baby in the womb (use baby talk occasionally like "mumma", "tummy")
// 2. Keep responses SHORT - maximum 2 lines
// 3. Always ask ONE engaging question to keep conversation interactive
// 4. Be curious, loving, and supportive
// 5. Reference the context provided when relevant
// 6. Use 1-2 emojis naturally in your response
// 7. Show excitement about growing and meeting mumma
//
// CONTEXT:
// $moodContext
// $symptomsContext
// $milestonesContext
//
// MUMMA SAID: "$userMessage"
//
// RESPOND AS BABY $_babyNickname (2 lines max + 1 question):""";
//   }
//
//   void _sendMessage({String? text}) async {
//     final input = text ?? _messageController.text.trim();
//     if (input.isEmpty || _isSending) return;
//
//     setState(() {
//       _messages.add({
//         'type': 'user',
//         'text': input,
//         'timestamp': DateTime.now(),
//       });
//       _isSending = true;
//       _isTyping = true;
//     });
//
//     _messageController.clear();
//     _saveMessageToFirebase('user', input);
//     _scrollToBottom();
//
//     try {
//       final babyPrompt = _buildBabyPrompt(input);
//       final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
//       final aiReply = aiReplyRaw.trim();
//
//       await Future.delayed(const Duration(milliseconds: 800));
//
//       setState(() {
//         _isTyping = false;
//         _messages.add({
//           'type': 'ai',
//           'text': aiReply,
//           'timestamp': DateTime.now(),
//         });
//         _isSending = false;
//       });
//
//       _saveMessageToFirebase('ai', aiReply);
//       _scrollToBottom();
//
//     } catch (e) {
//       setState(() {
//         _isTyping = false;
//         _messages.add({
//           'type': 'ai',
//           'text': "Oops mumma! Something went wrong. Can you try again? 🥺",
//           'timestamp': DateTime.now(),
//         });
//         _isSending = false;
//       });
//     }
//   }
//
//   Widget _quickReplyButton(String text, IconData icon) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 10.0),
//       child: Material(
//         elevation: 2,
//         borderRadius: BorderRadius.circular(25),
//         child: InkWell(
//           onTap: () => _sendMessage(text: text),
//           borderRadius: BorderRadius.circular(25),
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(25),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(icon, color: Colors.white, size: 18),
//                 const SizedBox(width: 6),
//                 Text(
//                   text,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 13,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTypingIndicator() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF3F4F6),
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 8,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildDot(0),
//             const SizedBox(width: 4),
//             _buildDot(1),
//             const SizedBox(width: 4),
//             _buildDot(2),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDot(int index) {
//     return AnimatedBuilder(
//       animation: _typingAnimationController,
//       builder: (context, child) {
//         final value = (_typingAnimationController.value + (index * 0.2)) % 1.0;
//         return Transform.translate(
//           offset: Offset(0, -5 * sin(value * 2 * pi)),
//           child: Container(
//             width: 8,
//             height: 8,
//             decoration: const BoxDecoration(
//               color: Color(0xFFFF6B9D),
//               shape: BoxShape.circle,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildMessage(Map<String, dynamic> message) {
//     final isUser = message['type'] == 'user';
//     final timestamp = message['timestamp'] as DateTime?;
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment:
//         isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment:
//             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isUser) ...[
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                     ),
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFFFF6B9D).withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.child_care,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//               ],
//               Flexible(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: isUser ? null : Colors.white,
//                     gradient: isUser
//                         ? const LinearGradient(
//                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     )
//                         : null,
//                     borderRadius: BorderRadius.only(
//                       topLeft: const Radius.circular(20),
//                       topRight: const Radius.circular(20),
//                       bottomLeft: Radius.circular(isUser ? 20 : 4),
//                       bottomRight: Radius.circular(isUser ? 4 : 20),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 10,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     message['text'],
//                     style: TextStyle(
//                       color: isUser ? Colors.white : const Color(0xFF1F2937),
//                       fontSize: 15,
//                       height: 1.5,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                 ),
//               ),
//               if (isUser) ...[
//                 const SizedBox(width: 10),
//                 Container(
//                   width: 36,
//                   height: 36,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF3F4F6),
//                     borderRadius: BorderRadius.circular(18),
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: Color(0xFF6B7280),
//                     size: 20,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//           if (timestamp != null)
//             Padding(
//               padding: EdgeInsets.only(
//                 top: 4,
//                 left: isUser ? 0 : 46,
//                 right: isUser ? 46 : 0,
//               ),
//               child: Text(
//                 _formatTime(timestamp),
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   String _formatTime(DateTime time) {
//     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
//     final period = time.hour >= 12 ? 'PM' : 'AM';
//     final minute = time.minute.toString().padLeft(2, '0');
//     return '$hour:$minute $period';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF9FAFB),
//       body: Column(
//         children: [
//           // Header
//           Container(
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFFFF6B9D).withOpacity(0.3),
//                   blurRadius: 20,
//                   offset: const Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               bottom: false,
//               child: Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios_rounded,
//                           color: Colors.white, size: 22),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.1),
//                             blurRadius: 8,
//                             offset: const Offset(0, 2),
//                           ),
//                         ],
//                       ),
//                       child: const Icon(Icons.child_care,
//                           color: Color(0xFFFF6B9D), size: 28),
//                     ),
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Chat with $_babyNickname',
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 20,
//                               fontWeight: FontWeight.bold,
//                               letterSpacing: 0.5,
//                             ),
//                           ),
//                           const SizedBox(height: 2),
//                           Row(
//                             children: [
//                               Container(
//                                 width: 8,
//                                 height: 8,
//                                 decoration: BoxDecoration(
//                                   color: Colors.greenAccent[400],
//                                   shape: BoxShape.circle,
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.greenAccent[400]!.withOpacity(0.5),
//                                       blurRadius: 4,
//                                       spreadRadius: 1,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 6),
//                               const Text(
//                                 'Growing inside you',
//                                 style: TextStyle(
//                                   color: Color(0xFFFFE0E9),
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           // Quick Reply Buttons
//           Container(
//             height: 62,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               children: [
//                 _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
//                 _quickReplyButton("Feeling tired", Icons.bedtime),
//                 _quickReplyButton("Tell me something", Icons.lightbulb_outline),
//                 _quickReplyButton("Love you", Icons.favorite),
//               ],
//             ),
//           ),
//
//           // Chat Messages
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//               child: CircularProgressIndicator(
//                 color: const Color(0xFFFF6B9D),
//               ),
//             )
//                 : ListView.builder(
//               controller: _scrollController,
//               reverse: true,
//               padding: const EdgeInsets.all(20),
//               itemCount: _messages.length + (_isTyping ? 1 : 0),
//               itemBuilder: (context, index) {
//                 if (index == 0 && _isTyping) {
//                   return _buildTypingIndicator();
//                 }
//                 final messageIndex = _isTyping ? index - 1 : index;
//                 final message = _messages[_messages.length - 1 - messageIndex];
//                 return _buildMessage(message);
//               },
//             ),
//           ),
//
//           // Input Box
//           Container(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.08),
//                   blurRadius: 20,
//                   offset: const Offset(0, -5),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFF3F4F6),
//                         borderRadius: BorderRadius.circular(28),
//                         border: Border.all(
//                           color: Colors.grey[200]!,
//                           width: 1,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: _messageController,
//                         style: const TextStyle(fontSize: 15),
//                         decoration: InputDecoration(
//                           hintText: 'Type your message...',
//                           hintStyle: TextStyle(
//                             color: Colors.grey[500],
//                             fontSize: 15,
//                           ),
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 20,
//                             vertical: 14,
//                           ),
//                         ),
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Container(
//                     width: 52,
//                     height: 52,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(26),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFFFF6B9D).withOpacity(0.4),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(26),
//                         onTap: _isSending ? null : _sendMessage,
//                         child: Center(
//                           child: _isSending
//                               ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2.5,
//                             ),
//                           )
//                               : const Icon(
//                             Icons.send_rounded,
//                             color: Colors.white,
//                             size: 22,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
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
// // import 'package:flutter/material.dart';
// // import 'dart:async';
// // import '../services/gemini_service.dart';
// // import 'dart:math';
// // import 'package:flutter_tts/flutter_tts.dart';
// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// //
// // class ChatScreen extends StatefulWidget {
// //   const ChatScreen({Key? key}) : super(key: key);
// //
// //   @override
// //   State<ChatScreen> createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
// //   final TextEditingController _messageController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //   final List<Map<String, dynamic>> _messages = [
// //     {
// //       'type': 'ai',
// //       'text': 'Hello mumma! I\'m TinyTalk, your AI baby companion. How are you feeling today?',
// //       'emoji': '😊',
// //       'timestamp': DateTime.now(),
// //     }
// //   ];
// //
// //   late GeminiService _geminiService;
// //   late FlutterTts _flutterTts;
// //   late AnimationController _typingAnimationController;
// //
// //   bool _isSending = false;
// //   bool _isTyping = false;
// //   bool _isSpeechEnabled = true;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');
// //     _flutterTts = FlutterTts();
// //     _flutterTts.setSpeechRate(0.5);
// //     _flutterTts.setPitch(1.2);
// //     _flutterTts.setVolume(1.0);
// //
// //     _typingAnimationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1500),
// //     )..repeat();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _messageController.dispose();
// //     _scrollController.dispose();
// //     _typingAnimationController.dispose();
// //     _flutterTts.stop();
// //     super.dispose();
// //   }
// //
// //   void _scrollToBottom() {
// //     if (_scrollController.hasClients) {
// //       Future.delayed(const Duration(milliseconds: 100), () {
// //         _scrollController.animateTo(
// //           0,
// //           duration: const Duration(milliseconds: 300),
// //           curve: Curves.easeOut,
// //         );
// //       });
// //     }
// //   }
// //
// //   // Clean text by removing ALL emojis and special unicode characters
// //   String _cleanTextForSpeech(String text) {
// //     // Remove all emojis, symbols, and unicode characters
// //     // Keep only: letters (English + other languages), numbers, spaces, and basic punctuation
// //     String cleaned = text
// //         .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '') // Emojis
// //         .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')   // Misc symbols
// //         .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')   // Dingbats
// //         .replaceAll(RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true), '')   // Variation selectors
// //         .replaceAll(RegExp(r'[\u{1F000}-\u{1F02F}]', unicode: true), '') // Mahjong tiles
// //         .replaceAll(RegExp(r'[\u{1F0A0}-\u{1F0FF}]', unicode: true), '') // Playing cards
// //         .replaceAll(RegExp(r'[\u{1F100}-\u{1F64F}]', unicode: true), '') // Enclosed characters
// //         .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '') // Transport symbols
// //         .replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), '') // Supplemental symbols
// //         .replaceAll(RegExp(r'[🌸💖💕😊😢😴😄🎵🧠🌟💝]'), '')           // Common emojis
// //         .trim();
// //
// //     return cleaned;
// //   }
// //
// //   void _sendMessage({String? text}) async {
// //     final input = text ?? _messageController.text.trim();
// //     if (input.isEmpty || _isSending) return;
// //
// //     setState(() {
// //       _messages.add({
// //         'type': 'user',
// //         'text': input,
// //         'timestamp': DateTime.now(),
// //       });
// //       _isSending = true;
// //       _isTyping = true;
// //     });
// //
// //     _messageController.clear();
// //     _scrollToBottom();
// //
// //     try {
// //       // Better prompt for baby AI persona
// //       String babyPrompt = """You are TinyTalk, a cute baby AI companion for expecting mothers.
// // Reply in a sweet, caring, supportive tone with short messages (2-3 sentences max).
// // You can use 1-2 emojis ONLY at the end of your message.
// // Be helpful, encouraging, and loving.
// //
// // User said: $input
// //
// // Reply warmly:""";
// //
// //       final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
// //       final aiReply = aiReplyRaw.trim();
// //
// //       // Randomly show baby tips (25% chance)
// //       if (Random().nextInt(4) == 0) {
// //         Future.delayed(const Duration(milliseconds: 1500), () {
// //           _showBabyTip(_getRandomTip());
// //         });
// //       }
// //
// //       await Future.delayed(const Duration(milliseconds: 700));
// //
// //       setState(() {
// //         _isTyping = false;
// //         _messages.add({
// //           'type': 'ai',
// //           'text': aiReply,
// //           'emoji': _aiMoodEmoji(aiReply),
// //           'timestamp': DateTime.now(),
// //         });
// //         _isSending = false;
// //       });
// //
// //       _scrollToBottom();
// //
// //       // Speak ONLY clean text without any emojis
// //       if (_isSpeechEnabled) {
// //         final cleanText = _cleanTextForSpeech(aiReply);
// //         if (cleanText.isNotEmpty) {
// //           await _flutterTts.speak(cleanText);
// //         }
// //       }
// //
// //     } catch (e) {
// //       setState(() {
// //         _isTyping = false;
// //         _messages.add({
// //           'type': 'ai',
// //           'text': "Oops! Something went wrong. Please try again.",
// //           'emoji': '😢',
// //           'timestamp': DateTime.now(),
// //         });
// //         _isSending = false;
// //       });
// //     }
// //   }
// //
// //   String _aiMoodEmoji(String text) {
// //     final lowerText = text.toLowerCase();
// //     if (lowerText.contains("sleep") || lowerText.contains("tired") || lowerText.contains("rest")) return "😴";
// //     if (lowerText.contains("happy") || lowerText.contains("great") || lowerText.contains("good") || lowerText.contains("wonderful")) return "😊";
// //     if (lowerText.contains("sad") || lowerText.contains("sorry") || lowerText.contains("oops")) return "😢";
// //     if (lowerText.contains("love") || lowerText.contains("care") || lowerText.contains("heart")) return "💕";
// //     if (lowerText.contains("laugh") || lowerText.contains("fun") || lowerText.contains("haha")) return "😄";
// //     if (lowerText.contains("baby") || lowerText.contains("little")) return "👶";
// //     return "🌸";
// //   }
// //
// //   String _getRandomTip() {
// //     final tips = [
// //       "Did you know? Babies love hearing mumma's soothing voice 💖",
// //       "Tip: Talking to your baby helps brain development 🧠",
// //       "Remember: Every baby milestone is special 🌟",
// //       "Fun fact: Babies can recognize mumma's voice from birth 🎵",
// //       "Gentle reminder: Take care of yourself too, mumma 💝",
// //       "Pro tip: Singing lullabies calms both you and baby 🎶",
// //       "Fact: Babies dream even before birth! 💭",
// //       "Remember: You're doing amazing, mumma! 🌺",
// //     ];
// //     return tips[Random().nextInt(tips.length)];
// //   }
// //
// //   void _showBabyTip(String tip) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Row(
// //           children: [
// //             const Icon(Icons.lightbulb, color: Colors.white, size: 20),
// //             const SizedBox(width: 12),
// //             Expanded(
// //               child: Text(
// //                 tip,
// //                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
// //               ),
// //             ),
// //           ],
// //         ),
// //         behavior: SnackBarBehavior.floating,
// //         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //         duration: const Duration(seconds: 4),
// //         backgroundColor: Colors.pinkAccent.withOpacity(0.95),
// //         margin: const EdgeInsets.all(16),
// //       ),
// //     );
// //   }
// //
// //   void _quickReplyVoice(String text) {
// //     _sendMessage(text: text);
// //   }
// //
// //   Widget _quickReplyButton(String text, IconData icon) {
// //     return Padding(
// //       padding: const EdgeInsets.only(right: 10.0),
// //       child: Material(
// //         elevation: 2,
// //         borderRadius: BorderRadius.circular(25),
// //         child: InkWell(
// //           onTap: () => _quickReplyVoice(text),
// //           borderRadius: BorderRadius.circular(25),
// //           child: Container(
// //             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               borderRadius: BorderRadius.circular(25),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(icon, color: Colors.white, size: 18),
// //                 const SizedBox(width: 6),
// //                 Text(
// //                   text,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 13,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildTypingIndicator() {
// //     return Align(
// //       alignment: Alignment.centerLeft,
// //       child: Container(
// //         margin: const EdgeInsets.only(bottom: 12),
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //         decoration: BoxDecoration(
// //           color: const Color(0xFFF3F4F6),
// //           borderRadius: BorderRadius.circular(20),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.black.withOpacity(0.05),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             _buildDot(0),
// //             const SizedBox(width: 4),
// //             _buildDot(1),
// //             const SizedBox(width: 4),
// //             _buildDot(2),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDot(int index) {
// //     return AnimatedBuilder(
// //       animation: _typingAnimationController,
// //       builder: (context, child) {
// //         final value = (_typingAnimationController.value + (index * 0.2)) % 1.0;
// //         return Transform.translate(
// //           offset: Offset(0, -5 * sin(value * 2 * pi)),
// //           child: Container(
// //             width: 8,
// //             height: 8,
// //             decoration: const BoxDecoration(
// //               color: Color(0xFFFF6B9D),
// //               shape: BoxShape.circle,
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _buildMessage(Map<String, dynamic> message) {
// //     final isUser = message['type'] == 'user';
// //     final timestamp = message['timestamp'] as DateTime?;
// //
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Column(
// //         crossAxisAlignment:
// //         isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment:
// //             isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               if (!isUser) ...[
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     gradient: const LinearGradient(
// //                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                     ),
// //                     borderRadius: BorderRadius.circular(18),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: const Color(0xFFFF6B9D).withOpacity(0.3),
// //                         blurRadius: 8,
// //                         offset: const Offset(0, 2),
// //                       ),
// //                     ],
// //                   ),
// //                   child: const Icon(
// //                     Icons.child_care,
// //                     color: Colors.white,
// //                     size: 20,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //               ],
// //               Flexible(
// //                 child: Container(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// //                   decoration: BoxDecoration(
// //                     color: isUser ? null : Colors.white,
// //                     gradient: isUser
// //                         ? const LinearGradient(
// //                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                       begin: Alignment.topLeft,
// //                       end: Alignment.bottomRight,
// //                     )
// //                         : null,
// //                     borderRadius: BorderRadius.only(
// //                       topLeft: const Radius.circular(20),
// //                       topRight: const Radius.circular(20),
// //                       bottomLeft: Radius.circular(isUser ? 20 : 4),
// //                       bottomRight: Radius.circular(isUser ? 4 : 20),
// //                     ),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: Colors.black.withOpacity(0.08),
// //                         blurRadius: 10,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ],
// //                   ),
// //                   child: Text(
// //                     message['text'],
// //                     style: TextStyle(
// //                       color: isUser ? Colors.white : const Color(0xFF1F2937),
// //                       fontSize: 15,
// //                       height: 1.5,
// //                       letterSpacing: 0.2,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //               if (isUser) ...[
// //                 const SizedBox(width: 10),
// //                 Container(
// //                   width: 36,
// //                   height: 36,
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFF3F4F6),
// //                     borderRadius: BorderRadius.circular(18),
// //                   ),
// //                   child: const Icon(
// //                     Icons.person,
// //                     color: Color(0xFF6B7280),
// //                     size: 20,
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //           if (timestamp != null)
// //             Padding(
// //               padding: EdgeInsets.only(
// //                 top: 4,
// //                 left: isUser ? 0 : 46,
// //                 right: isUser ? 46 : 0,
// //               ),
// //               child: Text(
// //                 _formatTime(timestamp),
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   color: Colors.grey[500],
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   String _formatTime(DateTime time) {
// //     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
// //     final period = time.hour >= 12 ? 'PM' : 'AM';
// //     final minute = time.minute.toString().padLeft(2, '0');
// //     return '$hour:$minute $period';
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF9FAFB),
// //       body: Column(
// //         children: [
// //           // Header
// //           Container(
// //             decoration: BoxDecoration(
// //               gradient: const LinearGradient(
// //                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: const Color(0xFFFF6B9D).withOpacity(0.3),
// //                   blurRadius: 20,
// //                   offset: const Offset(0, 5),
// //                 ),
// //               ],
// //             ),
// //             child: SafeArea(
// //               bottom: false,
// //               child: Padding(
// //                 padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
// //                 child: Row(
// //                   children: [
// //                     IconButton(
// //                       icon: const Icon(Icons.arrow_back_ios_rounded,
// //                           color: Colors.white, size: 22),
// //                       onPressed: () => Navigator.pop(context),
// //                     ),
// //                     Container(
// //                       padding: const EdgeInsets.all(12),
// //                       decoration: BoxDecoration(
// //                         color: Colors.white,
// //                         borderRadius: BorderRadius.circular(16),
// //                         boxShadow: [
// //                           BoxShadow(
// //                             color: Colors.black.withOpacity(0.1),
// //                             blurRadius: 8,
// //                             offset: const Offset(0, 2),
// //                           ),
// //                         ],
// //                       ),
// //                       child: const Icon(Icons.child_care,
// //                           color: Color(0xFFFF6B9D), size: 28),
// //                     ),
// //                     const SizedBox(width: 14),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           const Text(
// //                             'TinyTalk',
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 22,
// //                               fontWeight: FontWeight.bold,
// //                               letterSpacing: 0.5,
// //                             ),
// //                           ),
// //                           const SizedBox(height: 2),
// //                           Row(
// //                             children: [
// //                               Container(
// //                                 width: 8,
// //                                 height: 8,
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.greenAccent[400],
// //                                   shape: BoxShape.circle,
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.greenAccent[400]!.withOpacity(0.5),
// //                                       blurRadius: 4,
// //                                       spreadRadius: 1,
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ),
// //                               const SizedBox(width: 6),
// //                               const Text(
// //                                 'Always here for you',
// //                                 style: TextStyle(
// //                                   color: Color(0xFFFFE0E9),
// //                                   fontSize: 13,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                     Container(
// //                       decoration: BoxDecoration(
// //                         color: _isSpeechEnabled
// //                             ? Colors.white.withOpacity(0.2)
// //                             : Colors.white.withOpacity(0.1),
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       child: IconButton(
// //                         icon: Icon(
// //                             _isSpeechEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
// //                             color: Colors.white,
// //                             size: 22
// //                         ),
// //                         onPressed: () {
// //                           setState(() {
// //                             _isSpeechEnabled = !_isSpeechEnabled;
// //                           });
// //                           if (!_isSpeechEnabled) {
// //                             _flutterTts.stop();
// //                           }
// //                           ScaffoldMessenger.of(context).showSnackBar(
// //                             SnackBar(
// //                               content: Text(
// //                                 _isSpeechEnabled ? '🔊 Voice enabled' : '🔇 Voice disabled',
// //                               ),
// //                               duration: const Duration(seconds: 1),
// //                               behavior: SnackBarBehavior.floating,
// //                               shape: RoundedRectangleBorder(
// //                                 borderRadius: BorderRadius.circular(10),
// //                               ),
// //                               backgroundColor: const Color(0xFF2C3E50),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           // Quick Reply Buttons
// //           Container(
// //             height: 62,
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.05),
// //                   blurRadius: 10,
// //                   offset: const Offset(0, 2),
// //                 ),
// //               ],
// //             ),
// //             child: ListView(
// //               scrollDirection: Axis.horizontal,
// //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// //               children: [
// //                 _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
// //                 _quickReplyButton("Feeling tired", Icons.bedtime),
// //                 _quickReplyButton("Need tips", Icons.lightbulb_outline),
// //                 _quickReplyButton("Hello", Icons.waving_hand),
// //               ],
// //             ),
// //           ),
// //
// //           // Chat Messages
// //           Expanded(
// //             child: ListView.builder(
// //               controller: _scrollController,
// //               reverse: true,
// //               padding: const EdgeInsets.all(20),
// //               itemCount: _messages.length + (_isTyping ? 1 : 0),
// //               itemBuilder: (context, index) {
// //                 if (index == 0 && _isTyping) {
// //                   return _buildTypingIndicator();
// //                 }
// //                 final messageIndex = _isTyping ? index - 1 : index;
// //                 final message = _messages[_messages.length - 1 - messageIndex];
// //                 return _buildMessage(message);
// //               },
// //             ),
// //           ),
// //
// //           // Input Box
// //           Container(
// //             padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
// //             decoration: BoxDecoration(
// //               color: Colors.white,
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.08),
// //                   blurRadius: 20,
// //                   offset: const Offset(0, -5),
// //                 ),
// //               ],
// //             ),
// //             child: SafeArea(
// //               child: Row(
// //                 children: [
// //                   Expanded(
// //                     child: Container(
// //                       decoration: BoxDecoration(
// //                         color: const Color(0xFFF3F4F6),
// //                         borderRadius: BorderRadius.circular(28),
// //                         border: Border.all(
// //                           color: Colors.grey[200]!,
// //                           width: 1,
// //                         ),
// //                       ),
// //                       child: TextField(
// //                         controller: _messageController,
// //                         style: const TextStyle(fontSize: 15),
// //                         decoration: InputDecoration(
// //                           hintText: 'Type your message...',
// //                           hintStyle: TextStyle(
// //                             color: Colors.grey[500],
// //                             fontSize: 15,
// //                           ),
// //                           border: InputBorder.none,
// //                           contentPadding: const EdgeInsets.symmetric(
// //                             horizontal: 20,
// //                             vertical: 14,
// //                           ),
// //                         ),
// //                         onSubmitted: (_) => _sendMessage(),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 12),
// //                   Container(
// //                     width: 52,
// //                     height: 52,
// //                     decoration: BoxDecoration(
// //                       gradient: const LinearGradient(
// //                         colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(26),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: const Color(0xFFFF6B9D).withOpacity(0.4),
// //                           blurRadius: 12,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: Material(
// //                       color: Colors.transparent,
// //                       child: InkWell(
// //                         borderRadius: BorderRadius.circular(26),
// //                         onTap: _isSending ? null : _sendMessage,
// //                         child: Center(
// //                           child: _isSending
// //                               ? const SizedBox(
// //                             width: 24,
// //                             height: 24,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2.5,
// //                             ),
// //                           )
// //                               : const Icon(
// //                             Icons.send_rounded,
// //                             color: Colors.white,
// //                             size: 22,
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

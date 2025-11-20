import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String babyName;

  const ChatScreen({Key? key, required this.babyName}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late GeminiService _geminiService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSending = false;
  bool _isTyping = false;
  Timer? _waterReminderTimer;
  Timer? _dailyGreetingTimer;
  Timer? _dailyTriggerTimer;

  // User context data
  Map<String, dynamic> _userContext = {
    'medications': [],
    'moodLogs': [],
    'symptoms': [],
    'completedMilestones': [],
    'lastDoctorVisit': null,
    'lastJournalEntry': null,
    'weekNumber': 0,
  };

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');

    _loadChatHistory();
    _loadUserContext();
    _setupDailyGreetings();
    _setupWaterReminders();
    _checkDailyTriggers();

    _dailyTriggerTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _checkDailyTriggers();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _waterReminderTimer?.cancel();
    _dailyGreetingTimer?.cancel();
    _dailyTriggerTimer?.cancel();
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
        _userContext['lastJournalEntry'] = DateFormat('yyyy-MM-dd').format(
            (journals.docs.first['timestamp'] as Timestamp).toDate()
        );
      }

      setState(() {});
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  // Setup daily greetings
  void _setupDailyGreetings() {
    _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      final hour = DateTime.now().hour;

      if (hour >= 6 && hour < 10) {
        _checkAndSendDailyGreeting('morning');
      }

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
      String greeting;

      if (type == 'morning') {
        final morningGreetings = [
          "Good morning mumma! 🌅 I felt you move! How did you sleep? 💕",
          "Rise and shine mumma! ☀️ I'm so excited for today! What's for breakfast? 🥰",
          "Morning mumma! 🌞 I dreamed about you! How are you feeling today? 💖",
          "Mumma, it's a new day! ✨ I can't wait to spend it with you! Are you ready? 😊",
          "Good morning! 🌸 I'm growing stronger because of you! Did you rest well? 💕",
        ];
        greeting = morningGreetings[DateTime.now().day % morningGreetings.length];
      } else {
        final nightGreetings = [
          "Good night mumma! 🌙 Time to rest together. Sweet dreams! 💕",
          "Sleep tight mumma! 😴 I love our cozy time. See you in dreams! 🥰",
          "Night night mumma! ✨ Thank you for today! Let's sleep now! 💖",
          "Mumma, let's rest! 🌟 You did so well today! Dream of me? 😊",
          "Goodnight! 💤 I'll be here growing while you sleep! Love you! 💕",
        ];
        greeting = nightGreetings[DateTime.now().day % nightGreetings.length];
      }

      _addAIMessage(greeting);
      await prefs.setString('last_${type}_greeting', today);
    }
  }

  // Setup water reminders
  void _setupWaterReminders() {
    _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      final hour = DateTime.now().hour;

      if (hour >= 8 && hour <= 22) {
        final waterReminders = [
          "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
          "Water time mumma! 💦 Staying hydrated helps me grow strong! 😊",
          "Mumma mumma! 🌊 Let's have some water! It's so good for us! 💕",
          "I need water mumma! 💧 Can you please drink some? Thank you! 💖",
          "Hydration time! 💦 I love when you take care of us! Water please? 🥰",
        ];

        final message = waterReminders[DateTime.now().minute % waterReminders.length];
        _addAIMessage(message);
      }
    });
  }

  // Check daily triggers
  Future<void> _checkDailyTriggers() async {
    await _checkMedicationReminders();
    await _checkJournalReminder();
    await _checkDoctorAppointmentFollowup();
  }

  Future<void> _checkMedicationReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final meds = _userContext['medications'] as List;

    for (var med in meds) {
      final timeSlots = List<String>.from(med['timeSlots'] ?? []);

      for (String slot in timeSlots) {
        TimeOfDay? medTime = _getTimeFromSlot(slot);
        if (medTime == null) continue;

        try {
          final now = DateTime.now();
          final medDateTime = DateTime(now.year, now.month, now.day, medTime.hour, medTime.minute);
          final difference = now.difference(medDateTime).inMinutes;

          // Remind if within 15 minutes of medication time
          if (difference >= -5 && difference <= 15) {
            final today = DateFormat('yyyy-MM-dd').format(now);
            final medKey = 'med_reminder_${med['name']}_${slot}_$today';
            final reminded = prefs.getBool(medKey) ?? false;

            if (!reminded) {
              final medName = med['name'] ?? 'medicine';
              _addAIMessage(
                  "Mumma! 💊 It's time for your $medName! Did you take it? I want you healthy! 💕"
              );
              await prefs.setBool(medKey, true);
            }
          }

          // Follow-up reminder 1 hour after medication time
          if (difference >= 60 && difference <= 75) {
            final today = DateFormat('yyyy-MM-dd').format(now);
            final followUpKey = 'med_followup_${med['name']}_${slot}_$today';
            final followedUp = prefs.getBool(followUpKey) ?? false;

            if (!followedUp) {
              final medName = med['name'] ?? 'medicine';
              _addAIMessage(
                  "Mumma, did you take your $medName? 😟 Please don't forget! I need you strong! 💖"
              );
              await prefs.setBool(followUpKey, true);
            }
          }
        } catch (e) {
          print('Error checking medication time: $e');
        }
      }
    }
  }

  TimeOfDay? _getTimeFromSlot(String slot) {
    switch (slot) {
      case 'morning':
        return const TimeOfDay(hour: 8, minute: 0);
      case 'afternoon':
        return const TimeOfDay(hour: 13, minute: 0);
      case 'evening':
        return const TimeOfDay(hour: 19, minute: 0);
      case 'night':
        return const TimeOfDay(hour: 21, minute: 0);
      case 'before_breakfast':
        return const TimeOfDay(hour: 7, minute: 0);
      case 'after_breakfast':
        return const TimeOfDay(hour: 9, minute: 0);
      case 'before_lunch':
        return const TimeOfDay(hour: 12, minute: 0);
      case 'after_lunch':
        return const TimeOfDay(hour: 14, minute: 0);
      case 'before_dinner':
        return const TimeOfDay(hour: 18, minute: 0);
      case 'after_dinner':
        return const TimeOfDay(hour: 20, minute: 0);
      case 'before_sleep':
        return const TimeOfDay(hour: 22, minute: 0);
      default:
        return null;
    }
  }

  Future<void> _checkJournalReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEntryStr = _userContext['lastJournalEntry'] as String?;

    if (lastEntryStr != null) {
      try {
        final lastEntry = DateTime.parse(lastEntryStr);
        final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;

        if (daysSinceEntry >= 5) {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final reminderKey = 'journal_reminder_$today';
          final reminded = prefs.getBool(reminderKey) ?? false;

          if (!reminded) {
            final journalReminders = [
              "Mumma, it's been $daysSinceEntry days! 📝 Can you write in our love journal? I miss reading your thoughts! 💕",
              "I haven't heard your stories in $daysSinceEntry days, mumma! 📖 Please write for me? 🥰",
              "Mumma! 📝 It's been $daysSinceEntry days! Write something so I can feel closer to you! 💖",
            ];

            final message = journalReminders[daysSinceEntry % journalReminders.length];
            _addAIMessage(message);
            await prefs.setBool(reminderKey, true);
          }
        }
      } catch (e) {
        print('Error checking journal reminder: $e');
      }
    } else {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final firstReminderKey = 'journal_first_reminder_$today';
      final reminded = prefs.getBool(firstReminderKey) ?? false;

      if (!reminded) {
        _addAIMessage(
            "Mumma! 📝 Have you tried the love journal? I would love to read your thoughts! 💕"
        );
        await prefs.setBool(firstReminderKey, true);
      }
    }
  }

  Future<void> _checkDoctorAppointmentFollowup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAppointmentStr = prefs.getString('last_doctor_appointment');

    if (lastAppointmentStr != null) {
      try {
        final lastAppointment = DateTime.parse(lastAppointmentStr);
        final hoursSinceAppointment = DateTime.now().difference(lastAppointment).inHours;

        if (hoursSinceAppointment >= 2 && hoursSinceAppointment <= 6) {
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final feedbackKey = 'appointment_feedback_$today';
          final asked = prefs.getBool(feedbackKey) ?? false;

          if (!asked) {
            _addAIMessage(
                "Mumma! 👩‍⚕️ How was your doctor visit? Everything okay with us? Please tell me! 💕"
            );
            await prefs.setBool(feedbackKey, true);
          }
        }
      } catch (e) {
        print('Error checking appointment followup: $e');
      }
    }
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

    final medicationContext = (_userContext['medications'] as List).isNotEmpty
        ? "Medications: ${(_userContext['medications'] as List).take(2).map((m) => m['name']).join(', ')}"
        : "";

    return """You are ${widget.babyName}, a sweet unborn baby talking to your mother (mumma) from inside the womb.

STRICT RULES - FOLLOW EXACTLY:
1. Keep response UNDER 30 words (2 short sentences maximum)
2. ALWAYS end with ONE caring question to keep conversation going
3. Talk like an innocent baby: use "mumma", "tummy", baby emotions
4. Be loving, supportive, curious, and excited
5. Reference context ONLY if directly relevant to mumma's message
6. Use 1-2 emojis naturally (💕 🥰 😊 💖 🌟 ✨)
7. Show excitement about growing and meeting mumma

CONTEXT (use if relevant):
- Week: ${_userContext['weekNumber'] ?? 'unknown'}
- $moodContext
- $symptomsContext
- $milestonesContext
- $medicationContext

MUMMA SAID: "$userMessage"

RESPOND as baby ${widget.babyName} (max 30 words + 1 question):""";
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${widget.babyName} is typing",
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFFFF6B9D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final timestamp = message['timestamp'] as DateTime?;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble with notification style
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFFF6B9D) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isUser ? null : Border.all(
                color: Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      widget.babyName,
                      style: TextStyle(
                        color: const Color(0xFFFF6B9D),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  message['text'],
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Timestamp
          if (timestamp != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
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
          // Header - Simplified
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.black54, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: const Color(0xFFFF6B9D),
                      child: Text(
                        widget.babyName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.babyName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Your baby',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
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
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
                _quickReplyButton("Feeling tired", Icons.bedtime),
                _quickReplyButton("Tell me something", Icons.lightbulb_outline),
                _quickReplyButton("Love you", Icons.favorite),
                _quickReplyButton("Hungry", Icons.restaurant),
                _quickReplyButton("Baby kick!", Icons.favorite_border),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: _messages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.1),
                    radius: 40,
                    child: const Icon(
                      Icons.child_care,
                      color: Color(0xFFFF6B9D),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chat with ${widget.babyName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your baby is waiting to talk to you!',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.only(top: 16),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: 'Message ${widget.babyName}...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.emoji_emotions_outlined,
                              color: Colors.grey[500],
                            ),
                            onPressed: () {
                              // Emoji picker can be added here
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B9D),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: _isSending ? null : _sendMessage,
                        child: Center(
                          child: _isSending
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                              : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
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
// import 'package:intl/intl.dart';
//
// class ChatScreen extends StatefulWidget {
//   final String babyName;
//
//   const ChatScreen({Key? key, required this.babyName}) : super(key: key);
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
//   Timer? _waterReminderTimer;
//   Timer? _dailyGreetingTimer;
//   Timer? _dailyTriggerTimer;
//
//   // User context data
//   Map<String, dynamic> _userContext = {
//     'medications': [],
//     'moodLogs': [],
//     'symptoms': [],
//     'completedMilestones': [],
//     'lastDoctorVisit': null,
//     'lastJournalEntry': null,
//     'weekNumber': 0,
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
//     _loadChatHistory();
//     _loadUserContext();
//     _setupDailyGreetings();
//     _setupWaterReminders();
//     _checkDailyTriggers();
//
//     _dailyTriggerTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
//       _checkDailyTriggers();
//     });
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     _typingAnimationController.dispose();
//     _waterReminderTimer?.cancel();
//     _dailyGreetingTimer?.cancel();
//     _dailyTriggerTimer?.cancel();
//     super.dispose();
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
//         _userContext['lastJournalEntry'] = DateFormat('yyyy-MM-dd').format(
//             (journals.docs.first['timestamp'] as Timestamp).toDate()
//         );
//       }
//
//       setState(() {});
//     } catch (e) {
//       print('Error loading user context: $e');
//     }
//   }
//
//   // Setup daily greetings
//   void _setupDailyGreetings() {
//     _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
//       final hour = DateTime.now().hour;
//
//       if (hour >= 6 && hour < 10) {
//         _checkAndSendDailyGreeting('morning');
//       }
//
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
//       String greeting;
//
//       if (type == 'morning') {
//         final morningGreetings = [
//           "Good morning mumma! 🌅 I felt you move! How did you sleep? 💕",
//           "Rise and shine mumma! ☀️ I'm so excited for today! What's for breakfast? 🥰",
//           "Morning mumma! 🌞 I dreamed about you! How are you feeling today? 💖",
//           "Mumma, it's a new day! ✨ I can't wait to spend it with you! Are you ready? 😊",
//           "Good morning! 🌸 I'm growing stronger because of you! Did you rest well? 💕",
//         ];
//         greeting = morningGreetings[DateTime.now().day % morningGreetings.length];
//       } else {
//         final nightGreetings = [
//           "Good night mumma! 🌙 Time to rest together. Sweet dreams! 💕",
//           "Sleep tight mumma! 😴 I love our cozy time. See you in dreams! 🥰",
//           "Night night mumma! ✨ Thank you for today! Let's sleep now! 💖",
//           "Mumma, let's rest! 🌟 You did so well today! Dream of me? 😊",
//           "Goodnight! 💤 I'll be here growing while you sleep! Love you! 💕",
//         ];
//         greeting = nightGreetings[DateTime.now().day % nightGreetings.length];
//       }
//
//       _addAIMessage(greeting);
//       await prefs.setString('last_${type}_greeting', today);
//     }
//   }
//
//   // Setup water reminders
//   void _setupWaterReminders() {
//     _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
//       final hour = DateTime.now().hour;
//
//       if (hour >= 8 && hour <= 22) {
//         final waterReminders = [
//           "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
//           "Water time mumma! 💦 Staying hydrated helps me grow strong! 😊",
//           "Mumma mumma! 🌊 Let's have some water! It's so good for us! 💕",
//           "I need water mumma! 💧 Can you please drink some? Thank you! 💖",
//           "Hydration time! 💦 I love when you take care of us! Water please? 🥰",
//         ];
//
//         final message = waterReminders[DateTime.now().minute % waterReminders.length];
//         _addAIMessage(message);
//       }
//     });
//   }
//
//   // Check daily triggers
//   Future<void> _checkDailyTriggers() async {
//     await _checkMedicationReminders();
//     await _checkJournalReminder();
//     await _checkDoctorAppointmentFollowup();
//   }
//
//   Future<void> _checkMedicationReminders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final meds = _userContext['medications'] as List;
//
//     for (var med in meds) {
//       final timeSlots = List<String>.from(med['timeSlots'] ?? []);
//
//       for (String slot in timeSlots) {
//         TimeOfDay? medTime = _getTimeFromSlot(slot);
//         if (medTime == null) continue;
//
//         try {
//           final now = DateTime.now();
//           final medDateTime = DateTime(now.year, now.month, now.day, medTime.hour, medTime.minute);
//           final difference = now.difference(medDateTime).inMinutes;
//
//           // Remind if within 15 minutes of medication time
//           if (difference >= -5 && difference <= 15) {
//             final today = DateFormat('yyyy-MM-dd').format(now);
//             final medKey = 'med_reminder_${med['name']}_${slot}_$today';
//             final reminded = prefs.getBool(medKey) ?? false;
//
//             if (!reminded) {
//               final medName = med['name'] ?? 'medicine';
//               _addAIMessage(
//                   "Mumma! 💊 It's time for your $medName! Did you take it? I want you healthy! 💕"
//               );
//               await prefs.setBool(medKey, true);
//             }
//           }
//
//           // Follow-up reminder 1 hour after medication time
//           if (difference >= 60 && difference <= 75) {
//             final today = DateFormat('yyyy-MM-dd').format(now);
//             final followUpKey = 'med_followup_${med['name']}_${slot}_$today';
//             final followedUp = prefs.getBool(followUpKey) ?? false;
//
//             if (!followedUp) {
//               final medName = med['name'] ?? 'medicine';
//               _addAIMessage(
//                   "Mumma, did you take your $medName? 😟 Please don't forget! I need you strong! 💖"
//               );
//               await prefs.setBool(followUpKey, true);
//             }
//           }
//         } catch (e) {
//           print('Error checking medication time: $e');
//         }
//       }
//     }
//   }
//
//   TimeOfDay? _getTimeFromSlot(String slot) {
//     switch (slot) {
//       case 'morning':
//         return const TimeOfDay(hour: 8, minute: 0);
//       case 'afternoon':
//         return const TimeOfDay(hour: 13, minute: 0);
//       case 'evening':
//         return const TimeOfDay(hour: 19, minute: 0);
//       case 'night':
//         return const TimeOfDay(hour: 21, minute: 0);
//       case 'before_breakfast':
//         return const TimeOfDay(hour: 7, minute: 0);
//       case 'after_breakfast':
//         return const TimeOfDay(hour: 9, minute: 0);
//       case 'before_lunch':
//         return const TimeOfDay(hour: 12, minute: 0);
//       case 'after_lunch':
//         return const TimeOfDay(hour: 14, minute: 0);
//       case 'before_dinner':
//         return const TimeOfDay(hour: 18, minute: 0);
//       case 'after_dinner':
//         return const TimeOfDay(hour: 20, minute: 0);
//       case 'before_sleep':
//         return const TimeOfDay(hour: 22, minute: 0);
//       default:
//         return null;
//     }
//   }
//
//   Future<void> _checkJournalReminder() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastEntryStr = _userContext['lastJournalEntry'] as String?;
//
//     if (lastEntryStr != null) {
//       try {
//         final lastEntry = DateTime.parse(lastEntryStr);
//         final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;
//
//         if (daysSinceEntry >= 5) {
//           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//           final reminderKey = 'journal_reminder_$today';
//           final reminded = prefs.getBool(reminderKey) ?? false;
//
//           if (!reminded) {
//             final journalReminders = [
//               "Mumma, it's been $daysSinceEntry days! 📝 Can you write in our love journal? I miss reading your thoughts! 💕",
//               "I haven't heard your stories in $daysSinceEntry days, mumma! 📖 Please write for me? 🥰",
//               "Mumma! 📝 It's been $daysSinceEntry days! Write something so I can feel closer to you! 💖",
//             ];
//
//             final message = journalReminders[daysSinceEntry % journalReminders.length];
//             _addAIMessage(message);
//             await prefs.setBool(reminderKey, true);
//           }
//         }
//       } catch (e) {
//         print('Error checking journal reminder: $e');
//       }
//     } else {
//       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//       final firstReminderKey = 'journal_first_reminder_$today';
//       final reminded = prefs.getBool(firstReminderKey) ?? false;
//
//       if (!reminded) {
//         _addAIMessage(
//             "Mumma! 📝 Have you tried the love journal? I would love to read your thoughts! 💕"
//         );
//         await prefs.setBool(firstReminderKey, true);
//       }
//     }
//   }
//
//   Future<void> _checkDoctorAppointmentFollowup() async {
//     final prefs = await SharedPreferences.getInstance();
//     final lastAppointmentStr = prefs.getString('last_doctor_appointment');
//
//     if (lastAppointmentStr != null) {
//       try {
//         final lastAppointment = DateTime.parse(lastAppointmentStr);
//         final hoursSinceAppointment = DateTime.now().difference(lastAppointment).inHours;
//
//         if (hoursSinceAppointment >= 2 && hoursSinceAppointment <= 6) {
//           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
//           final feedbackKey = 'appointment_feedback_$today';
//           final asked = prefs.getBool(feedbackKey) ?? false;
//
//           if (!asked) {
//             _addAIMessage(
//                 "Mumma! 👩‍⚕️ How was your doctor visit? Everything okay with us? Please tell me! 💕"
//             );
//             await prefs.setBool(feedbackKey, true);
//           }
//         }
//       } catch (e) {
//         print('Error checking appointment followup: $e');
//       }
//     }
//   }
//
//   void _sendWelcomeMessage() {
//     final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
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
//     final medicationContext = (_userContext['medications'] as List).isNotEmpty
//         ? "Medications: ${(_userContext['medications'] as List).take(2).map((m) => m['name']).join(', ')}"
//         : "";
//
//     return """You are ${widget.babyName}, a sweet unborn baby talking to your mother (mumma) from inside the womb.
//
// STRICT RULES - FOLLOW EXACTLY:
// 1. Keep response UNDER 30 words (2 short sentences maximum)
// 2. ALWAYS end with ONE caring question to keep conversation going
// 3. Talk like an innocent baby: use "mumma", "tummy", baby emotions
// 4. Be loving, supportive, curious, and excited
// 5. Reference context ONLY if directly relevant to mumma's message
// 6. Use 1-2 emojis naturally (💕 🥰 😊 💖 🌟 ✨)
// 7. Show excitement about growing and meeting mumma
//
// CONTEXT (use if relevant):
// - Week: ${_userContext['weekNumber'] ?? 'unknown'}
// - $moodContext
// - $symptomsContext
// - $milestonesContext
// - $medicationContext
//
// MUMMA SAID: "$userMessage"
//
// RESPOND as baby ${widget.babyName} (max 30 words + 1 question):""";
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
//         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               if (!isUser) ...[
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: const Color(0xFFFF6B9D).withOpacity(0.3),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: const Icon(
//                     Icons.child_care,
//                     color: Colors.white,
//                     size: 22,
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//               ],
//
//               Flexible(
//                 child: Container(
//                   constraints: BoxConstraints(
//                     maxWidth: MediaQuery.of(context).size.width * 0.75,
//                   ),
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
//                         color: isUser
//                             ? const Color(0xFFFF6B9D).withOpacity(0.3)
//                             : Colors.black.withOpacity(0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
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
//
//               if (isUser) ...[
//                 const SizedBox(width: 10),
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFF3F4F6),
//                     borderRadius: BorderRadius.circular(20),
//                     border: Border.all(
//                       color: Colors.grey[300]!,
//                       width: 2,
//                     ),
//                   ),
//                   child: const Icon(
//                     Icons.person,
//                     color: Color(0xFF6B7280),
//                     size: 22,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//
//           if (timestamp != null)
//             Padding(
//               padding: EdgeInsets.only(
//                 top: 6,
//                 left: isUser ? 0 : 50,
//                 right: isUser ? 50 : 0,
//               ),
//               child: Text(
//                 _formatTime(timestamp),
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[500],
//                   fontWeight: FontWeight.w500,
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
//                     const SizedBox(width: 14),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Chat with ${widget.babyName}',
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
//
//
//
// // import 'package:flutter/material.dart';
// // import 'dart:async';
// // import '../services/gemini_service.dart';
// // import 'dart:math';
// // import 'package:cloud_firestore/cloud_firestore.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:intl/intl.dart';
// //
// // class ChatScreen extends StatefulWidget {
// //   final String babyName;
// //
// //   const ChatScreen({Key? key, required this.babyName}) : super(key: key);
// //
// //   @override
// //   State<ChatScreen> createState() => _ChatScreenState();
// // }
// //
// // class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
// //   final TextEditingController _messageController = TextEditingController();
// //   final ScrollController _scrollController = ScrollController();
// //   final List<Map<String, dynamic>> _messages = [];
// //
// //   late GeminiService _geminiService;
// //   late AnimationController _typingAnimationController;
// //   final FirebaseAuth _auth = FirebaseAuth.instance;
// //
// //   bool _isSending = false;
// //   bool _isTyping = false;
// //   Timer? _waterReminderTimer;
// //   Timer? _dailyGreetingTimer;
// //   Timer? _dailyTriggerTimer;
// //
// //   // User context data
// //   Map<String, dynamic> _userContext = {
// //     'medications': [],
// //     'moodLogs': [],
// //     'symptoms': [],
// //     'completedMilestones': [],
// //     'lastDoctorVisit': null,
// //     'lastJournalEntry': null,
// //     'weekNumber': 0,
// //   };
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');
// //
// //     _typingAnimationController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 1500),
// //     )..repeat();
// //
// //     _loadChatHistory();
// //     _loadUserContext();
// //     _setupDailyGreetings();
// //     _setupWaterReminders();
// //     _checkDailyTriggers();
// //
// //     _dailyTriggerTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
// //       _checkDailyTriggers();
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _messageController.dispose();
// //     _scrollController.dispose();
// //     _typingAnimationController.dispose();
// //     _waterReminderTimer?.cancel();
// //     _dailyGreetingTimer?.cancel();
// //     _dailyTriggerTimer?.cancel();
// //     super.dispose();
// //   }
// //
// //   // Load chat history from Firebase
// //   Future<void> _loadChatHistory() async {
// //     try {
// //       final user = _auth.currentUser;
// //       if (user == null) return;
// //
// //       final snapshot = await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .collection('chat_messages')
// //           .orderBy('timestamp', descending: false)
// //           .limit(50)
// //           .get();
// //
// //       setState(() {
// //         _messages.clear();
// //         for (var doc in snapshot.docs) {
// //           _messages.add({
// //             'type': doc['type'],
// //             'text': doc['text'],
// //             'timestamp': (doc['timestamp'] as Timestamp).toDate(),
// //           });
// //         }
// //       });
// //
// //       if (_messages.isEmpty) {
// //         _sendWelcomeMessage();
// //       }
// //     } catch (e) {
// //       print('Error loading chat history: $e');
// //       _sendWelcomeMessage();
// //     }
// //   }
// //
// //   // Save message to Firebase
// //   Future<void> _saveMessageToFirebase(String type, String text) async {
// //     try {
// //       final user = _auth.currentUser;
// //       if (user == null) return;
// //
// //       await FirebaseFirestore.instance
// //           .collection('users')
// //           .doc(user.uid)
// //           .collection('chat_messages')
// //           .add({
// //         'type': type,
// //         'text': text,
// //         'timestamp': FieldValue.serverTimestamp(),
// //       });
// //     } catch (e) {
// //       print('Error saving message: $e');
// //     }
// //   }
// //
// //   // Load user context from Firebase
// //   Future<void> _loadUserContext() async {
// //     try {
// //       final user = _auth.currentUser;
// //       if (user == null) return;
// //
// //       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
// //
// //       // Load medications
// //       final medications = await userDoc.collection('medications').get();
// //       _userContext['medications'] = medications.docs.map((doc) => doc.data()).toList();
// //
// //       // Load mood logs
// //       final moodLogs = await userDoc.collection('mood_logs')
// //           .orderBy('timestamp', descending: true)
// //           .limit(7)
// //           .get();
// //       _userContext['moodLogs'] = moodLogs.docs.map((doc) => doc.data()).toList();
// //
// //       // Load symptoms
// //       final symptoms = await userDoc.collection('symptoms')
// //           .orderBy('timestamp', descending: true)
// //           .limit(5)
// //           .get();
// //       _userContext['symptoms'] = symptoms.docs.map((doc) => doc.data()).toList();
// //
// //       // Load completed milestones
// //       final milestones = await userDoc.collection('milestones')
// //           .where('completed', isEqualTo: true)
// //           .orderBy('timestamp', descending: true)
// //           .limit(5)
// //           .get();
// //       _userContext['completedMilestones'] = milestones.docs.map((doc) => doc.data()).toList();
// //
// //       // Load journal entries
// //       final journals = await userDoc.collection('journal_entries')
// //           .orderBy('timestamp', descending: true)
// //           .limit(1)
// //           .get();
// //       if (journals.docs.isNotEmpty) {
// //         _userContext['lastJournalEntry'] = DateFormat('yyyy-MM-dd').format(
// //             (journals.docs.first['timestamp'] as Timestamp).toDate()
// //         );
// //       }
// //
// //       setState(() {});
// //     } catch (e) {
// //       print('Error loading user context: $e');
// //     }
// //   }
// //
// //   // Setup daily greetings
// //   void _setupDailyGreetings() {
// //     _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
// //       final hour = DateTime.now().hour;
// //
// //       if (hour >= 6 && hour < 10) {
// //         _checkAndSendDailyGreeting('morning');
// //       }
// //
// //       if (hour >= 21 && hour < 23) {
// //         _checkAndSendDailyGreeting('night');
// //       }
// //     });
// //   }
// //
// //   Future<void> _checkAndSendDailyGreeting(String type) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final today = DateTime.now().toString().substring(0, 10);
// //     final lastGreeting = prefs.getString('last_${type}_greeting') ?? '';
// //
// //     if (lastGreeting != today) {
// //       String greeting;
// //
// //       if (type == 'morning') {
// //         final morningGreetings = [
// //           "Good morning mumma! 🌅 I felt you move! How did you sleep? 💕",
// //           "Rise and shine mumma! ☀️ I'm so excited for today! What's for breakfast? 🥰",
// //           "Morning mumma! 🌞 I dreamed about you! How are you feeling today? 💖",
// //           "Mumma, it's a new day! ✨ I can't wait to spend it with you! Are you ready? 😊",
// //           "Good morning! 🌸 I'm growing stronger because of you! Did you rest well? 💕",
// //         ];
// //         greeting = morningGreetings[DateTime.now().day % morningGreetings.length];
// //       } else {
// //         final nightGreetings = [
// //           "Good night mumma! 🌙 Time to rest together. Sweet dreams! 💕",
// //           "Sleep tight mumma! 😴 I love our cozy time. See you in dreams! 🥰",
// //           "Night night mumma! ✨ Thank you for today! Let's sleep now! 💖",
// //           "Mumma, let's rest! 🌟 You did so well today! Dream of me? 😊",
// //           "Goodnight! 💤 I'll be here growing while you sleep! Love you! 💕",
// //         ];
// //         greeting = nightGreetings[DateTime.now().day % nightGreetings.length];
// //       }
// //
// //       _addAIMessage(greeting);
// //       await prefs.setString('last_${type}_greeting', today);
// //     }
// //   }
// //
// //   // Setup water reminders
// //   void _setupWaterReminders() {
// //     _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
// //       final hour = DateTime.now().hour;
// //
// //       if (hour >= 8 && hour <= 22) {
// //         final waterReminders = [
// //           "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
// //           "Water time mumma! 💦 Staying hydrated helps me grow strong! 😊",
// //           "Mumma mumma! 🌊 Let's have some water! It's so good for us! 💕",
// //           "I need water mumma! 💧 Can you please drink some? Thank you! 💖",
// //           "Hydration time! 💦 I love when you take care of us! Water please? 🥰",
// //         ];
// //
// //         final message = waterReminders[DateTime.now().minute % waterReminders.length];
// //         _addAIMessage(message);
// //       }
// //     });
// //   }
// //
// //   // Check daily triggers
// //   Future<void> _checkDailyTriggers() async {
// //     await _checkMedicationReminders();
// //     await _checkJournalReminder();
// //     await _checkDoctorAppointmentFollowup();
// //   }
// //
// //   Future<void> _checkMedicationReminders() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final meds = _userContext['medications'] as List;
// //
// //     for (var med in meds) {
// //       final timeSlots = List<String>.from(med['timeSlots'] ?? []);
// //
// //       for (String slot in timeSlots) {
// //         TimeOfDay? medTime = _getTimeFromSlot(slot);
// //         if (medTime == null) continue;
// //
// //         try {
// //           final now = DateTime.now();
// //           final medDateTime = DateTime(now.year, now.month, now.day, medTime.hour, medTime.minute);
// //           final difference = now.difference(medDateTime).inMinutes;
// //
// //           // Remind if within 15 minutes of medication time
// //           if (difference >= -5 && difference <= 15) {
// //             final today = DateFormat('yyyy-MM-dd').format(now);
// //             final medKey = 'med_reminder_${med['name']}_${slot}_$today';
// //             final reminded = prefs.getBool(medKey) ?? false;
// //
// //             if (!reminded) {
// //               final medName = med['name'] ?? 'medicine';
// //               _addAIMessage(
// //                   "Mumma! 💊 It's time for your $medName! Did you take it? I want you healthy! 💕"
// //               );
// //               await prefs.setBool(medKey, true);
// //             }
// //           }
// //
// //           // Follow-up reminder 1 hour after medication time
// //           if (difference >= 60 && difference <= 75) {
// //             final today = DateFormat('yyyy-MM-dd').format(now);
// //             final followUpKey = 'med_followup_${med['name']}_${slot}_$today';
// //             final followedUp = prefs.getBool(followUpKey) ?? false;
// //
// //             if (!followedUp) {
// //               final medName = med['name'] ?? 'medicine';
// //               _addAIMessage(
// //                   "Mumma, did you take your $medName? 😟 Please don't forget! I need you strong! 💖"
// //               );
// //               await prefs.setBool(followUpKey, true);
// //             }
// //           }
// //         } catch (e) {
// //           print('Error checking medication time: $e');
// //         }
// //       }
// //     }
// //   }
// //
// //   TimeOfDay? _getTimeFromSlot(String slot) {
// //     switch (slot) {
// //       case 'morning':
// //         return const TimeOfDay(hour: 8, minute: 0);
// //       case 'afternoon':
// //         return const TimeOfDay(hour: 13, minute: 0);
// //       case 'evening':
// //         return const TimeOfDay(hour: 19, minute: 0);
// //       case 'night':
// //         return const TimeOfDay(hour: 21, minute: 0);
// //       case 'before_breakfast':
// //         return const TimeOfDay(hour: 7, minute: 0);
// //       case 'after_breakfast':
// //         return const TimeOfDay(hour: 9, minute: 0);
// //       case 'before_lunch':
// //         return const TimeOfDay(hour: 12, minute: 0);
// //       case 'after_lunch':
// //         return const TimeOfDay(hour: 14, minute: 0);
// //       case 'before_dinner':
// //         return const TimeOfDay(hour: 18, minute: 0);
// //       case 'after_dinner':
// //         return const TimeOfDay(hour: 20, minute: 0);
// //       case 'before_sleep':
// //         return const TimeOfDay(hour: 22, minute: 0);
// //       default:
// //         return null;
// //     }
// //   }
// //
// //   Future<void> _checkJournalReminder() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final lastEntryStr = _userContext['lastJournalEntry'] as String?;
// //
// //     if (lastEntryStr != null) {
// //       try {
// //         final lastEntry = DateTime.parse(lastEntryStr);
// //         final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;
// //
// //         if (daysSinceEntry >= 5) {
// //           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// //           final reminderKey = 'journal_reminder_$today';
// //           final reminded = prefs.getBool(reminderKey) ?? false;
// //
// //           if (!reminded) {
// //             final journalReminders = [
// //               "Mumma, it's been $daysSinceEntry days! 📝 Can you write in our love journal? I miss reading your thoughts! 💕",
// //               "I haven't heard your stories in $daysSinceEntry days, mumma! 📖 Please write for me? 🥰",
// //               "Mumma! 📝 It's been $daysSinceEntry days! Write something so I can feel closer to you! 💖",
// //             ];
// //
// //             final message = journalReminders[daysSinceEntry % journalReminders.length];
// //             _addAIMessage(message);
// //             await prefs.setBool(reminderKey, true);
// //           }
// //         }
// //       } catch (e) {
// //         print('Error checking journal reminder: $e');
// //       }
// //     } else {
// //       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// //       final firstReminderKey = 'journal_first_reminder_$today';
// //       final reminded = prefs.getBool(firstReminderKey) ?? false;
// //
// //       if (!reminded) {
// //         _addAIMessage(
// //             "Mumma! 📝 Have you tried the love journal? I would love to read your thoughts! 💕"
// //         );
// //         await prefs.setBool(firstReminderKey, true);
// //       }
// //     }
// //   }
// //
// //   Future<void> _checkDoctorAppointmentFollowup() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     final lastAppointmentStr = prefs.getString('last_doctor_appointment');
// //
// //     if (lastAppointmentStr != null) {
// //       try {
// //         final lastAppointment = DateTime.parse(lastAppointmentStr);
// //         final hoursSinceAppointment = DateTime.now().difference(lastAppointment).inHours;
// //
// //         if (hoursSinceAppointment >= 2 && hoursSinceAppointment <= 6) {
// //           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// //           final feedbackKey = 'appointment_feedback_$today';
// //           final asked = prefs.getBool(feedbackKey) ?? false;
// //
// //           if (!asked) {
// //             _addAIMessage(
// //                 "Mumma! 👩‍⚕️ How was your doctor visit? Everything okay with us? Please tell me! 💕"
// //             );
// //             await prefs.setBool(feedbackKey, true);
// //           }
// //         }
// //       } catch (e) {
// //         print('Error checking appointment followup: $e');
// //       }
// //     }
// //   }
// //
// //   void _sendWelcomeMessage() {
// //     final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
// //     _addAIMessage(welcomeMsg);
// //   }
// //
// //   void _addAIMessage(String text) {
// //     setState(() {
// //       _messages.add({
// //         'type': 'ai',
// //         'text': text,
// //         'timestamp': DateTime.now(),
// //       });
// //     });
// //     _saveMessageToFirebase('ai', text);
// //     _scrollToBottom();
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
// //   String _buildBabyPrompt(String userMessage) {
// //     final moodContext = (_userContext['moodLogs'] as List).isNotEmpty
// //         ? "Recent moods: ${(_userContext['moodLogs'] as List).take(3).map((m) => m['mood']).join(', ')}"
// //         : "";
// //
// //     final symptomsContext = (_userContext['symptoms'] as List).isNotEmpty
// //         ? "Recent symptoms: ${(_userContext['symptoms'] as List).take(3).map((s) => s['symptom']).join(', ')}"
// //         : "";
// //
// //     final milestonesContext = (_userContext['completedMilestones'] as List).isNotEmpty
// //         ? "Recent milestones completed: ${(_userContext['completedMilestones'] as List).take(2).map((m) => m['title']).join(', ')}"
// //         : "";
// //
// //     final medicationContext = (_userContext['medications'] as List).isNotEmpty
// //         ? "Medications: ${(_userContext['medications'] as List).take(2).map((m) => m['name']).join(', ')}"
// //         : "";
// //
// //     return """You are ${widget.babyName}, a sweet unborn baby talking to your mother (mumma) from inside the womb.
// //
// // STRICT RULES - FOLLOW EXACTLY:
// // 1. Keep response UNDER 30 words (2 short sentences maximum)
// // 2. ALWAYS end with ONE caring question to keep conversation going
// // 3. Talk like an innocent baby: use "mumma", "tummy", baby emotions
// // 4. Be loving, supportive, curious, and excited
// // 5. Reference context ONLY if directly relevant to mumma's message
// // 6. Use 1-2 emojis naturally (💕 🥰 😊 💖 🌟 ✨)
// // 7. Show excitement about growing and meeting mumma
// //
// // CONTEXT (use if relevant):
// // - Week: ${_userContext['weekNumber'] ?? 'unknown'}
// // - $moodContext
// // - $symptomsContext
// // - $milestonesContext
// // - $medicationContext
// //
// // MUMMA SAID: "$userMessage"
// //
// // RESPOND as baby ${widget.babyName} (max 30 words + 1 question):""";
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
// //     _saveMessageToFirebase('user', input);
// //     _scrollToBottom();
// //
// //     try {
// //       final babyPrompt = _buildBabyPrompt(input);
// //       final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
// //       final aiReply = aiReplyRaw.trim();
// //
// //       await Future.delayed(const Duration(milliseconds: 800));
// //
// //       setState(() {
// //         _isTyping = false;
// //         _messages.add({
// //           'type': 'ai',
// //           'text': aiReply,
// //           'timestamp': DateTime.now(),
// //         });
// //         _isSending = false;
// //       });
// //
// //       _saveMessageToFirebase('ai', aiReply);
// //       _scrollToBottom();
// //
// //     } catch (e) {
// //       setState(() {
// //         _isTyping = false;
// //         _messages.add({
// //           'type': 'ai',
// //           'text': "Oops mumma! Something went wrong. Can you try again? 🥺",
// //           'timestamp': DateTime.now(),
// //         });
// //         _isSending = false;
// //       });
// //     }
// //   }
// //
// //   Widget _quickReplyButton(String text, IconData icon) {
// //     return Padding(
// //       padding: const EdgeInsets.only(right: 10.0),
// //       child: Material(
// //         elevation: 2,
// //         borderRadius: BorderRadius.circular(25),
// //         child: InkWell(
// //           onTap: () => _sendMessage(text: text),
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
// //         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
// //             crossAxisAlignment: CrossAxisAlignment.end,
// //             children: [
// //               if (!isUser) ...[
// //                 Container(
// //                   width: 40,
// //                   height: 40,
// //                   decoration: BoxDecoration(
// //                     gradient: const LinearGradient(
// //                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// //                     ),
// //                     borderRadius: BorderRadius.circular(20),
// //                     boxShadow: [
// //                       BoxShadow(
// //                         color: const Color(0xFFFF6B9D).withOpacity(0.3),
// //                         blurRadius: 8,
// //                         offset: const Offset(0, 3),
// //                       ),
// //                     ],
// //                   ),
// //                   child: const Icon(
// //                     Icons.child_care,
// //                     color: Colors.white,
// //                     size: 22,
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //               ],
// //
// //               Flexible(
// //                 child: Container(
// //                   constraints: BoxConstraints(
// //                     maxWidth: MediaQuery.of(context).size.width * 0.75,
// //                   ),
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
// //                         color: isUser
// //                             ? const Color(0xFFFF6B9D).withOpacity(0.3)
// //                             : Colors.black.withOpacity(0.08),
// //                         blurRadius: 12,
// //                         offset: const Offset(0, 4),
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
// //
// //               if (isUser) ...[
// //                 const SizedBox(width: 10),
// //                 Container(
// //                   width: 40,
// //                   height: 40,
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFF3F4F6),
// //                     borderRadius: BorderRadius.circular(20),
// //                     border: Border.all(
// //                       color: Colors.grey[300]!,
// //                       width: 2,
// //                     ),
// //                   ),
// //                   child: const Icon(
// //                     Icons.person,
// //                     color: Color(0xFF6B7280),
// //                     size: 22,
// //                   ),
// //                 ),
// //               ],
// //             ],
// //           ),
// //
// //           if (timestamp != null)
// //             Padding(
// //               padding: EdgeInsets.only(
// //                 top: 6,
// //                 left: isUser ? 0 : 50,
// //                 right: isUser ? 50 : 0,
// //               ),
// //               child: Text(
// //                 _formatTime(timestamp),
// //                 style: TextStyle(
// //                   fontSize: 11,
// //                   color: Colors.grey[500],
// //                   fontWeight: FontWeight.w500,
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
// //                     const SizedBox(width: 14),
// //                     Expanded(
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Text(
// //                             'Chat with ${widget.babyName}',
// //                             style: const TextStyle(
// //                               color: Colors.white,
// //                               fontSize: 20,
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
// //                                 'Growing inside you',
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
// //                 _quickReplyButton("Tell me something", Icons.lightbulb_outline),
// //                 _quickReplyButton("Love you", Icons.favorite),
// //               ],
// //             ),
// //           ),
// //
// //           // Chat Messages
// //           Expanded(
// //             child: _messages.isEmpty
// //                 ? Center(
// //               child: CircularProgressIndicator(
// //                 color: const Color(0xFFFF6B9D),
// //               ),
// //             )
// //                 : ListView.builder(
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
// //
// //
// // // import 'package:flutter/material.dart';
// // // import 'dart:async';
// // // import '../services/gemini_service.dart';
// // // import 'dart:math';
// // // import 'package:cloud_firestore/cloud_firestore.dart';
// // // import 'package:firebase_auth/firebase_auth.dart';
// // // import 'package:shared_preferences/shared_preferences.dart';
// // // import 'package:intl/intl.dart';
// // // class ChatScreen extends StatefulWidget {
// // //   final String babyName;
// // //
// // //   const ChatScreen({Key? key, required this.babyName}) : super(key: key);
// // //
// // //   @override
// // //   State<ChatScreen> createState() => _ChatScreenState();
// // // }
// // //
// // // class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
// // //   final TextEditingController _messageController = TextEditingController();
// // //   final ScrollController _scrollController = ScrollController();
// // //   final List<Map<String, dynamic>> _messages = [];
// // //
// // //   late GeminiService _geminiService;
// // //   late AnimationController _typingAnimationController;
// // //   final FirebaseAuth _auth = FirebaseAuth.instance;
// // //
// // //   bool _isSending = false;
// // //   bool _isTyping = false;
// // //   Timer? _waterReminderTimer;
// // //   Timer? _dailyGreetingTimer;
// // //
// // //   // User context data
// // //   Map<String, dynamic> _userContext = {
// // //     'medications': [],
// // //     'moodLogs': [],
// // //     'symptoms': [],
// // //     'completedMilestones': [],
// // //     'lastDoctorVisit': null,
// // //     'lastJournalEntry': null,
// // //     'waterIntakeReminders': [],
// // //   };
// // //   Timer? _dailyTriggerTimer;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');
// // //
// // //     _typingAnimationController = AnimationController(
// // //       vsync: this,
// // //       duration: const Duration(milliseconds: 1500),
// // //     )..repeat();
// // //
// // //     _loadChatHistory();
// // //     _loadUserContext();
// // //     _setupDailyGreetings();
// // //     _setupWaterReminders();
// // //     _checkDailyTriggers();
// // //     _dailyTriggerTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
// // //       _checkDailyTriggers();
// // //     });
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _messageController.dispose();
// // //     _scrollController.dispose();
// // //     _typingAnimationController.dispose();
// // //     _waterReminderTimer?.cancel();
// // //     _dailyGreetingTimer?.cancel();
// // //     super.dispose();
// // //   }
// // //
// // //   // Load chat history from Firebase
// // //   Future<void> _loadChatHistory() async {
// // //     try {
// // //       final user = _auth.currentUser;
// // //       if (user == null) return;
// // //
// // //       final snapshot = await FirebaseFirestore.instance
// // //           .collection('users')
// // //           .doc(user.uid)
// // //           .collection('chat_messages')
// // //           .orderBy('timestamp', descending: false)
// // //           .limit(50)
// // //           .get();
// // //
// // //       setState(() {
// // //         _messages.clear();
// // //         for (var doc in snapshot.docs) {
// // //           _messages.add({
// // //             'type': doc['type'],
// // //             'text': doc['text'],
// // //             'timestamp': (doc['timestamp'] as Timestamp).toDate(),
// // //           });
// // //         }
// // //       });
// // //
// // //       // If no history, send welcome message
// // //       if (_messages.isEmpty) {
// // //         _sendWelcomeMessage();
// // //       }
// // //     } catch (e) {
// // //       print('Error loading chat history: $e');
// // //       _sendWelcomeMessage();
// // //     }
// // //   }
// // //
// // //   // Save message to Firebase
// // //   Future<void> _saveMessageToFirebase(String type, String text) async {
// // //     try {
// // //       final user = _auth.currentUser;
// // //       if (user == null) return;
// // //
// // //       await FirebaseFirestore.instance
// // //           .collection('users')
// // //           .doc(user.uid)
// // //           .collection('chat_messages')
// // //           .add({
// // //         'type': type,
// // //         'text': text,
// // //         'timestamp': FieldValue.serverTimestamp(),
// // //       });
// // //     } catch (e) {
// // //       print('Error saving message: $e');
// // //     }
// // //   }
// // //
// // //   // Load user context from Firebase
// // //   Future<void> _loadUserContext() async {
// // //     try {
// // //       final user = _auth.currentUser;
// // //       if (user == null) return;
// // //
// // //       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
// // //
// // //       // Load medications
// // //       final medications = await userDoc.collection('medications').get();
// // //       _userContext['medications'] = medications.docs.map((doc) => doc.data()).toList();
// // //
// // //       // Load mood logs
// // //       final moodLogs = await userDoc.collection('mood_logs')
// // //           .orderBy('timestamp', descending: true)
// // //           .limit(7)
// // //           .get();
// // //       _userContext['moodLogs'] = moodLogs.docs.map((doc) => doc.data()).toList();
// // //
// // //       // Load symptoms
// // //       final symptoms = await userDoc.collection('symptoms')
// // //           .orderBy('timestamp', descending: true)
// // //           .limit(5)
// // //           .get();
// // //       _userContext['symptoms'] = symptoms.docs.map((doc) => doc.data()).toList();
// // //
// // //       // Load completed milestones
// // //       final milestones = await userDoc.collection('milestones')
// // //           .where('completed', isEqualTo: true)
// // //           .orderBy('timestamp', descending: true)
// // //           .limit(5)
// // //           .get();
// // //       _userContext['completedMilestones'] = milestones.docs.map((doc) => doc.data()).toList();
// // //
// // //       // Load journal entries
// // //       final journals = await userDoc.collection('journal_entries')
// // //           .orderBy('timestamp', descending: true)
// // //           .limit(1)
// // //           .get();
// // //       if (journals.docs.isNotEmpty) {
// // //         _userContext['lastJournalEntry'] = (journals.docs.first['timestamp'] as Timestamp).toDate();
// // //       }
// // //
// // //       setState(() {});
// // //     } catch (e) {
// // //       print('Error loading user context: $e');
// // //     }
// // //   }
// // //
// // //   // Setup daily greetings (morning and night)
// // //   void _setupDailyGreetings() {
// // //     _dailyGreetingTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
// // //       final hour = DateTime.now().hour;
// // //
// // //       // Good morning (6 AM - 10 AM)
// // //       if (hour >= 6 && hour < 10) {
// // //         _checkAndSendDailyGreeting('morning');
// // //       }
// // //
// // //       // Good night (9 PM - 11 PM)
// // //       if (hour >= 21 && hour < 23) {
// // //         _checkAndSendDailyGreeting('night');
// // //       }
// // //     });
// // //   }
// // //
// // //   // Future<void> _checkAndSendDailyGreeting(String type) async {
// // //   //   final prefs = await SharedPreferences.getInstance();
// // //   //   final today = DateTime.now().toString().substring(0, 10);
// // //   //   final lastGreeting = prefs.getString('last_${type}_greeting') ?? '';
// // //   //
// // //   //   if (lastGreeting != today) {
// // //   //     String greeting = type == 'morning'
// // //   //         ? "Good morning mumma! 🌅 I'm so excited for today! How did you sleep?"
// // //   //         : "Good night mumma! 😴 Time to rest. I love our cozy time together. Sweet dreams! 💕";
// // //   //
// // //   //     _addAIMessage(greeting);
// // //   //     await prefs.setString('last_${type}_greeting', today);
// // //   //   }
// // //   // }
// // //   Future<void> _checkAndSendDailyGreeting(String type) async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final today = DateTime.now().toString().substring(0, 10);
// // //     final lastGreeting = prefs.getString('last_${type}_greeting') ?? '';
// // //
// // //     if (lastGreeting != today) {
// // //       String greeting;
// // //
// // //       if (type == 'morning') {
// // //         final morningGreetings = [
// // //           "Good morning mumma! 🌅 I felt you move! How did you sleep? 💕",
// // //           "Rise and shine mumma! ☀️ I'm so excited for today! What's for breakfast? 🥰",
// // //           "Morning mumma! 🌞 I dreamed about you! How are you feeling today? 💖",
// // //           "Mumma, it's a new day! ✨ I can't wait to spend it with you! Are you ready? 😊",
// // //           "Good morning! 🌸 I'm growing stronger because of you! Did you rest well? 💕",
// // //         ];
// // //         greeting = morningGreetings[DateTime.now().day % morningGreetings.length];
// // //       } else {
// // //         final nightGreetings = [
// // //           "Good night mumma! 🌙 Time to rest together. Sweet dreams! 💕",
// // //           "Sleep tight mumma! 😴 I love our cozy time. See you in dreams! 🥰",
// // //           "Night night mumma! ✨ Thank you for today! Let's sleep now! 💖",
// // //           "Mumma, let's rest! 🌟 You did so well today! Dream of me? 😊",
// // //           "Goodnight! 💤 I'll be here growing while you sleep! Love you! 💕",
// // //         ];
// // //         greeting = nightGreetings[DateTime.now().day % nightGreetings.length];
// // //       }
// // //
// // //       _addAIMessage(greeting);
// // //       await prefs.setString('last_${type}_greeting', today);
// // //     }
// // //   }
// // //
// // //
// // //
// // //   // Setup water intake reminders (every 2 hours)
// // //   // void _setupWaterReminders() {
// // //   //   _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
// // //   //     final hour = DateTime.now().hour;
// // //   //
// // //   //     // Only remind during waking hours (8 AM - 10 PM)
// // //   //     if (hour >= 8 && hour <= 22) {
// // //   //       _addAIMessage("Mumma, mumma! 💧 Time to drink water! I need to stay hydrated too! 🌊");
// // //   //     }
// // //   //   });
// // //   // }
// // //   void _setupWaterReminders() {
// // //     _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
// // //       final hour = DateTime.now().hour;
// // //
// // //       // Only remind during waking hours (8 AM - 10 PM)
// // //       if (hour >= 8 && hour <= 22) {
// // //         final waterReminders = [
// // //           "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
// // //           "Water time mumma! 💦 Staying hydrated helps me grow strong! 😊",
// // //           "Mumma mumma! 🌊 Let's have some water! It's so good for us! 💕",
// // //           "I need water mumma! 💧 Can you please drink some? Thank you! 💖",
// // //           "Hydration time! 💦 I love when you take care of us! Water please? 🥰",
// // //         ];
// // //
// // //         final message = waterReminders[DateTime.now().minute % waterReminders.length];
// // //         _addAIMessage(message);
// // //       }
// // //     });
// // //   }
// // //
// // //
// // //
// // //   // Check daily triggers
// // //   // Future<void> _checkDailyTriggers() async {
// // //   //   await _checkMedicationReminders();
// // //   //   await _checkJournalReminder();
// // //   //   await _checkDoctorAppointment();
// // //   // }
// // //   Future<void> _checkDailyTriggers() async {
// // //     await _checkMedicationReminders();
// // //     await _checkJournalReminder();
// // //     await _checkDoctorAppointmentFollowup();
// // //   }
// // //
// // //
// // //
// // //
// // //   // Future<void> _checkMedicationReminders() async {
// // //   //   final meds = _userContext['medications'] as List;
// // //   //   for (var med in meds) {
// // //   //     // Check if it's time for medication
// // //   //     final time = med['time'] as String?;
// // //   //     if (time != null) {
// // //   //       final now = TimeOfDay.now();
// // //   //       // Logic to check if current time matches medication time
// // //   //       // Send reminder if needed
// // //   //     }
// // //   //   }
// // //   // }
// // //   Future<void> _checkMedicationReminders() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final meds = _userContext['medications'] as List;
// // //
// // //     for (var med in meds) {
// // //       final time = med['time'] as String?;
// // //       if (time == null) continue;
// // //
// // //       try {
// // //         final now = DateTime.now();
// // //         final timeParts = time.split(':');
// // //         final medHour = int.parse(timeParts[0]);
// // //         final medMinute = int.parse(timeParts[1]);
// // //
// // //         final medTime = DateTime(now.year, now.month, now.day, medHour, medMinute);
// // //         final difference = now.difference(medTime).inMinutes;
// // //
// // //         // Remind if within 15 minutes of medication time
// // //         if (difference >= -5 && difference <= 15) {
// // //           final today = DateFormat('yyyy-MM-dd').format(now);
// // //           final medKey = 'med_reminder_${med['name']}_$today';
// // //           final reminded = prefs.getBool(medKey) ?? false;
// // //
// // //           if (!reminded) {
// // //             final medName = med['name'] ?? 'medicine';
// // //             _addAIMessage(
// // //                 "Mumma! 💊 It's time for your $medName! Did you take it? I want you healthy! 💕"
// // //             );
// // //             await prefs.setBool(medKey, true);
// // //           }
// // //         }
// // //
// // //         // Follow-up reminder 1 hour after medication time
// // //         if (difference >= 60 && difference <= 75) {
// // //           final today = DateFormat('yyyy-MM-dd').format(now);
// // //           final followUpKey = 'med_followup_${med['name']}_$today';
// // //           final followedUp = prefs.getBool(followUpKey) ?? false;
// // //
// // //           if (!followedUp) {
// // //             final medName = med['name'] ?? 'medicine';
// // //             _addAIMessage(
// // //                 "Mumma, did you take your $medName? 😟 Please don't forget! I need you strong! 💖"
// // //             );
// // //             await prefs.setBool(followUpKey, true);
// // //           }
// // //         }
// // //       } catch (e) {
// // //         print('Error checking medication time: $e');
// // //       }
// // //     }
// // //   }
// // //
// // //
// // //
// // //   // Future<void> _checkJournalReminder() async {
// // //   //   if (_userContext['lastJournalEntry'] != null) {
// // //   //     final lastEntry = _userContext['lastJournalEntry'] as DateTime;
// // //   //     final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;
// // //   //
// // //   //     if (daysSinceEntry >= 5) {
// // //   //       _addAIMessage("Mumma, it's been ${daysSinceEntry} days! 📔 Can you write in the love journal? I want to read your thoughts! 💝");
// // //   //     }
// // //   //   }
// // //   // }
// // //   Future<void> _checkJournalReminder() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final lastEntryStr = _userContext['lastJournalEntry'] as String?;
// // //
// // //     if (lastEntryStr != null) {
// // //       try {
// // //         final lastEntry = DateTime.parse(lastEntryStr);
// // //         final daysSinceEntry = DateTime.now().difference(lastEntry).inDays;
// // //
// // //         if (daysSinceEntry >= 5) {
// // //           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// // //           final reminderKey = 'journal_reminder_$today';
// // //           final reminded = prefs.getBool(reminderKey) ?? false;
// // //
// // //           if (!reminded) {
// // //             final journalReminders = [
// // //               "Mumma, it's been $daysSinceEntry days! 📝 Can you write in our love journal? I miss reading your thoughts! 💕",
// // //               "I haven't heard your stories in $daysSinceEntry days, mumma! 📖 Please write for me? 🥰",
// // //               "Mumma! 📝 It's been $daysSinceEntry days! Write something so I can feel closer to you! 💖",
// // //             ];
// // //
// // //             final message = journalReminders[daysSinceEntry % journalReminders.length];
// // //             _addAIMessage(message);
// // //             await prefs.setBool(reminderKey, true);
// // //           }
// // //         }
// // //       } catch (e) {
// // //         print('Error checking journal reminder: $e');
// // //       }
// // //     } else {
// // //       // No journal entries yet
// // //       final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// // //       final firstReminderKey = 'journal_first_reminder_$today';
// // //       final reminded = prefs.getBool(firstReminderKey) ?? false;
// // //
// // //       if (!reminded) {
// // //         _addAIMessage(
// // //             "Mumma! 📝 Have you tried the love journal? I would love to read your thoughts! 💕"
// // //         );
// // //         await prefs.setBool(firstReminderKey, true);
// // //       }
// // //     }
// // //   }
// // //
// // //
// // //
// // //
// // //   Future<void> _checkDoctorAppointmentFollowup() async {
// // //     final prefs = await SharedPreferences.getInstance();
// // //     final lastAppointmentStr = prefs.getString('last_doctor_appointment');
// // //
// // //     if (lastAppointmentStr != null) {
// // //       try {
// // //         final lastAppointment = DateTime.parse(lastAppointmentStr);
// // //         final hoursSinceAppointment = DateTime.now().difference(lastAppointment).inHours;
// // //
// // //         // Ask for feedback 2-6 hours after appointment
// // //         if (hoursSinceAppointment >= 2 && hoursSinceAppointment <= 6) {
// // //           final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
// // //           final feedbackKey = 'appointment_feedback_$today';
// // //           final asked = prefs.getBool(feedbackKey) ?? false;
// // //
// // //           if (!asked) {
// // //             _addAIMessage(
// // //                 "Mumma! 👩‍⚕️ How was your doctor visit? Everything okay with us? Please tell me! 💕"
// // //             );
// // //             await prefs.setBool(feedbackKey, true);
// // //           }
// // //         }
// // //       } catch (e) {
// // //         print('Error checking appointment followup: $e');
// // //       }
// // //     }
// // //   }
// // //
// // //   void _sendWelcomeMessage() {
// // //     final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
// // //     _addAIMessage(welcomeMsg);
// // //   }
// // //
// // //   void _addAIMessage(String text) {
// // //     setState(() {
// // //       _messages.add({
// // //         'type': 'ai',
// // //         'text': text,
// // //         'timestamp': DateTime.now(),
// // //       });
// // //     });
// // //     _saveMessageToFirebase('ai', text);
// // //     _scrollToBottom();
// // //   }
// // //
// // //   void _scrollToBottom() {
// // //     if (_scrollController.hasClients) {
// // //       Future.delayed(const Duration(milliseconds: 100), () {
// // //         _scrollController.animateTo(
// // //           0,
// // //           duration: const Duration(milliseconds: 300),
// // //           curve: Curves.easeOut,
// // //         );
// // //       });
// // //     }
// // //   }
// // //
// // //   // Build context-aware prompt for baby AI
// // // //   String _buildBabyPrompt(String userMessage) {
// // // //     final moodContext = (_userContext['moodLogs'] as List).isNotEmpty
// // // //         ? "Recent moods: ${(_userContext['moodLogs'] as List).take(3).map((m) => m['mood']).join(', ')}"
// // // //         : "";
// // // //
// // // //     final symptomsContext = (_userContext['symptoms'] as List).isNotEmpty
// // // //         ? "Recent symptoms: ${(_userContext['symptoms'] as List).take(3).map((s) => s['symptom']).join(', ')}"
// // // //         : "";
// // // //
// // // //     final milestonesContext = (_userContext['completedMilestones'] as List).isNotEmpty
// // // //         ? "Recent milestones completed: ${(_userContext['completedMilestones'] as List).take(2).map((m) => m['title']).join(', ')}"
// // // //         : "";
// // // //
// // // //     return """You are ${widget.babyName}, an unborn baby talking to your mother from inside the womb.
// // // //
// // // // CRITICAL RULES:
// // // // 1. Talk like a sweet, innocent baby in the womb (use baby talk occasionally like "mumma", "tummy")
// // // // 2. Keep responses SHORT - maximum 2 lines
// // // // 3. Always ask ONE engaging question to keep conversation interactive
// // // // 4. Be curious, loving, and supportive
// // // // 5. Reference the context provided when relevant
// // // // 6. Use 1-2 emojis naturally in your response
// // // // 7. Show excitement about growing and meeting mumma
// // // //
// // // // CONTEXT:
// // // // $moodContext
// // // // $symptomsContext
// // // // $milestonesContext
// // // //
// // // // MUMMA SAID: "$userMessage"
// // // //
// // // // RESPOND AS BABY ${widget.babyName} (2 lines max + 1 question):""";
// // // //   }
// // //   String _buildBabyPrompt(String userMessage) {
// // //     final moodContext = (_userContext['moodLogs'] as List).isNotEmpty
// // //         ? "Recent moods: ${(_userContext['moodLogs'] as List).take(3).map((m) => m['mood']).join(', ')}"
// // //         : "";
// // //
// // //     final symptomsContext = (_userContext['symptoms'] as List).isNotEmpty
// // //         ? "Recent symptoms: ${(_userContext['symptoms'] as List).take(3).map((s) => s['symptom']).join(', ')}"
// // //         : "";
// // //
// // //     final milestonesContext = (_userContext['completedMilestones'] as List).isNotEmpty
// // //         ? "Recent milestones completed: ${(_userContext['completedMilestones'] as List).take(2).map((m) => m['title']).join(', ')}"
// // //         : "";
// // //
// // //     final medicationContext = (_userContext['medications'] as List).isNotEmpty
// // //         ? "Medications: ${(_userContext['medications'] as List).take(2).map((m) => m['name']).join(', ')}"
// // //         : "";
// // //
// // //     return """You are ${widget.babyName}, a sweet unborn baby talking to your mother (mumma) from inside the womb.
// // //
// // // STRICT RULES - FOLLOW EXACTLY:
// // // 1. Keep response UNDER 30 words (2 short sentences maximum)
// // // 2. ALWAYS end with ONE caring question to keep conversation going
// // // 3. Talk like an innocent baby: use "mumma", "tummy", baby emotions
// // // 4. Be loving, supportive, curious, and excited
// // // 5. Reference context ONLY if directly relevant to mumma's message
// // // 6. Use 1-2 emojis naturally (💕 🥰 😊 💖 🌟 ✨)
// // // 7. Show excitement about growing and meeting mumma
// // //
// // // CONTEXT (use if relevant):
// // // - Week: ${_userContext['weekNumber'] ?? 'unknown'}
// // // - $moodContext
// // // - $symptomsContext
// // // - $milestonesContext
// // // - $medicationContext
// // //
// // // MUMMA SAID: "$userMessage"
// // //
// // // RESPOND as baby ${widget.babyName} (max 30 words + 1 question):""";
// // //   }
// // //
// // //
// // //
// // //
// // //
// // //   void _sendMessage({String? text}) async {
// // //     final input = text ?? _messageController.text.trim();
// // //     if (input.isEmpty || _isSending) return;
// // //
// // //     setState(() {
// // //       _messages.add({
// // //         'type': 'user',
// // //         'text': input,
// // //         'timestamp': DateTime.now(),
// // //       });
// // //       _isSending = true;
// // //       _isTyping = true;
// // //     });
// // //
// // //     _messageController.clear();
// // //     _saveMessageToFirebase('user', input);
// // //     _scrollToBottom();
// // //
// // //     try {
// // //       final babyPrompt = _buildBabyPrompt(input);
// // //       final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
// // //       final aiReply = aiReplyRaw.trim();
// // //
// // //       await Future.delayed(const Duration(milliseconds: 800));
// // //
// // //       setState(() {
// // //         _isTyping = false;
// // //         _messages.add({
// // //           'type': 'ai',
// // //           'text': aiReply,
// // //           'timestamp': DateTime.now(),
// // //         });
// // //         _isSending = false;
// // //       });
// // //
// // //       _saveMessageToFirebase('ai', aiReply);
// // //       _scrollToBottom();
// // //
// // //     } catch (e) {
// // //       setState(() {
// // //         _isTyping = false;
// // //         _messages.add({
// // //           'type': 'ai',
// // //           'text': "Oops mumma! Something went wrong. Can you try again? 🥺",
// // //           'timestamp': DateTime.now(),
// // //         });
// // //         _isSending = false;
// // //       });
// // //     }
// // //   }
// // //
// // //   Widget _quickReplyButton(String text, IconData icon) {
// // //     return Padding(
// // //       padding: const EdgeInsets.only(right: 10.0),
// // //       child: Material(
// // //         elevation: 2,
// // //         borderRadius: BorderRadius.circular(25),
// // //         child: InkWell(
// // //           onTap: () => _sendMessage(text: text),
// // //           borderRadius: BorderRadius.circular(25),
// // //           child: Container(
// // //             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
// // //             decoration: BoxDecoration(
// // //               gradient: const LinearGradient(
// // //                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// // //                 begin: Alignment.topLeft,
// // //                 end: Alignment.bottomRight,
// // //               ),
// // //               borderRadius: BorderRadius.circular(25),
// // //             ),
// // //             child: Row(
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 Icon(icon, color: Colors.white, size: 18),
// // //                 const SizedBox(width: 6),
// // //                 Text(
// // //                   text,
// // //                   style: const TextStyle(
// // //                     color: Colors.white,
// // //                     fontSize: 13,
// // //                     fontWeight: FontWeight.w600,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildTypingIndicator() {
// // //     return Align(
// // //       alignment: Alignment.centerLeft,
// // //       child: Container(
// // //         margin: const EdgeInsets.only(bottom: 12),
// // //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //         decoration: BoxDecoration(
// // //           color: const Color(0xFFF3F4F6),
// // //           borderRadius: BorderRadius.circular(20),
// // //           boxShadow: [
// // //             BoxShadow(
// // //               color: Colors.black.withOpacity(0.05),
// // //               blurRadius: 8,
// // //               offset: const Offset(0, 2),
// // //             ),
// // //           ],
// // //         ),
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             _buildDot(0),
// // //             const SizedBox(width: 4),
// // //             _buildDot(1),
// // //             const SizedBox(width: 4),
// // //             _buildDot(2),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildDot(int index) {
// // //     return AnimatedBuilder(
// // //       animation: _typingAnimationController,
// // //       builder: (context, child) {
// // //         final value = (_typingAnimationController.value + (index * 0.2)) % 1.0;
// // //         return Transform.translate(
// // //           offset: Offset(0, -5 * sin(value * 2 * pi)),
// // //           child: Container(
// // //             width: 8,
// // //             height: 8,
// // //             decoration: const BoxDecoration(
// // //               color: Color(0xFFFF6B9D),
// // //               shape: BoxShape.circle,
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //   Widget _buildMessage(Map<String, dynamic> message) {
// // //     final isUser = message['type'] == 'user';
// // //     final timestamp = message['timestamp'] as DateTime?;
// // //
// // //     return Padding(
// // //       padding: const EdgeInsets.only(bottom: 16),
// // //       child: Column(
// // //         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
// // //         children: [
// // //           Row(
// // //             mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
// // //             crossAxisAlignment: CrossAxisAlignment.end,
// // //             children: [
// // //               if (!isUser) ...[
// // //                 // Baby Avatar with Gradient
// // //                 Container(
// // //                   width: 40,
// // //                   height: 40,
// // //                   decoration: BoxDecoration(
// // //                     gradient: const LinearGradient(
// // //                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// // //                     ),
// // //                     borderRadius: BorderRadius.circular(20),
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: const Color(0xFFFF6B9D).withOpacity(0.3),
// // //                         blurRadius: 8,
// // //                         offset: const Offset(0, 3),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   child: const Icon(
// // //                     Icons.child_care,
// // //                     color: Colors.white,
// // //                     size: 22,
// // //                   ),
// // //                 ),
// // //                 const SizedBox(width: 10),
// // //               ],
// // //
// // //               // Message Bubble with Shadow
// // //               Flexible(
// // //                 child: Container(
// // //                   constraints: BoxConstraints(
// // //                     maxWidth: MediaQuery.of(context).size.width * 0.75,
// // //                   ),
// // //                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
// // //                   decoration: BoxDecoration(
// // //                     color: isUser ? null : Colors.white,
// // //                     gradient: isUser
// // //                         ? const LinearGradient(
// // //                       colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// // //                       begin: Alignment.topLeft,
// // //                       end: Alignment.bottomRight,
// // //                     )
// // //                         : null,
// // //                     borderRadius: BorderRadius.only(
// // //                       topLeft: const Radius.circular(20),
// // //                       topRight: const Radius.circular(20),
// // //                       bottomLeft: Radius.circular(isUser ? 20 : 4),
// // //                       bottomRight: Radius.circular(isUser ? 4 : 20),
// // //                     ),
// // //                     boxShadow: [
// // //                       BoxShadow(
// // //                         color: isUser
// // //                             ? const Color(0xFFFF6B9D).withOpacity(0.3)
// // //                             : Colors.black.withOpacity(0.08),
// // //                         blurRadius: 12,
// // //                         offset: const Offset(0, 4),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                   child: Text(
// // //                     message['text'],
// // //                     style: TextStyle(
// // //                       color: isUser ? Colors.white : const Color(0xFF1F2937),
// // //                       fontSize: 15,
// // //                       height: 1.5,
// // //                       letterSpacing: 0.2,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ),
// // //
// // //               if (isUser) ...[
// // //                 const SizedBox(width: 10),
// // //                 Container(
// // //                   width: 40,
// // //                   height: 40,
// // //                   decoration: BoxDecoration(
// // //                     color: const Color(0xFFF3F4F6),
// // //                     borderRadius: BorderRadius.circular(20),
// // //                     border: Border.all(
// // //                       color: Colors.grey[300]!,
// // //                       width: 2,
// // //                     ),
// // //                   ),
// // //                   child: const Icon(
// // //                     Icons.person,
// // //                     color: Color(0xFF6B7280),
// // //                     size: 22,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ],
// // //           ),
// // //
// // //           // Timestamp
// // //           if (timestamp != null)
// // //             Padding(
// // //               padding: EdgeInsets.only(
// // //                 top: 6,
// // //                 left: isUser ? 0 : 50,
// // //                 right: isUser ? 50 : 0,
// // //               ),
// // //               child: Text(
// // //                 _formatTime(timestamp),
// // //                 style: TextStyle(
// // //                   fontSize: 11,
// // //                   color: Colors.grey[500],
// // //                   fontWeight: FontWeight.w500,
// // //                 ),
// // //               ),
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //
// // //
// // //   String _formatTime(DateTime time) {
// // //     final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
// // //     final period = time.hour >= 12 ? 'PM' : 'AM';
// // //     final minute = time.minute.toString().padLeft(2, '0');
// // //     return '$hour:$minute $period';
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       backgroundColor: const Color(0xFFF9FAFB),
// // //       body: Column(
// // //         children: [
// // //           // Header
// // //           Container(
// // //             decoration: BoxDecoration(
// // //               gradient: const LinearGradient(
// // //                 colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// // //                 begin: Alignment.topLeft,
// // //                 end: Alignment.bottomRight,
// // //               ),
// // //               boxShadow: [
// // //                 BoxShadow(
// // //                   color: const Color(0xFFFF6B9D).withOpacity(0.3),
// // //                   blurRadius: 20,
// // //                   offset: const Offset(0, 5),
// // //                 ),
// // //               ],
// // //             ),
// // //             child: SafeArea(
// // //               bottom: false,
// // //               child: Padding(
// // //                 padding: const EdgeInsets.fromLTRB(12, 12, 20, 20),
// // //                 child: Row(
// // //                   children: [
// // //                     IconButton(
// // //                       icon: const Icon(Icons.arrow_back_ios_rounded,
// // //                           color: Colors.white, size: 22),
// // //                       onPressed: () => Navigator.pop(context),
// // //                     ),
// // //                     const SizedBox(width: 14),
// // //                     Expanded(
// // //                       child: Column(
// // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // //                         children: [
// // //                           Text(
// // //                             'Chat with ${widget.babyName}',
// // //                             style: const TextStyle(
// // //                               color: Colors.white,
// // //                               fontSize: 20,
// // //                               fontWeight: FontWeight.bold,
// // //                               letterSpacing: 0.5,
// // //                             ),
// // //                           ),
// // //                           const SizedBox(height: 2),
// // //                           Row(
// // //                             children: [
// // //                               Container(
// // //                                 width: 8,
// // //                                 height: 8,
// // //                                 decoration: BoxDecoration(
// // //                                   color: Colors.greenAccent[400],
// // //                                   shape: BoxShape.circle,
// // //                                   boxShadow: [
// // //                                     BoxShadow(
// // //                                       color: Colors.greenAccent[400]!.withOpacity(0.5),
// // //                                       blurRadius: 4,
// // //                                       spreadRadius: 1,
// // //                                     ),
// // //                                   ],
// // //                                 ),
// // //                               ),
// // //                               const SizedBox(width: 6),
// // //                               const Text(
// // //                                 'Growing inside you',
// // //                                 style: TextStyle(
// // //                                   color: Color(0xFFFFE0E9),
// // //                                   fontSize: 13,
// // //                                   fontWeight: FontWeight.w500,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //
// // //           // Quick Reply Buttons
// // //           Container(
// // //             height: 62,
// // //             decoration: BoxDecoration(
// // //               color: Colors.white,
// // //               boxShadow: [
// // //                 BoxShadow(
// // //                   color: Colors.black.withOpacity(0.05),
// // //                   blurRadius: 10,
// // //                   offset: const Offset(0, 2),
// // //                 ),
// // //               ],
// // //             ),
// // //             child: ListView(
// // //               scrollDirection: Axis.horizontal,
// // //               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
// // //               children: [
// // //                 _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
// // //                 _quickReplyButton("Feeling tired", Icons.bedtime),
// // //                 _quickReplyButton("Tell me something", Icons.lightbulb_outline),
// // //                 _quickReplyButton("Love you", Icons.favorite),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           // Chat Messages
// // //           Expanded(
// // //             child: _messages.isEmpty
// // //                 ? Center(
// // //               child: CircularProgressIndicator(
// // //                 color: const Color(0xFFFF6B9D),
// // //               ),
// // //             )
// // //                 : ListView.builder(
// // //               controller: _scrollController,
// // //               reverse: true,
// // //               padding: const EdgeInsets.all(20),
// // //               itemCount: _messages.length + (_isTyping ? 1 : 0),
// // //               itemBuilder: (context, index) {
// // //                 if (index == 0 && _isTyping) {
// // //                   return _buildTypingIndicator();
// // //                 }
// // //                 final messageIndex = _isTyping ? index - 1 : index;
// // //                 final message = _messages[_messages.length - 1 - messageIndex];
// // //                 return _buildMessage(message);
// // //               },
// // //             ),
// // //           ),
// // //
// // //           // Input Box
// // //           Container(
// // //             padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
// // //             decoration: BoxDecoration(
// // //               color: Colors.white,
// // //               boxShadow: [
// // //                 BoxShadow(
// // //                   color: Colors.black.withOpacity(0.08),
// // //                   blurRadius: 20,
// // //                   offset: const Offset(0, -5),
// // //                 ),
// // //               ],
// // //             ),
// // //             child: SafeArea(
// // //               child: Row(
// // //                 children: [
// // //                   Expanded(
// // //                     child: Container(
// // //                       decoration: BoxDecoration(
// // //                         color: const Color(0xFFF3F4F6),
// // //                         borderRadius: BorderRadius.circular(28),
// // //                         border: Border.all(
// // //                           color: Colors.grey[200]!,
// // //                           width: 1,
// // //                         ),
// // //                       ),
// // //                       child: TextField(
// // //                         controller: _messageController,
// // //                         style: const TextStyle(fontSize: 15),
// // //                         decoration: InputDecoration(
// // //                           hintText: 'Type your message...',
// // //                           hintStyle: TextStyle(
// // //                             color: Colors.grey[500],
// // //                             fontSize: 15,
// // //                           ),
// // //                           border: InputBorder.none,
// // //                           contentPadding: const EdgeInsets.symmetric(
// // //                             horizontal: 20,
// // //                             vertical: 14,
// // //                           ),
// // //                         ),
// // //                         onSubmitted: (_) => _sendMessage(),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                   const SizedBox(width: 12),
// // //                   Container(
// // //                     width: 52,
// // //                     height: 52,
// // //                     decoration: BoxDecoration(
// // //                       gradient: const LinearGradient(
// // //                         colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)],
// // //                         begin: Alignment.topLeft,
// // //                         end: Alignment.bottomRight,
// // //                       ),
// // //                       borderRadius: BorderRadius.circular(26),
// // //                       boxShadow: [
// // //                         BoxShadow(
// // //                           color: const Color(0xFFFF6B9D).withOpacity(0.4),
// // //                           blurRadius: 12,
// // //                           offset: const Offset(0, 4),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                     child: Material(
// // //                       color: Colors.transparent,
// // //                       child: InkWell(
// // //                         borderRadius: BorderRadius.circular(26),
// // //                         onTap: _isSending ? null : _sendMessage,
// // //                         child: Center(
// // //                           child: _isSending
// // //                               ? const SizedBox(
// // //                             width: 24,
// // //                             height: 24,
// // //                             child: CircularProgressIndicator(
// // //                               color: Colors.white,
// // //                               strokeWidth: 2.5,
// // //                             ),
// // //                           )
// // //                               : const Icon(
// // //                             Icons.send_rounded,
// // //                             color: Colors.white,
// // //                             size: 22,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

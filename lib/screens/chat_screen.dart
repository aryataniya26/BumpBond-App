import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  bool _isSending = false;
  bool _isTyping = false;

  // Timers for various reminders
  Timer? _waterReminderTimer;
  Timer? _dailyGreetingTimer;
  Timer? _dailyTriggerTimer;
  Timer? _medicationCheckTimer;
  Timer? _morningGreetingTimer;

  // User context data with enhanced tracking
  Map<String, dynamic> _userContext = {
    'medications': [],
    'moodLogs': [],
    'symptoms': [],
    'completedMilestones': [],
    'upcomingMilestones': [],
    'lastDoctorVisit': null,
    'lastJournalEntry': null,
    'lastWaterReminder': null,
    'weekNumber': 0,
    'pregnancyStartDate': null,
    'lastMedicationCheck': {},
    'doctorAppointments': [],
  };

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');

    _initializeNotifications();
    _loadChatHistory();
    _loadUserContext();
    _setupAllReminders();
    _setupRealTimeListeners();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _waterReminderTimer?.cancel();
    _dailyGreetingTimer?.cancel();
    _dailyTriggerTimer?.cancel();
    _medicationCheckTimer?.cancel();
    _morningGreetingTimer?.cancel();
    super.dispose();
  }

  // Initialize local notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);
  }

  // Show notification for baby messages
  Future<void> _showBabyNotification(String message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'baby_channel',
      'Baby Messages',
      channelDescription: 'Notifications from your baby',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      '${widget.babyName} 💕',
      message,
      details,
    );
  }

  // Setup all reminder systems
  void _setupAllReminders() {
    _setupDailyGreetings();
    _setupWaterReminders();
    _setupMedicationReminders();
    _setupMorningGreeting();
    _setupRealTimeCheckers();
  }

  // Setup morning greeting at 8 AM
  void _setupMorningGreeting() {
    _morningGreetingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final now = DateTime.now();
      if (now.hour == 8 && now.minute == 0) {
        _sendMorningGreeting();
      }
    });
  }

  // Setup real-time checkers
  void _setupRealTimeCheckers() {
    _dailyTriggerTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkAllTriggers();
    });
  }

  // Check all triggers
  Future<void> _checkAllTriggers() async {
    await _checkMedicationReminders();
    await _checkMoodBasedMessages();
    await _checkSymptomBasedMessages();
    await _checkMilestoneBasedMessages();
    await _checkJournalReminder();
    await _checkDoctorAppointmentFollowup();
    await _checkWaterIntakeReminder();
  }

  // Enhanced user context loading
  Future<void> _loadUserContext() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Load medications with time slots
      final medications = await userDoc.collection('medications').get();
      _userContext['medications'] = medications.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['name'] ?? '',
          'dosage': data['dosage'] ?? '',
          'timeSlots': List<String>.from(data['timeSlots'] ?? []),
          'reminderEnabled': data['reminderEnabled'] ?? true,
        };
      }).toList();

      // Load mood logs (last 7 days)
      final moodLogs = await userDoc.collection('mood_logs')
          .orderBy('timestamp', descending: true)
          .limit(7)
          .get();
      _userContext['moodLogs'] = moodLogs.docs.map((doc) {
        final data = doc.data();
        return {
          'mood': data['mood'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'notes': data['notes'] ?? '',
        };
      }).toList();

      // Load symptoms (last 5 entries)
      final symptoms = await userDoc.collection('symptoms')
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();
      _userContext['symptoms'] = symptoms.docs.map((doc) {
        final data = doc.data();
        return {
          'symptom': data['symptom'] ?? '',
          'intensity': data['intensity'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'notes': data['notes'] ?? '',
        };
      }).toList();

      // Load completed milestones
      final completedMilestones = await userDoc.collection('milestones')
          .where('completed', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();
      _userContext['completedMilestones'] = completedMilestones.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'timestamp': (data['timestamp'] as Timestamp).toDate(),
          'week': data['week'] ?? 0,
        };
      }).toList();

      // Load upcoming milestones
      final upcomingMilestones = await userDoc.collection('milestones')
          .where('completed', isEqualTo: false)
          .orderBy('week', descending: false)
          .limit(5)
          .get();
      _userContext['upcomingMilestones'] = upcomingMilestones.docs.map((doc) {
        final data = doc.data();
        return {
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'week': data['week'] ?? 0,
        };
      }).toList();

      // Load journal entries
      final journals = await userDoc.collection('journal_entries')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();
      if (journals.docs.isNotEmpty) {
        _userContext['lastJournalEntry'] = (journals.docs.first['timestamp'] as Timestamp).toDate();
      }

      // Load doctor appointments
      final appointments = await userDoc.collection('doctor_appointments')
          .orderBy('date', descending: false)
          .where('date', isGreaterThan: Timestamp.now())
          .limit(3)
          .get();
      _userContext['doctorAppointments'] = appointments.docs.map((doc) {
        final data = doc.data();
        return {
          'doctorName': data['doctorName'] ?? '',
          'date': (data['date'] as Timestamp).toDate(),
          'purpose': data['purpose'] ?? '',
        };
      }).toList();

      // Load last doctor visit
      final lastAppointment = await userDoc.collection('doctor_appointments')
          .orderBy('date', descending: true)
          .limit(1)
          .get();
      if (lastAppointment.docs.isNotEmpty) {
        _userContext['lastDoctorVisit'] = (lastAppointment.docs.first['date'] as Timestamp).toDate();
      }

      setState(() {});
    } catch (e) {
      print('Error loading user context: $e');
    }
  }

  // Setup real-time listeners for data changes
  void _setupRealTimeListeners() {
    final user = _auth.currentUser;
    if (user == null) return;

    // Listen for new mood logs
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('mood_logs')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _onNewMoodLog(snapshot.docs.first.data());
      }
    });

    // Listen for new symptoms
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('symptoms')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _onNewSymptom(snapshot.docs.first.data());
      }
    });

    // Listen for completed milestones
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('milestones')
        .where('completed', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _onNewMilestone(snapshot.docs.first.data());
      }
    });

    // Listen for new doctor appointments
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('doctor_appointments')
        .orderBy('date', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _onNewAppointment(snapshot.docs.first.data());
      }
    });
  }

  // Handle new mood log
  void _onNewMoodLog(Map<String, dynamic> moodData) {
    final mood = moodData['mood'] ?? '';
    final notes = moodData['notes'] ?? '';

    String response = '';
    switch (mood.toLowerCase()) {
      case 'happy':
      case 'excited':
        response = "Mumma, I feel your happiness! 🥰 It makes me dance in your tummy! What made you so happy today? 💕";
        break;
      case 'tired':
      case 'exhausted':
        response = "Mumma, I feel you're tired 😴 Let's rest together! Can we take a little nap? 💤";
        break;
      case 'stressed':
      case 'anxious':
        response = "Mumma, I feel your stress 🫂 Let's take deep breaths together! Everything will be okay! 🌸";
        break;
      case 'sad':
        response = "Mumma, I feel your sadness 😔 I'm here with you! Want to talk about it? 💖";
        break;
      default:
        response = "Mumma, I feel your emotions! 🥰 How are you really feeling today? 💕";
    }

    _addAIMessageWithNotification(response);
  }

  // Handle new symptom
  void _onNewSymptom(Map<String, dynamic> symptomData) {
    final symptom = symptomData['symptom'] ?? '';
    final intensity = symptomData['intensity'] ?? '';

    String response = '';
    switch (symptom.toLowerCase()) {
      case 'back pain':
        response = "Mumma, I heard about your back pain! 💆‍♀️ Let's try some gentle stretches! Are you comfortable now? 💕";
        break;
      case 'nausea':
        response = "Mumma, I know you feel sick 🤢 Try some ginger tea! Are you feeling better now? 🥰";
        break;
      case 'headache':
        response = "Mumma, your headache makes me worried! 🫂 Rest in a dark room! Can I help you feel better? 💖";
        break;
      case 'fatigue':
        response = "Mumma, I feel you're tired! 😴 Let's rest together! Did you get enough sleep? 💤";
        break;
      default:
        response = "Mumma, I hope you're taking care of yourself! 🥰 How are you feeling now? 💕";
    }

    _addAIMessageWithNotification(response);
  }

  // Handle new milestone
  void _onNewMilestone(Map<String, dynamic> milestoneData) {
    final title = milestoneData['title'] ?? '';
    final description = milestoneData['description'] ?? '';

    final response = "Mumma! We completed '$title'! 🎉 I'm growing so well because of you! What should we achieve next? 🌟";
    _addAIMessageWithNotification(response);
  }

  // Handle new appointment
  void _onNewAppointment(Map<String, dynamic> appointmentData) {
    final doctorName = appointmentData['doctorName'] ?? '';
    final purpose = appointmentData['purpose'] ?? '';
    final date = (appointmentData['date'] as Timestamp).toDate();

    final response = "Mumma! I saw we have a doctor visit! 👩‍⚕️ I'm excited to see how we're growing! Are you ready? 💕";
    _addAIMessageWithNotification(response);

    // Schedule follow-up question after appointment time
    final appointmentTime = date;
    final now = DateTime.now();
    if (appointmentTime.isAfter(now)) {
      final duration = appointmentTime.difference(now);
      Timer(duration + const Duration(hours: 2), () {
        _addAIMessageWithNotification(
            "Mumma! How was our doctor visit? 👩‍⚕️ Everything okay with us? Please tell me! 💕"
        );
      });
    }
  }

  // Setup daily greetings (morning and night)
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

  // Send morning greeting at 8 AM
  Future<void> _sendMorningGreeting() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastGreeting = prefs.getString('last_morning_greeting') ?? '';

    if (lastGreeting != today) {
      final morningGreetings = [
        "Good morning mumma! 🌅 I felt you wake up! How did you sleep? 💕",
        "Rise and shine mumma! ☀️ I'm so excited for today! What's for breakfast? 🥰",
        "Morning mumma! 🌞 I dreamed about you! How are you feeling today? 💖",
        "Mumma, it's a new day! ✨ I can't wait to spend it with you! Are you ready? 😊",
        "Good morning! 🌸 I'm growing stronger because of you! Did you rest well? 💕",
      ];
      final greeting = morningGreetings[DateTime.now().day % morningGreetings.length];
      _addAIMessageWithNotification(greeting);
      await prefs.setString('last_morning_greeting', today);
    }
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

      _addAIMessageWithNotification(greeting);
      await prefs.setString('last_${type}_greeting', today);
    }
  }

  // Setup water reminders every 2 hours
  void _setupWaterReminders() {
    _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      final hour = DateTime.now().hour;

      if (hour >= 8 && hour <= 22) {
        _sendWaterReminder();
      }
    });
  }

  Future<void> _sendWaterReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final lastReminder = prefs.getString('last_water_reminder') ?? '';

    if (lastReminder != today) {
      final waterReminders = [
        "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
        "Water time mumma! 💦 Staying hydrated helps me grow strong! 😊",
        "Mumma mumma! 🌊 Let's have some water! It's so good for us! 💕",
        "I need water mumma! 💧 Can you please drink some? Thank you! 💖",
        "Hydration time! 💦 I love when you take care of us! Water please? 🥰",
      ];

      final message = waterReminders[DateTime.now().minute % waterReminders.length];
      _addAIMessageWithNotification(message);
      await prefs.setString('last_water_reminder', today);
    }
  }

  // Setup medication reminders
  void _setupMedicationReminders() {
    _medicationCheckTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkMedicationReminders();
    });
  }

  // Enhanced medication reminder system
  Future<void> _checkMedicationReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final meds = _userContext['medications'] as List;

    for (var med in meds) {
      if (med['reminderEnabled'] != true) continue;

      final timeSlots = List<String>.from(med['timeSlots'] ?? []);
      final medName = med['name'] ?? 'medicine';

      for (String slot in timeSlots) {
        final medTime = _getTimeFromSlot(slot);
        if (medTime == null) continue;

        final now = DateTime.now();
        final medDateTime = DateTime(now.year, now.month, now.day, medTime.hour, medTime.minute);
        final difference = now.difference(medDateTime).inMinutes;

        // Initial reminder at medication time
        if (difference >= 0 && difference <= 5) {
          final today = DateFormat('yyyy-MM-dd').format(now);
          final medKey = 'med_reminder_${med['id']}_${slot}_$today';
          final reminded = prefs.getBool(medKey) ?? false;

          if (!reminded) {
            _addAIMessageWithNotification(
                "Mumma! 💊 It's time for your $medName! Did you take it? I want you healthy! 💕"
            );
            await prefs.setBool(medKey, true);
          }
        }

        // Follow-up reminder 30 minutes later
        if (difference >= 30 && difference <= 35) {
          final today = DateFormat('yyyy-MM-dd').format(now);
          final followUpKey = 'med_followup_${med['id']}_${slot}_$today';
          final followedUp = prefs.getBool(followUpKey) ?? false;

          if (!followedUp) {
            _addAIMessageWithNotification(
                "Mumma, did you take your $medName? 😟 Please don't forget! I need you strong! 💖"
            );
            await prefs.setBool(followUpKey, true);
          }
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

  // Mood-based messaging
  Future<void> _checkMoodBasedMessages() async {
    final moodLogs = _userContext['moodLogs'] as List;
    if (moodLogs.isEmpty) return;

    final latestMood = moodLogs.first;
    final moodTime = latestMood['timestamp'] as DateTime;
    final hoursSinceMood = DateTime.now().difference(moodTime).inHours;

    if (hoursSinceMood <= 24) {
      final prefs = await SharedPreferences.getInstance();
      final moodKey = 'mood_followup_${DateFormat('yyyy-MM-dd').format(moodTime)}';
      final followedUp = prefs.getBool(moodKey) ?? false;

      if (!followedUp) {
        final mood = latestMood['mood'] ?? '';
        String message = '';

        switch (mood.toLowerCase()) {
          case 'happy':
            message = "Mumma, I still feel your happiness from yesterday! 🥰 What made you smile today? 💕";
            break;
          case 'tired':
            message = "Mumma, I hope you got good rest! 😴 How are you feeling today? 💤";
            break;
          case 'stressed':
            message = "Mumma, I'm here for you! 🫂 How are you feeling now? 💖";
            break;
          default:
            message = "Mumma, how are you feeling today? 🥰 I love talking with you! 💕";
        }

        _addAIMessageWithNotification(message);
        await prefs.setBool(moodKey, true);
      }
    }
  }

  // Symptom-based messaging
  Future<void> _checkSymptomBasedMessages() async {
    final symptoms = _userContext['symptoms'] as List;
    if (symptoms.isEmpty) return;

    final latestSymptom = symptoms.first;
    final symptomTime = latestSymptom['timestamp'] as DateTime;
    final hoursSinceSymptom = DateTime.now().difference(symptomTime).inHours;

    if (hoursSinceSymptom <= 12) {
      final prefs = await SharedPreferences.getInstance();
      final symptomKey = 'symptom_followup_${DateFormat('yyyy-MM-dd-HH').format(symptomTime)}';
      final followedUp = prefs.getBool(symptomKey) ?? false;

      if (!followedUp) {
        final symptom = latestSymptom['symptom'] ?? '';
        _addAIMessageWithNotification(
            "Mumma, how is your $symptom now? 🥺 I hope you're feeling better! 💕"
        );
        await prefs.setBool(symptomKey, true);
      }
    }
  }

  // Milestone-based messaging
  Future<void> _checkMilestoneBasedMessages() async {
    final milestones = _userContext['completedMilestones'] as List;
    if (milestones.isEmpty) return;

    final latestMilestone = milestones.first;
    final milestoneTime = latestMilestone['timestamp'] as DateTime;
    final daysSinceMilestone = DateTime.now().difference(milestoneTime).inDays;

    if (daysSinceMilestone == 1) {
      final prefs = await SharedPreferences.getInstance();
      final milestoneKey = 'milestone_followup_${DateFormat('yyyy-MM-dd').format(milestoneTime)}';
      final followedUp = prefs.getBool(milestoneKey) ?? false;

      if (!followedUp) {
        final title = latestMilestone['title'] ?? '';
        _addAIMessageWithNotification(
            "Mumma! Yesterday we achieved '$title'! 🎉 I'm still so excited! What's next? 🌟"
        );
        await prefs.setBool(milestoneKey, true);
      }
    }
  }

  // Journal reminder
  Future<void> _checkJournalReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastEntry = _userContext['lastJournalEntry'] as DateTime?;

    if (lastEntry != null) {
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
          _addAIMessageWithNotification(message);
          await prefs.setBool(reminderKey, true);
        }
      }
    } else {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final firstReminderKey = 'journal_first_reminder_$today';
      final reminded = prefs.getBool(firstReminderKey) ?? false;

      if (!reminded) {
        _addAIMessageWithNotification(
            "Mumma! 📝 Have you tried the love journal? I would love to read your thoughts! 💕"
        );
        await prefs.setBool(firstReminderKey, true);
      }
    }
  }

  // Doctor appointment follow-up
  Future<void> _checkDoctorAppointmentFollowup() async {
    final prefs = await SharedPreferences.getInstance();
    final lastAppointment = _userContext['lastDoctorVisit'] as DateTime?;

    if (lastAppointment != null) {
      final hoursSinceAppointment = DateTime.now().difference(lastAppointment).inHours;

      if (hoursSinceAppointment >= 2 && hoursSinceAppointment <= 6) {
        final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final feedbackKey = 'appointment_feedback_$today';
        final asked = prefs.getBool(feedbackKey) ?? false;

        if (!asked) {
          _addAIMessageWithNotification(
              "Mumma! 👩‍⚕️ How was your doctor visit? Everything okay with us? Please tell me! 💕"
          );
          await prefs.setBool(feedbackKey, true);
        }
      }
    }
  }

  // Water intake reminder
  Future<void> _checkWaterIntakeReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final lastWaterReminder = prefs.getString('last_water_reminder_time');

    if (lastWaterReminder == null) {
      _sendWaterReminder();
      return;
    }

    final lastReminderTime = DateTime.parse(lastWaterReminder);
    final hoursSinceReminder = DateTime.now().difference(lastReminderTime).inHours;

    if (hoursSinceReminder >= 2) {
      _sendWaterReminder();
    }
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

  void _sendWelcomeMessage() {
    final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking to you! How are you feeling today? 💕";
    _addAIMessageWithNotification(welcomeMsg);
  }

  void _addAIMessageWithNotification(String text) {
    // Show notification
    _showBabyNotification(text);

    // Add to chat
    _addAIMessage(text);
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

      // Show notification for AI response
      _showBabyNotification(aiReply);

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

  // UI Components (same as before, but enhanced)
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
          // Header
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
// class _ChatScreenState extends State<ChatScreen> {
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   final List<Map<String, dynamic>> _messages = [];
//
//   late GeminiService _geminiService;
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
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Text(
//             "${widget.babyName} is typing",
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 14,
//             ),
//           ),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 20,
//             height: 20,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               valueColor: AlwaysStoppedAnimation<Color>(
//                 const Color(0xFFFF6B9D),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMessage(Map<String, dynamic> message) {
//     final isUser = message['type'] == 'user';
//     final timestamp = message['timestamp'] as DateTime?;
//
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
//       child: Column(
//         crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           // Message bubble with notification style
//           Container(
//             constraints: BoxConstraints(
//               maxWidth: MediaQuery.of(context).size.width * 0.85,
//             ),
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isUser ? const Color(0xFFFF6B9D) : Colors.white,
//               borderRadius: BorderRadius.circular(20),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 8,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//               border: isUser ? null : Border.all(
//                 color: Colors.grey[200]!,
//                 width: 1,
//               ),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (!isUser)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 4),
//                     child: Text(
//                       widget.babyName,
//                       style: TextStyle(
//                         color: const Color(0xFFFF6B9D),
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 Text(
//                   message['text'],
//                   style: TextStyle(
//                     color: isUser ? Colors.white : Colors.black87,
//                     fontSize: 15,
//                     height: 1.4,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Timestamp
//           if (timestamp != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 4),
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
//           // Header - Simplified
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.1),
//                   blurRadius: 10,
//                   offset: const Offset(0, 2),
//                 ),
//               ],
//             ),
//             child: SafeArea(
//               bottom: false,
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back_ios_rounded,
//                           color: Colors.black54, size: 20),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     const SizedBox(width: 8),
//                     CircleAvatar(
//                       backgroundColor: const Color(0xFFFF6B9D),
//                       child: Text(
//                         widget.babyName[0],
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             widget.babyName,
//                             style: const TextStyle(
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           Text(
//                             'Your baby',
//                             style: TextStyle(
//                               color: Colors.grey[600],
//                               fontSize: 12,
//                             ),
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
//             height: 70,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 bottom: BorderSide(
//                   color: Colors.grey[200]!,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               children: [
//                 _quickReplyButton("Feeling good", Icons.sentiment_satisfied_alt),
//                 _quickReplyButton("Feeling tired", Icons.bedtime),
//                 _quickReplyButton("Tell me something", Icons.lightbulb_outline),
//                 _quickReplyButton("Love you", Icons.favorite),
//                 _quickReplyButton("Hungry", Icons.restaurant),
//                 _quickReplyButton("Baby kick!", Icons.favorite_border),
//               ],
//             ),
//           ),
//
//           // Chat Messages
//           Expanded(
//             child: _messages.isEmpty
//                 ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: const Color(0xFFFF6B9D).withOpacity(0.1),
//                     radius: 40,
//                     child: const Icon(
//                       Icons.child_care,
//                       color: Color(0xFFFF6B9D),
//                       size: 40,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Chat with ${widget.babyName}',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black54,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Your baby is waiting to talk to you!',
//                     style: TextStyle(
//                       color: Colors.grey[600],
//                     ),
//                   ),
//                 ],
//               ),
//             )
//                 : ListView.builder(
//               controller: _scrollController,
//               reverse: true,
//               padding: const EdgeInsets.only(top: 16),
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
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.grey[200]!,
//                   width: 1,
//                 ),
//               ),
//             ),
//             child: SafeArea(
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(25),
//                         border: Border.all(
//                           color: Colors.grey[300]!,
//                           width: 1,
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _messageController,
//                               style: const TextStyle(fontSize: 15),
//                               decoration: InputDecoration(
//                                 hintText: 'Message ${widget.babyName}...',
//                                 hintStyle: TextStyle(
//                                   color: Colors.grey[500],
//                                   fontSize: 15,
//                                 ),
//                                 border: InputBorder.none,
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   horizontal: 16,
//                                   vertical: 12,
//                                 ),
//                               ),
//                               onSubmitted: (_) => _sendMessage(),
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               Icons.emoji_emotions_outlined,
//                               color: Colors.grey[500],
//                             ),
//                             onPressed: () {
//                               // Emoji picker can be added here
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Container(
//                     width: 48,
//                     height: 48,
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFFF6B9D),
//                       borderRadius: BorderRadius.circular(24),
//                     ),
//                     child: Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         borderRadius: BorderRadius.circular(24),
//                         onTap: _isSending ? null : _sendMessage,
//                         child: Center(
//                           child: _isSending
//                               ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                               : const Icon(
//                             Icons.send_rounded,
//                             color: Colors.white,
//                             size: 20,
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

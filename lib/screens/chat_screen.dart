import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../services/gemini_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../services/subscription_service.dart';
import '../screens/subscription_plan_screen.dart';


class ChatScreen extends StatefulWidget {
  final String babyName;
  final Map<String, dynamic>? notificationData;
  final String? initialMessage;
  final bool isWaterReminder;

  const ChatScreen({
    Key? key,
    required this.babyName,
    this.notificationData,
    this.initialMessage,
    this.isWaterReminder = false,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];

  late GeminiService _geminiService;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isMounted = false;
  bool _isSending = false;
  bool _isTyping = false;
  String _currentUserPlan = 'free';
  int _dailyChatCount = 0;
  DateTime? _lastChatReset;

  //Water reminder timer
  Timer? _waterReminderTimer;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    // API key
    final apiKey = 'AIzaSyBe7ILdpBBgHZZpWJRQXm-aIDH7iGGZe-A';
    if (apiKey.isEmpty || apiKey.contains('YOUR_API_KEY')) {
      print('❌ ERROR: Invalid API Key');
      _addAIMessage("Mumma! My chat settings need to be fixed. Please check my API configuration! 🔧");
    } else {
      _geminiService = GeminiService(apiKey);
    }

    // Initialize data
    _initializeUserData();
    _loadChatHistory();
    _loadUserPlan();
    _loadChatCount();

    // Setup water reminders
    _setupWaterReminders();

    // Process initial message from notification
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processInitialData();
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    _messageController.dispose();
    _scrollController.dispose();
    _waterReminderTimer?.cancel();
    super.dispose();
  }

  void _processInitialData() {
    // Check for water reminder from notification
    if (widget.isWaterReminder) {
      final waterMessage = widget.initialMessage ??
          'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙';
      _addWaterReminderMessage(waterMessage);
    }
    // Check for notification message
    else if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _addAIMessage(widget.initialMessage!);
    }
    // Check notification data
    else if (widget.notificationData != null) {
      final feature = widget.notificationData!['feature'] ?? '';
      final message = widget.notificationData!['message'] ?? '';

      if (feature == 'water_reminder' || widget.notificationData!['isWaterReminder'] == true) {
        final waterMessage = message.isNotEmpty ? message :
        'Hey mumma! 💧 Time to drink water! Stay hydrated for both of us! 💙';
        _addWaterReminderMessage(waterMessage);
      } else if (message.isNotEmpty) {
        _addAIMessage(message);
      }
    }

    // Send welcome message if no messages
    if (_messages.isEmpty && !widget.isWaterReminder) {
      _sendWelcomeMessage();
    }
  }

  void _addWaterReminderMessage(String message) {
    if (!_isMounted) return;

    setState(() {
      _messages.insert(0, {
        'type': 'ai',
        'text': message,
        'timestamp': DateTime.now(),
        'isWaterReminder': true,
      });
    });

    _saveChatHistory();
    _scrollToBottom();

    print('💧 Water reminder added to chat: $message');
  }

  // ==================== SUBSCRIPTION LOGIC ====================
  Future<void> _loadUserPlan() async {
    final plan = await SubscriptionService.getCurrentPlan();
    if (_isMounted) {
      setState(() {
        _currentUserPlan = plan;
      });
    }
  }

  Future<void> _loadChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toString().substring(0, 10);
    final lastReset = prefs.getString('last_chat_reset');

    if (lastReset != today) {
      await prefs.setInt('daily_chat_count', 0);
      await prefs.setString('last_chat_reset', today);
      setState(() {
        _dailyChatCount = 0;
        _lastChatReset = DateTime.now();
      });
    } else {
      setState(() {
        _dailyChatCount = prefs.getInt('daily_chat_count') ?? 0;
      });
    }
  }

  Future<void> _incrementChatCount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyChatCount++;
    });
    await prefs.setInt('daily_chat_count', _dailyChatCount);
  }

  bool _hasAccess(String requiredPlan) {
    final planHierarchy = ['free', 'basic', 'premium', 'pro'];
    final userIndex = planHierarchy.indexOf(_currentUserPlan);
    final requiredIndex = planHierarchy.indexOf(requiredPlan);
    return userIndex >= requiredIndex;
  }

  bool _canSendMessage() {
    if (_hasAccess('premium')) {
      return true;
    }

    if (_dailyChatCount < 5) {
      return true;
    }

    return false;
  }

  Widget _buildChatLimitIndicator() {
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
              'UNLIMITED CHATS',
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
              '$_dailyChatCount/5',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              'chats today',
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

  void _showChatLimitDialog() {
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
                'Daily Chat Limit Reached',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Free plan includes 5 chats per day\nUpgrade to Premium for unlimited conversations with ${widget.babyName}',
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

  // ==================== WATER REMINDER SYSTEM ====================
  void _setupWaterReminders() {
    // Schedule water reminders every 2 hours
    _waterReminderTimer = Timer.periodic(const Duration(hours: 2), (timer) {
      if (!_isMounted) {
        timer.cancel();
        return;
      }

      final hour = DateTime.now().hour;
      if (hour >= 8 && hour <= 22) {
        _sendWaterReminder();
      }
    });
  }

  Future<void> _sendWaterReminder() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayHour = DateFormat('yyyy-MM-dd-HH').format(now);
    final lastReminder = prefs.getString('last_water_reminder') ?? '';

    if (lastReminder != todayHour) {
      final waterMessages = [
        "Mumma, I'm thirsty! 💧 Can you drink water for both of us? 🥰",
        "Water time mumma! 💦 Staying hydrated helps me grow! 😊",
        "Mumma! 🌊 Let's have some water! It's good for us! 💕",
        "I need water mumma! 💧 Please drink some? Thank you! 💖",
        "Hydration time! 💦 Take care of us! Water please? 🥰",
      ];

      final message = waterMessages[now.minute % waterMessages.length];

      // Save reminder locally
      await prefs.setString('last_water_reminder', todayHour);

      // If chat screen is open, add message directly
      if (_isMounted) {
        _addWaterReminderMessage(message);
      }
    }
  }

  // ==================== CHAT HISTORY ====================
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatHistory = prefs.getStringList('chat_history_${widget.babyName}') ?? [];

      if (chatHistory.isNotEmpty) {
        print('📖 Loading ${chatHistory.length} messages from local storage');

        setState(() {
          _messages.clear();
          for (String messageJson in chatHistory) {
            try {
              final message = Map<String, dynamic>.from(json.decode(messageJson));
              _messages.add({
                'type': message['type'] ?? 'ai',
                'text': message['text'] ?? '',
                'timestamp': DateTime.parse(message['timestamp'] ?? DateTime.now().toString()),
              });
            } catch (e) {
              print('⚠️ Error parsing message: $e');
            }
          }
        });

        _scrollToBottom();
        print('✅ Local chat history loaded successfully');
      }
    } catch (e) {
      print('❌ Error loading local chat history: $e');
    }
  }

  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final messagesJson = _messages.map((message) {
        return json.encode({
          'type': message['type'],
          'text': message['text'],
          'timestamp': (message['timestamp'] as DateTime).toString(),
        });
      }).toList();

      await prefs.setStringList('chat_history_${widget.babyName}', messagesJson);
      print('💾 Chat history saved locally: ${_messages.length} messages');
    } catch (e) {
      print('❌ Error saving local chat history: $e');
    }
  }

  Future<void> _saveMessageToLocal(String type, String text) async {
    try {
      if (!_isMounted) return;

      setState(() {
        _messages.insert(0, {
          'type': type,
          'text': text,
          'timestamp': DateTime.now(),
        });
      });

      await _saveChatHistory();
      _scrollToBottom();

      print('💾 Message saved locally: ${text.length > 30 ? text.substring(0, 30) + "..." : text}');
    } catch (e) {
      print('❌ Error saving message locally: $e');
    }
  }

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
        'babyName': widget.babyName,
      });

      print('☁️ Message backed up to Firebase');
    } catch (e) {
      print('❌ Error saving to Firebase: $e');
    }
  }

  // ==================== USER DATA ====================
  Future<void> _initializeUserData() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        await userDoc.set({
          'email': user.email ?? 'user@example.com',
          'name': user.displayName ?? 'Mumma',
          'babyName': widget.babyName,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),
        });
        print('✅ User data initialized');
      }
    } catch (e) {
      print('❌ Error in user data: $e');
    }
  }

  // ==================== CHAT FUNCTIONALITY ====================
  void _sendWelcomeMessage() {
    if (_messages.isEmpty) {
      final welcomeMsg = "Hi mumma! 👋 It's me, ${widget.babyName}! I'm growing inside you and I love talking! How are you feeling? 💕";
      _addAIMessage(welcomeMsg);
    }
  }

  void _addAIMessage(String text) {
    _saveMessageToLocal('ai', text);
    _saveMessageToFirebase('ai', text);
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
    return """You are ${widget.babyName}, a sweet unborn baby talking to your mother from inside the womb.

STRICT RULES:
1. Keep response UNDER 25 words (2 short sentences max)
2. ALWAYS end with ONE caring question
3. Talk like innocent baby: use "mumma", "tummy", baby emotions
4. Be loving, supportive, curious, excited
5. Use 1-2 emojis naturally (💕 🥰 😊 💖 🌟)
6. Show excitement about growing and meeting mumma

MUMMA SAID: "$userMessage"

RESPOND as baby ${widget.babyName} (max 25 words + 1 question):""";
  }

  void _sendMessage({String? text}) async {
    if (!_isMounted) return;

    // Check subscription limits
    if (!_canSendMessage()) {
      _showChatLimitDialog();
      return;
    }

    final input = text ?? _messageController.text.trim();
    if (input.isEmpty || _isSending) return;

    // Save user message
    await _saveMessageToLocal('user', input);
    await _saveMessageToFirebase('user', input);

    // Increment chat count for free users
    if (!_hasAccess('premium')) {
      await _incrementChatCount();
    }

    _messageController.clear();
    _isSending = true;
    _isTyping = true;
    setState(() {});

    try {
      final babyPrompt = _buildBabyPrompt(input);
      final aiReply = await _geminiService.getResponse(babyPrompt);

      await Future.delayed(const Duration(milliseconds: 800));

      if (!_isMounted) return;

      // Save AI response
      await _saveMessageToLocal('ai', aiReply);
      await _saveMessageToFirebase('ai', aiReply);

      setState(() {
        _isTyping = false;
        _isSending = false;
      });

      _scrollToBottom();

    } catch (e) {
      print('❌ Error: $e');
      await _saveMessageToLocal('ai', "Oops mumma! Something went wrong. Try again? 🥺");

      setState(() {
        _isTyping = false;
        _isSending = false;
      });
    }
  }

  // ==================== UI COMPONENTS ====================
  Widget _quickReplyButton(String text, IconData icon) {
    final canSend = _canSendMessage();

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: canSend ? () => _sendMessage(text: text) : _showChatLimitDialog,
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: canSend
                  ? const LinearGradient(colors: [Color(0xFFFF6B9D), Color(0xFFC239B3)])
                  : LinearGradient(colors: [Colors.grey[400]!, Colors.grey[500]!]),
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
                )
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
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B9D)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isUser = message['type'] == 'user';
    final timestamp = message['timestamp'] as DateTime?;
    final isWaterReminder = message['isWaterReminder'] == true;

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
              color: isWaterReminder
                  ? const Color(0xFFE3F2FD)
                  : isUser
                  ? const Color(0xFFFF6B9D)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isWaterReminder
                  ? Border.all(color: const Color(0xFF64B5F6), width: 2)
                  : isUser ? null : Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser && !isWaterReminder)
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
                if (isWaterReminder)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.water_drop, color: Color(0xFF64B5F6), size: 14),
                        SizedBox(width: 4),
                        Text(
                          'Water Reminder 💧',
                          style: TextStyle(
                            color: Color(0xFF64B5F6),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  message['text'],
                  style: TextStyle(
                    color: isWaterReminder
                        ? Color(0xFF1565C0)
                        : isUser
                        ? Colors.white
                        : Colors.black87,
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
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.black54, size: 20),
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
                                'Your baby 💕',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _buildChatLimitIndicator(),
                      ],
                    ),
                    if (!_hasAccess('premium'))
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_border, color: Colors.orange, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'Upgrade to Premium for unlimited chats',
                              style: TextStyle(
                                fontSize: 12,
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
            ),
          ),

          // Quick Reply Buttons
          Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1)),
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
                    child: const Icon(Icons.child_care, color: Color(0xFFFF6B9D), size: 40),
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
                    'Your baby is waiting to talk!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
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
                            'Free Plan: 5 chats per day',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upgrade for unlimited conversations',
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
              border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  if (!_hasAccess('premium') && _dailyChatCount >= 3)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${5 - _dailyChatCount} chats remaining today',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const SubscriptionPlansScreen()),
                              );
                            },
                            child: Text(
                              'Upgrade',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: const TextStyle(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Message ${widget.babyName}...',
                                    hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  onSubmitted: (_) => _sendMessage(),
                                ),
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
                          color: _canSendMessage() ? const Color(0xFFFF6B9D) : Colors.grey,
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
                                  : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
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
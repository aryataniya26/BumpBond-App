import 'package:flutter/material.dart';
import 'dart:async';
import '../services/gemini_service.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'type': 'ai',
      'text': 'Hello mumma! I\'m TinyTalk, your AI baby companion. How are you feeling today?',
      'emoji': '😊',
      'timestamp': DateTime.now(),
    }
  ];

  late GeminiService _geminiService;
  late FlutterTts _flutterTts;
  late AnimationController _typingAnimationController;

  bool _isSending = false;
  bool _isTyping = false;
  bool _isSpeechEnabled = true;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService('AIzaSyCceYvJdUt2ql4tZk7Ze1DzxCE0r5azQIE');
    _flutterTts = FlutterTts();
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.2);
    _flutterTts.setVolume(1.0);

    _typingAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _flutterTts.stop();
    super.dispose();
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

  // Clean text by removing ALL emojis and special unicode characters
  String _cleanTextForSpeech(String text) {
    // Remove all emojis, symbols, and unicode characters
    // Keep only: letters (English + other languages), numbers, spaces, and basic punctuation
    String cleaned = text
        .replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}]', unicode: true), '') // Emojis
        .replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), '')   // Misc symbols
        .replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), '')   // Dingbats
        .replaceAll(RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true), '')   // Variation selectors
        .replaceAll(RegExp(r'[\u{1F000}-\u{1F02F}]', unicode: true), '') // Mahjong tiles
        .replaceAll(RegExp(r'[\u{1F0A0}-\u{1F0FF}]', unicode: true), '') // Playing cards
        .replaceAll(RegExp(r'[\u{1F100}-\u{1F64F}]', unicode: true), '') // Enclosed characters
        .replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), '') // Transport symbols
        .replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), '') // Supplemental symbols
        .replaceAll(RegExp(r'[🌸💖💕😊😢😴😄🎵🧠🌟💝]'), '')           // Common emojis
        .trim();

    return cleaned;
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
    _scrollToBottom();

    try {
      // Better prompt for baby AI persona
      String babyPrompt = """You are TinyTalk, a cute baby AI companion for expecting mothers. 
Reply in a sweet, caring, supportive tone with short messages (2-3 sentences max). 
You can use 1-2 emojis ONLY at the end of your message.
Be helpful, encouraging, and loving.

User said: $input

Reply warmly:""";

      final aiReplyRaw = await _geminiService.getResponse(babyPrompt);
      final aiReply = aiReplyRaw.trim();

      // Randomly show baby tips (25% chance)
      if (Random().nextInt(4) == 0) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _showBabyTip(_getRandomTip());
        });
      }

      await Future.delayed(const Duration(milliseconds: 700));

      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'text': aiReply,
          'emoji': _aiMoodEmoji(aiReply),
          'timestamp': DateTime.now(),
        });
        _isSending = false;
      });

      _scrollToBottom();

      // Speak ONLY clean text without any emojis
      if (_isSpeechEnabled) {
        final cleanText = _cleanTextForSpeech(aiReply);
        if (cleanText.isNotEmpty) {
          await _flutterTts.speak(cleanText);
        }
      }

    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'type': 'ai',
          'text': "Oops! Something went wrong. Please try again.",
          'emoji': '😢',
          'timestamp': DateTime.now(),
        });
        _isSending = false;
      });
    }
  }

  String _aiMoodEmoji(String text) {
    final lowerText = text.toLowerCase();
    if (lowerText.contains("sleep") || lowerText.contains("tired") || lowerText.contains("rest")) return "😴";
    if (lowerText.contains("happy") || lowerText.contains("great") || lowerText.contains("good") || lowerText.contains("wonderful")) return "😊";
    if (lowerText.contains("sad") || lowerText.contains("sorry") || lowerText.contains("oops")) return "😢";
    if (lowerText.contains("love") || lowerText.contains("care") || lowerText.contains("heart")) return "💕";
    if (lowerText.contains("laugh") || lowerText.contains("fun") || lowerText.contains("haha")) return "😄";
    if (lowerText.contains("baby") || lowerText.contains("little")) return "👶";
    return "🌸";
  }

  String _getRandomTip() {
    final tips = [
      "Did you know? Babies love hearing mumma's soothing voice 💖",
      "Tip: Talking to your baby helps brain development 🧠",
      "Remember: Every baby milestone is special 🌟",
      "Fun fact: Babies can recognize mumma's voice from birth 🎵",
      "Gentle reminder: Take care of yourself too, mumma 💝",
      "Pro tip: Singing lullabies calms both you and baby 🎶",
      "Fact: Babies dream even before birth! 💭",
      "Remember: You're doing amazing, mumma! 🌺",
    ];
    return tips[Random().nextInt(tips.length)];
  }

  void _showBabyTip(String tip) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                tip,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.pinkAccent.withOpacity(0.95),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _quickReplyVoice(String text) {
    _sendMessage(text: text);
  }

  Widget _quickReplyButton(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () => _quickReplyVoice(text),
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
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.child_care,
                          color: Color(0xFFFF6B9D), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TinyTalk',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
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
                                'Always here for you',
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
                    Container(
                      decoration: BoxDecoration(
                        color: _isSpeechEnabled
                            ? Colors.white.withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                            _isSpeechEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            color: Colors.white,
                            size: 22
                        ),
                        onPressed: () {
                          setState(() {
                            _isSpeechEnabled = !_isSpeechEnabled;
                          });
                          if (!_isSpeechEnabled) {
                            _flutterTts.stop();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _isSpeechEnabled ? '🔊 Voice enabled' : '🔇 Voice disabled',
                              ),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: const Color(0xFF2C3E50),
                            ),
                          );
                        },
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
                _quickReplyButton("Need tips", Icons.lightbulb_outline),
                _quickReplyButton("Hello", Icons.waving_hand),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
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

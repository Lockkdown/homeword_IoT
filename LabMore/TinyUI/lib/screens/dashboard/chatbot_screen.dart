import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  static const Color _primaryBlue = Color(0xFF4561E9); // Slightly different blue for chat bubbles
  static const Color _textDark = Color(0xFF0D0D0D);
  static const Color _textGrey = Color(0xFF6B6B6B);
  static const Color _bgGrey = Color(0xFFF5F5F7);
  
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': true,
      'text': 'Hi Bobo! 🤖',
      'time': '09:41',
    },
    {
      'isMe': false,
      'text': 'Hello there! 👋 How can I assist you today?',
      'time': '09:41',
      'showBotAvatar': true,
    },
    {
      'isMe': true,
      'text': 'I just set up my Smartify account. What cool things can I do with it?',
      'time': '09:41',
    },
    {
      'isMe': false,
      'text': 'Awesome! 🎉 With Smartify, you can control devices, set up automation, manage energy, and more! What are you interested in exploring first?',
      'time': '09:41',
    },
    {
      'isMe': true,
      'text': 'Hmm, tell me about automation. How can I set it up?',
      'time': '09:41',
    },
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _messages.add({
        'isMe': true,
        'text': _messageController.text.trim(),
        'time': '09:42', // Hardcoded for demo
      });
      _messageController.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat with Bobo',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: _textDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'] as bool;
                final showBotAvatar = message['showBotAvatar'] == true;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBotAvatar) ...[
                      // Chatbot Avatar Graphic
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Icon(Icons.smart_toy_outlined, size: 80, color: _primaryBlue) // Placeholder for bot image
                      ),
                    ],
                    _buildChatBubble(
                        text: message['text'], time: message['time'], isMe: isMe),
                  ],
                );
              },
            ),
          ),
          
          // Chat Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFEEEEF5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _bgGrey,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask me anything ...',
                        hintStyle: GoogleFonts.inter(color: const Color(0xFFA1A1AA)),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: const BoxDecoration(
                      color: _primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble({
    required String text,
    required String time,
    required bool isMe,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMe ? _primaryBlue : _bgGrey,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16), // space for time
                    child: Text(
                      text,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: isMe ? Colors.white : _textDark,
                        height: 1.5,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Text(
                      time,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: isMe
                            ? Colors.white.withValues(alpha: 0.7)
                            : const Color(0xFFA1A1AA),
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

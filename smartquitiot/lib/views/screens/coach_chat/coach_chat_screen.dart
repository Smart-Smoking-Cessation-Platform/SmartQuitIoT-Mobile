import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/coach_chat/chat_message_bubble.dart';


class CoachChatScreen extends StatelessWidget {
  final Map<String, String> coach;

  const CoachChatScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(coach['avatar'] ?? ''),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  coach['specialty'] ?? '',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ChatMessageBubble(
                  text: 'Welcome, I am your virtual assistant.',
                  isFromCoach: true,
                  time: '14:00',
                  coachAvatar: coach['avatar'] ?? '',
                ),
                // Add more ChatMessageBubble widgets here if needed
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E5E5))),
      ),
      child: const AiChatMessageBubble(
        text: 'Demo message',          // tạm cho text
        isUser: true,                 // tạm cho true hoặc false
        time: '12:00',                // tạm cho giờ
      ),
    );
  }
}

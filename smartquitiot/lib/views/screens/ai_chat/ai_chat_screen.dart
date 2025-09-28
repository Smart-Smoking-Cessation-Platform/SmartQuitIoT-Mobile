import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_message_bubble.dart';
import 'ai_chat_message_input.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hút thuốc với hút meth cái nào có hại hơn',
      'isUser': true,
      'time': '14:03',
    },
    {
      'text':
          'AI nhớ những gì bạn đã nói trước đó và sẽ trả lời dựa trên thông tin đó.',
      'isUser': false,
      'time': '14:05',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

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
        title: SizedBox(
          height: 40,
          child: Image.asset('lib/assets/logo/logo-2.png', fit: BoxFit.contain),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return AiChatMessageBubble(
                  text: message['text'],
                  isUser: message['isUser'],
                  time: message['time'],
                );
              },
            ),
          ),
          _buildRegenerateButton(),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildRegenerateButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.refresh, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Regenerate Response',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
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
      child: AiChatMessageInput(
        controller: _messageController,
        onSubmitted: (text) {
          if (text.trim().isNotEmpty) {
            _sendMessage(text);
          }
        },
        onSend: () {
          if (_messageController.text.trim().isNotEmpty) {
            _sendMessage(_messageController.text);
          }
        },
      ),
    );
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add({'text': text, 'isUser': true, 'time': _getCurrentTime()});
      _messageController.clear();
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({
          'text':
              'Thank you for your message. I remember what you said earlier and will respond accordingly.',
          'isUser': false,
          'time': _getCurrentTime(),
        });
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}

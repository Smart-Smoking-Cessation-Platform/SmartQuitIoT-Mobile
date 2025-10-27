// ========================================
// ChatScreenDetail.dart
// ========================================
import 'package:flutter/material.dart';
import 'chat_bubble.dart';
import 'message_input.dart';

// ========================================
// Fake message model
// ========================================
class Message {
  final String text;
  final bool isUser;
  final String time;
  final String? avatar;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
    this.avatar,
  });
}

// ========================================
// Main Screen (Stateful để gửi message demo)
// ========================================
class ChatScreenDetail extends StatefulWidget {
  final String coachName;
  final String coachAvatar;

  const ChatScreenDetail({
    super.key,
    required this.coachName,
    required this.coachAvatar,
  });

  @override
  State<ChatScreenDetail> createState() => _ChatScreenDetailState();
}

class _ChatScreenDetailState extends State<ChatScreenDetail> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Message> messages;

  @override
  void initState() {
    super.initState();
    // Fake initial messages
    messages = [
      Message(
        text: 'Welcome! How can I help you today?',
        isUser: false,
        time: '14:00',
        avatar: widget.coachAvatar,
      ),
      Message(
        text: 'I want some advice about quitting smoking.',
        isUser: true,
        time: '14:01',
      ),
    ];
  }

  void _sendMessage(String text) {
    if (text
        .trim()
        .isEmpty) {
      return;
    }

    final now = TimeOfDay.now();
    setState(() {
      messages.add(
        Message(
          text: text,
          isUser: true,
          time: '${now.hour.toString().padLeft(2, '0')}:${now.minute
              .toString()
              .padLeft(2, '0')}',
        ),
      );
    });

    _controller.clear();

    // scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.coachAvatar),
            ),
            const SizedBox(width: 8),
            Text(
              widget.coachName,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ChatBubble(message: msg);
              },
            ),
          ),
          // ✅ Chỉ cần nhúng MessageInput widget
          MessageInput(
            onSend: (text) {
              final now = TimeOfDay.now();
              setState(() {
                messages.add(Message(
                  text: text,
                  isUser: true,
                  time: '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
                ));
              });

              Future.delayed(const Duration(milliseconds: 100), () {
                if (_scrollController.hasClients) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            },
          ),

        ],
      ),
    );
  }
    
}

 



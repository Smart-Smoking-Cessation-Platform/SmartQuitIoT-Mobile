import 'package:flutter/material.dart';
import 'ai_chat_instructions_screen.dart';
import 'package:SmartQuitIoT/views/widgets/ai/ai_chat_welcome_content.dart';

class AiChatWelcomeScreen extends StatelessWidget {
  const AiChatWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E), // Đồng bộ màu header
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: AiChatWelcomeContent(
            title: 'Chào mừng tới SmartQuit AI',
            subtitle: 'Bắt đầu chat với trợ lí AI của SmartQuit',
            buttonText: 'Bắt Đầu',
            onButtonPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AiChatInstructionsScreen(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

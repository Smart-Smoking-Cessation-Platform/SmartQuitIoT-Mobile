import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class AiChatInstructionsScreen extends StatelessWidget {
  const AiChatInstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // cho keyboard đẩy view lên
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Instructions',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Phần trên scroll được
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Logo ở trên
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: Image.asset('lib/assets/logo.png'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 3 instruction cards
                    _buildInstructionsList(),
                  ],
                ),
              ),
            ),

            // TextField luôn nằm sát bottom
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildMessageInput(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsList() {
    final instructions = [
      'Remembers what user said earlier in the conversation',
      'Allows user to provide follow-up corrections with AI',
      'Limited knowledge of world and events after 2021',
    ];

    return Column(
      children: instructions
          .map((instruction) => _buildInstructionCard(instruction))
          .toList(),
    );
  }

  Widget _buildInstructionCard(String instruction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Send a message...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF5F5F5),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
            ),
            onSubmitted: (text) {
              if (text.trim().isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AiChatScreen()),
                );
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: const BoxDecoration(
            color: Color(0xFF00D09E),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AiChatScreen()),
              );
            },
          ),
        ),
      ],
    );
  }
}

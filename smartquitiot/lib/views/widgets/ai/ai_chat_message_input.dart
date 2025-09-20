import 'package:flutter/material.dart';

class AiChatMessageInput extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final VoidCallback? onSend;
  final Function(String)? onSubmitted;

  const AiChatMessageInput({
    super.key,
    this.controller,
    this.hintText = 'Send a message...',
    this.onSend,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
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
            onSubmitted: onSubmitted,
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
            onPressed: onSend,
          ),
        ),
      ],
    );
  }
}

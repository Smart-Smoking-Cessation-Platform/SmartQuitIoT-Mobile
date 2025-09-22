import 'package:flutter/material.dart';

class AiChatMessageBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final String time;

  const AiChatMessageBubble({
    super.key,
    required this.text,
    required this.isUser,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.black, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (isUser) ...[
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

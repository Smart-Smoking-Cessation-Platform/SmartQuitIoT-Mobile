import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String text;
  final String? characterName;
  final Color? characterNameColor;
  final Color? bubbleColor;
  final Color? textColor;
  final EdgeInsets? padding;
  final double? maxWidth;
  final bool showTail;
  final bool tailPointsLeft;

  const SpeechBubble({
    super.key,
    required this.text,
    this.characterName,
    this.characterNameColor,
    this.bubbleColor,
    this.textColor,
    this.padding,
    this.maxWidth,
    this.showTail = true,
    this.tailPointsLeft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (characterName != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: characterNameColor ?? Colors.green[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              characterName!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth ?? MediaQuery.of(context).size.width * 0.8,
          ),
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bubbleColor ?? Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              if (showTail) ...[
                Positioned(
                  bottom: 0,
                  left: tailPointsLeft ? null : 20,
                  right: tailPointsLeft ? 20 : null,
                  child: CustomPaint(
                    size: const Size(20, 20),
                    painter: SpeechBubbleTailPainter(
                      pointsLeft: tailPointsLeft,
                      color: bubbleColor ?? Colors.white,
                    ),
                  ),
                ),
              ],
              Text(
                text,
                style: TextStyle(
                  color: textColor ?? Colors.black87,
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SpeechBubbleTailPainter extends CustomPainter {
  final bool pointsLeft;
  final Color? color;

  SpeechBubbleTailPainter({required this.pointsLeft, this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color ?? Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    if (pointsLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

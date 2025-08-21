import 'package:flutter/material.dart';

class CloudBackground extends StatelessWidget {
  final Widget child;
  final List<Cloud>? clouds;

  const CloudBackground({super.key, required this.child, this.clouds});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF87CEEB), // Light sky blue
            Color(0xFFB0E0E6), // Powder blue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Default clouds if none provided
          ...(clouds ?? _defaultClouds),
          child,
        ],
      ),
    );
  }

  List<Cloud> get _defaultClouds => [
    Cloud(left: 0.1, top: 0.05, size: 80, opacity: 0.8),
    Cloud(left: 0.7, top: 0.1, size: 100, opacity: 0.6),
    Cloud(left: 0.3, top: 0.15, size: 60, opacity: 0.7),
  ];
}

class Cloud extends StatelessWidget {
  final double left;
  final double top;
  final double size;
  final double opacity;

  const Cloud({
    super.key,
    required this.left,
    required this.top,
    required this.size,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left * MediaQuery.of(context).size.width,
      top: top * MediaQuery.of(context).size.height,
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size(size, size * 0.6),
          painter: CloudPainter(),
        ),
      ),
    );
  }
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Main cloud shape using multiple circles
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Large center circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX, centerY),
        radius: size.width * 0.25,
      ),
    );

    // Left circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX - size.width * 0.2, centerY),
        radius: size.width * 0.2,
      ),
    );

    // Right circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX + size.width * 0.2, centerY),
        radius: size.width * 0.2,
      ),
    );

    // Top circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(centerX, centerY - size.height * 0.15),
        radius: size.width * 0.18,
      ),
    );

    // Bottom left circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          centerX - size.width * 0.15,
          centerY + size.height * 0.1,
        ),
        radius: size.width * 0.15,
      ),
    );

    // Bottom right circle
    path.addOval(
      Rect.fromCircle(
        center: Offset(
          centerX + size.width * 0.15,
          centerY + size.height * 0.1,
        ),
        radius: size.width * 0.15,
      ),
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

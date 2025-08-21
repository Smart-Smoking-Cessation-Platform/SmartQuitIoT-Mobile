import 'package:flutter/material.dart';

class GrassLandscape extends StatelessWidget {
  final Widget child;
  final List<Sparkle>? sparkles;
  final List<Decoration>? decorations;

  const GrassLandscape({
    super.key,
    required this.child,
    this.sparkles,
    this.decorations,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 200),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF90EE90), // Light green
            Color(0xFF32CD32), // Lime green
          ],
        ),
      ),
      child: Stack(
        children: [
          // Default decorations
          ...(decorations ?? _defaultDecorations),

          // Default sparkles
          ...(sparkles ?? _defaultSparkles),

          child,
        ],
      ),
    );
  }

  List<Decoration> get _defaultDecorations => [
    Decoration(left: 0.05, bottom: 0.1, type: DecorationType.tree),
  ];

  List<Sparkle> get _defaultSparkles => [
    Sparkle(left: 0.15, bottom: 0.15, color: Colors.yellow[600]!),
    Sparkle(right: 0.15, bottom: 0.15, color: Colors.lightBlue[300]!),
    Sparkle(left: 0.8, bottom: 0.2, color: Colors.yellow[600]!),
    Sparkle(right: 0.8, bottom: 0.2, color: Colors.lightBlue[300]!),
  ];
}

class Decoration extends StatelessWidget {
  final double? left;
  final double? right;
  final double? bottom;
  final DecorationType type;

  const Decoration({
    super.key,
    this.left,
    this.right,
    this.bottom,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left != null ? left! * MediaQuery.of(context).size.width : null,
      right: right != null ? right! * MediaQuery.of(context).size.width : null,
      bottom: bottom != null
          ? bottom! * MediaQuery.of(context).size.height
          : null,
      child: _buildDecoration(),
    );
  }

  Widget _buildDecoration() {
    switch (type) {
      case DecorationType.tree:
        return _buildTree();
      case DecorationType.flower:
        return _buildFlower();
    }
  }

  Widget _buildTree() {
    return SizedBox(
      width: 40,
      height: 60,
      child: Stack(
        children: [
          // Tree trunk
          Positioned(
            bottom: 0,
            left: 18,
            child: Container(
              width: 4,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.brown[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Tree leaves
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.lightGreen[400],
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlower() {
    return SizedBox(
      width: 20,
      height: 30,
      child: Stack(
        children: [
          // Flower petals
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.pink[300],
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Flower stem
          Positioned(
            bottom: 0,
            left: 9,
            child: Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.green[600],
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Sparkle extends StatelessWidget {
  final double? left;
  final double? right;
  final double? bottom;
  final Color color;

  const Sparkle({
    super.key,
    this.left,
    this.right,
    this.bottom,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left != null ? left! * MediaQuery.of(context).size.width : null,
      right: right != null ? right! * MediaQuery.of(context).size.width : null,
      bottom: bottom != null
          ? bottom! * MediaQuery.of(context).size.height
          : null,
      child: CustomPaint(
        size: const Size(20, 20),
        painter: SparklePainter(color: color),
      ),
    );
  }
}

class SparklePainter extends CustomPainter {
  final Color color;

  SparklePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw a 4-pointed star
    final path = Path();

    // Top point
    path.moveTo(center.dx, center.dy - radius);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.close();

    // Right point
    path.moveTo(center.dx + radius, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy - radius * 0.3);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.close();

    // Bottom point
    path.moveTo(center.dx, center.dy + radius);
    path.lineTo(center.dx + radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.close();

    // Left point
    path.moveTo(center.dx - radius, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy + radius * 0.3);
    path.lineTo(center.dx, center.dy);
    path.lineTo(center.dx - radius * 0.3, center.dy - radius * 0.3);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum DecorationType { tree, flower }

import 'package:flutter/material.dart';

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View More',
                      style: TextStyle(
                        color: Color(0xFF00D09E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset(
                      'lib/assets/notification.png',
                      width: 16,
                      height: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FFF3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cravings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(height: 120, child: _buildCravingsChart(context)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Explore',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCravingsChart(BuildContext context) {
    // Simple line chart simulation
    return CustomPaint(
      painter: CravingsChartPainter(),
      size: Size(MediaQuery.of(context).size.width - 80, 120),
    );
  }
}

class CravingsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D09E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [
      const Offset(0, 100),
      const Offset(20, 80),
      const Offset(40, 60),
      const Offset(60, 70),
      const Offset(80, 50),
      const Offset(100, 40),
      const Offset(120, 30),
      const Offset(140, 35),
      const Offset(160, 25),
      const Offset(180, 20),
      const Offset(200, 15),
      const Offset(220, 10),
      const Offset(240, 5),
      const Offset(260, 8),
      const Offset(280, 12),
    ];

    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    canvas.drawPath(path, paint);

    // Draw data points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D09E)
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }

    // Draw axes
    final axisPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    // Y-axis
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint);

    // X-axis
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    // Draw labels
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Y-axis labels
    final yLabels = ['0', '10', '20', '30'];
    for (int i = 0; i < yLabels.length; i++) {
      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-25, size.height - (i * 30) - 5));
    }

    // X-axis labels
    final xLabels = ['1', '5', '10', '15'];
    for (int i = 0; i < xLabels.length; i++) {
      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(color: Colors.grey, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(i * 70 - 5, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

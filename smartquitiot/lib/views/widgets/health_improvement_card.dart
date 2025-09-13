import 'package:flutter/material.dart';

class HealthImprovementCard extends StatelessWidget {
  const HealthImprovementCard({super.key});

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
                'Health Improvement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildProgressCircle(
                title: 'Pulse rate',
                progress: 0.5,
                icon: Icons.favorite,
              ),
              _buildProgressCircle(
                title: 'Oxygen levels',
                progress: 0.5,
                icon: Icons.air,
              ),
              _buildProgressCircle(
                title: 'Carbon monoxide Levels',
                progress: 0.5,
                icon: Icons.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle({
    required String title,
    required double progress,
    required IconData icon,
  }) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: const Color(0xFFF1FFF3),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF00D09E),
                ),
              ),
            ),
            Positioned(
              top: 8,
              child: Icon(icon, color: const Color(0xFF00D09E), size: 16),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00D09E),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

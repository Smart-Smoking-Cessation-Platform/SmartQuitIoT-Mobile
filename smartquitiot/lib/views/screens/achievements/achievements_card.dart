import 'package:SmartQuitIoT/views/screens/achievements/achievements.dart';
import 'package:SmartQuitIoT/views/screens/badges/badges_screen.dart';
import 'package:flutter/material.dart';

class AchievementsCard extends StatelessWidget {
  const AchievementsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937), // chữ tối
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BadgesScreen()),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      color: Color(0xFF00D09E), // xanh lá đồng bộ
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildAchievementBadge(
                  title: '7 Day Streak',
                  subtitle: 'You smoke for 7 days',
                  icon: Icons.local_fire_department,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAchievementBadge(
                  title: 'Royal Streak',
                  subtitle: '50th level achieved',
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildAchievementBadge(
                  title: 'On Target',
                  subtitle: '20 day streak',
                  icon: Icons.flag,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAchievementBadge(
                  title: 'Consistency',
                  subtitle: 'Keep it up!',
                  icon: Icons.star,
                  color: Colors.purpleAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

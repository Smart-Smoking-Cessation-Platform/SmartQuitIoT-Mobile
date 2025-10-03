import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/badges/badges_screen.dart';
import 'package:easy_localization/easy_localization.dart';

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'achievements'.tr(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
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
                  padding: const EdgeInsets.only(right: 12),
                  child: Text(
                    'view_more'.tr(),
                    style: const TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Badges Row 1
          Row(
            children: [
              Expanded(
                child: _buildAchievementBadge(
                  title: 'streak_7'.tr(),
                  subtitle: 'streak_7_sub'.tr(),
                  icon: Icons.local_fire_department,
                  color: Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAchievementBadge(
                  title: 'royal_streak'.tr(),
                  subtitle: 'royal_streak_sub'.tr(),
                  icon: Icons.emoji_events,
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Badges Row 2
          Row(
            children: [
              Expanded(
                child: _buildAchievementBadge(
                  title: 'on_target'.tr(),
                  subtitle: 'on_target_sub'.tr(),
                  icon: Icons.flag,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _buildAchievementBadge(
                  title: 'consistency'.tr(),
                  subtitle: 'consistency_sub'.tr(),
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

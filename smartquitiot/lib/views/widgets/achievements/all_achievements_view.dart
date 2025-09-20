import 'package:flutter/material.dart';
import '../progress_card.dart';
import 'achievement_section.dart';

class AllAchievementsView extends StatelessWidget {
  final List<Map<String, dynamic>> milestoneAchievements;
  final List<Map<String, dynamic>> healthAchievements;
  final List<Map<String, dynamic>> socialAchievements;
  final List<Map<String, dynamic>> specialAchievements;

  const AllAchievementsView({
    super.key,
    required this.milestoneAchievements,
    required this.healthAchievements,
    required this.socialAchievements,
    required this.specialAchievements,
  });

  List<Map<String, dynamic>> _getAllAchievements() {
    return [
      ...milestoneAchievements,
      ...healthAchievements,
      ...socialAchievements,
      ...specialAchievements,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final totalAchievements = _getAllAchievements().length;
    final completedCount = _getAllAchievements()
        .where((a) => a['isCompleted'])
        .length;
    final progress = completedCount / totalAchievements;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProgressCard(
            title: 'Achievement Progress',
            subtitle:
                '$completedCount of $totalAchievements achievements completed',
            progress: progress,
            progressText: '${(progress * 100).toInt()}%',
            icon: Icons.emoji_events,
          ),
          const SizedBox(height: 24),
          AchievementSection(
            title: 'Milestone Achievements',
            achievements: milestoneAchievements,
            sectionColor: const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          AchievementSection(
            title: 'Health Achievements',
            achievements: healthAchievements,
            sectionColor: const Color(0xFFE91E63),
          ),
          const SizedBox(height: 24),
          AchievementSection(
            title: 'Social Achievements',
            achievements: socialAchievements,
            sectionColor: const Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          AchievementSection(
            title: 'Special Achievements',
            achievements: specialAchievements,
            sectionColor: const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }
}

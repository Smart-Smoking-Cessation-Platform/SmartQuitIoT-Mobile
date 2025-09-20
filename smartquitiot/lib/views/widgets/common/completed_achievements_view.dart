import 'package:flutter/material.dart';
import 'completed_achievement_card.dart';

class CompletedAchievementsView extends StatelessWidget {
  final List<Map<String, dynamic>> milestoneAchievements;
  final List<Map<String, dynamic>> healthAchievements;
  final List<Map<String, dynamic>> socialAchievements;
  final List<Map<String, dynamic>> specialAchievements;

  const CompletedAchievementsView({
    super.key,
    required this.milestoneAchievements,
    required this.healthAchievements,
    required this.socialAchievements,
    required this.specialAchievements,
  });

  @override
  Widget build(BuildContext context) {
    final completedAchievements = [
      ...milestoneAchievements.where((a) => a['isCompleted']),
      ...healthAchievements.where((a) => a['isCompleted']),
      ...socialAchievements.where((a) => a['isCompleted']),
      ...specialAchievements.where((a) => a['isCompleted']),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedAchievements.length,
      itemBuilder: (context, index) {
        final achievement = completedAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: CompletedAchievementCard(achievement: achievement),
        );
      },
    );
  }
}

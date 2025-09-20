import 'package:flutter/material.dart';
import '../widgets/home_header.dart';
import '../widgets/smoke_free_timer_card.dart';
import '../widgets/stats_table_card.dart';
import '../widgets/health_improvement_card.dart';
import '../widgets/achievements_card.dart';
import '../widgets/quit_plan_card.dart';
import '../widgets/today_mission_card.dart';
import '../widgets/analysis_card.dart';
import '../widgets/community_trending_card.dart';
import '../widgets/recent_news_card.dart';
import 'ai_chat_welcome_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80), // tránh che FAB
          child: Column(
            children: const [
              HomeHeader(),
              SmokeFreeTimerCard(),
              StatsTableCard(),
              HealthImprovementCard(),
              AchievementsCard(),
              QuitPlanCard(),
              TodayMissionCard(),
              AnalysisCard(),
              CommunityTrendingCard(),
              RecentNewsCard(),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AiChatWelcomeScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF00D09E), // màu xanh chủ đạo
        elevation: 8,
        child: const Icon(
          Icons.smart_toy, // AI icon
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

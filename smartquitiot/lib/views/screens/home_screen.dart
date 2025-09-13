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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HomeHeader(),
              const SmokeFreeTimerCard(),
              const StatsTableCard(),
              const HealthImprovementCard(),
              const AchievementsCard(),
              const QuitPlanCard(),
              const TodayMissionCard(),
              const AnalysisCard(),
              const CommunityTrendingCard(),
              const RecentNewsCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00D09E),
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

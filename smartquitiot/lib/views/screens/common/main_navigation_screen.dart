import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:SmartQuitIoT/views/screens/ai_chat/ai_chat_welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievements_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/coach_appointment_card.dart';
import 'package:SmartQuitIoT/views/screens/common/membership_shortcut_card.dart';
import 'package:SmartQuitIoT/views/widgets/headers/home_header.dart';
import 'package:SmartQuitIoT/views/widgets/cards/smoke_free_timer_card.dart';
import 'package:SmartQuitIoT/views/screens/stats_table/stats_table_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/health_improvement_card.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_card.dart';
import 'package:SmartQuitIoT/views/screens/missions/today_mission_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/analysis_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/community_trending_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/recent_news_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/diary_record_card.dart';

import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_screen.dart';
import 'package:SmartQuitIoT/views/screens/leaderboard/leaderboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  /// Danh sách các màn hình con
  late final List<Widget> _screens = [
    _buildHomeContent(), // 👈 trang home chính
    const ChatScreen(),
    const DiaryScreen(),
    const QuitPlanScreen(),
    const AchievementScreen(),
    const LeaderboardScreen(),
  ];

  final List<String> lottiePaths = [
    'lib/assets/animations/home.json',
    'lib/assets/animations/chat.json',
    'lib/assets/animations/diary.json',
    'lib/assets/animations/craving.json',
    'lib/assets/animations/trophy.json',
    'lib/assets/animations/leaderboard.json',
  ];

  final List<String> lottieLabels = [
    'home',
    'chat',
    'diary',
    'craving',
    'achievements',
    'leaderboard',
  ];

  /// Hàm build riêng cho trang Home
  Widget _buildHomeContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            children: const [
              HomeHeader(),
              SmokeFreeTimerCard(),
              MembershipShortcutCard(),
              DiaryRecordCard(),
              CoachAppointmentCard(),
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
            MaterialPageRoute(builder: (_) => const AiChatWelcomeScreen()),
          );
        },
        backgroundColor: const Color(0xFF00D09E),
        elevation: 8,
        child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF00D09E),
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: List.generate(lottiePaths.length, (index) {
          return BottomNavigationBarItem(
            icon: SizedBox(
              height: 30,
              width: 30,
              child: Lottie.asset(
                lottiePaths[index],
                animate: _currentIndex == index,
              ),
            ),
            label: lottieLabels[index].tr(),
          );
        }),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart';

import 'home_screen.dart';
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

  final List<Widget> _screens = [
    const HomeScreen(),
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

  /// Key song ngữ cho từng tab
  final List<String> lottieLabels = [
    'home',
    'chat',
    'diary',
    'craving',
    'achievements',
    'leaderboard',
  ];

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
            label: lottieLabels[index].tr(), // <-- dùng easy_localization
          );
        }),
      ),
    );
  }
}

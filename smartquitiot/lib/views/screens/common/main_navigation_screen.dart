import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

// import các màn hình của bạn

import 'package:SmartQuitIoT/views/screens/coach_chat/chat_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_screen.dart';
import 'package:SmartQuitIoT/views/screens/achievements/achievement_screen.dart';
import 'package:SmartQuitIoT/views/screens/leaderboard/leaderboard_screen.dart';

import 'home_screen.dart';

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
    const LeaderboardScreen()
  ];

  /// Danh sách đường dẫn Lottie cho từng tab
  final List<String> lottiePaths = [
    'lib/assets/animations/home.json',        // Home
    'lib/assets/animations/chat.json',        // Chat
    'lib/assets/animations/diary.json',       // Diary
    'lib/assets/animations/craving.json',     // Craving
    'lib/assets/animations/trophy.json',
    'lib/assets/animations/leaderboard.json' // Achievements
// Achievements
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
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          _buildLottieNavItem(0, 'Home'),
          _buildLottieNavItem(1, 'Chat'),
          _buildLottieNavItem(2, 'Diary'),
          _buildLottieNavItem(3, 'Craving'),
          _buildLottieNavItem(4, 'Achievements'),
          _buildLottieNavItem(5, 'Leaderboard'),
        ],
      ),
    );
  }

  /// Hàm tạo BottomNavigationBarItem với Lottie
  BottomNavigationBarItem _buildLottieNavItem(int index, String label) {
    return BottomNavigationBarItem(
      icon: SizedBox(
        height: 30,
        width: 30,
        child: Lottie.asset(
          lottiePaths[index],
          animate: _currentIndex == index,
        ),
      ),
      label: label,
    );
  }
}

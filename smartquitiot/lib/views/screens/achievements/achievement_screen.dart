import 'package:SmartQuitIoT/views/screens/achievements/all_achievements_view.dart';
import 'package:SmartQuitIoT/views/screens/achievements/completed_achievements_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartQuitIoT/views/widgets/common/in_progress_achievements_view.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent default pop
      onPopInvoked: (didPop) {
        if (!didPop) {
          // Navigate to MainNavigationScreen instead of popping
          context.go('/main');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FFFE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF00D09E),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'Achievements',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Completed'),
              Tab(text: 'In Progress'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildAllAchievements(),
            _buildCompletedAchievements(),
            _buildInProgressAchievements(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllAchievements() {
    return const AllAchievementsView();
  }

  Widget _buildCompletedAchievements() {
    return const CompletedAchievementsView();
  }

  Widget _buildInProgressAchievements() {
    return const InProgressAchievementsView();
  }
}

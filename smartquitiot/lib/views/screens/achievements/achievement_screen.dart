import 'package:SmartQuitIoT/views/screens/achievements/all_achievements_view.dart';
import 'package:SmartQuitIoT/views/screens/achievements/completed_achievements_view.dart';
import 'package:flutter/material.dart';
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
          // Navigate to HomeScreen instead of popping
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home', // hoặc route name của HomeScreen
            (route) => false,
          );
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
    return AllAchievementsView(
      milestoneAchievements: _milestoneAchievements,
      healthAchievements: _healthAchievements,
      socialAchievements: _socialAchievements,
      specialAchievements: _specialAchievements,
    );
  }

  Widget _buildCompletedAchievements() {
    return CompletedAchievementsView(
      milestoneAchievements: _milestoneAchievements,
      healthAchievements: _healthAchievements,
      socialAchievements: _socialAchievements,
      specialAchievements: _specialAchievements,
    );
  }

  Widget _buildInProgressAchievements() {
    return InProgressAchievementsView(
      milestoneAchievements: _milestoneAchievements,
      healthAchievements: _healthAchievements,
      socialAchievements: _socialAchievements,
      specialAchievements: _specialAchievements,
    );
  }

  final List<Map<String, dynamic>> _milestoneAchievements = [
    {
      'title': 'First Day Smoke-Free',
      'description': 'Complete your first 24 hours without smoking',
      'icon': Icons.timer_outlined,
      'isCompleted': true,
      'completedDate': 'Dec 15, 2024',
    },
    {
      'title': 'One Week Strong',
      'description': 'Stay smoke-free for 7 consecutive days',
      'icon': Icons.calendar_today_outlined,
      'isCompleted': true,
      'completedDate': 'Dec 22, 2024',
    },
    {
      'title': 'One Month Champion',
      'description': 'Reach 30 days smoke-free',
      'icon': Icons.emoji_events_outlined,
      'isCompleted': false,
      'progress': 0.8,
    },
    {
      'title': 'Three Month Warrior',
      'description': 'Complete 90 days smoke-free',
      'icon': Icons.military_tech_outlined,
      'isCompleted': false,
      'progress': 0.2,
    },
    {
      'title': 'Six Month Hero',
      'description': 'Reach 180 days smoke-free',
      'icon': Icons.workspace_premium_outlined,
      'isCompleted': false,
      'progress': 0.0,
    },
    {
      'title': 'One Year Legend',
      'description': 'Complete a full year smoke-free',
      'icon': Icons.celebration_outlined,
      'isCompleted': false,
      'progress': 0.0,
    },
  ];

  final List<Map<String, dynamic>> _healthAchievements = [
    {
      'title': 'Lung Capacity Boost',
      'description': 'Complete 10 breathing exercises',
      'icon': Icons.air,
      'isCompleted': true,
      'completedDate': 'Dec 20, 2024',
    },
    {
      'title': 'Heart Health Hero',
      'description': 'Track your heart rate for 7 days',
      'icon': Icons.favorite_outline,
      'isCompleted': false,
      'progress': 0.6,
    },
    {
      'title': 'Energy Surge',
      'description': 'Complete 30 days of daily exercise',
      'icon': Icons.fitness_center_outlined,
      'isCompleted': false,
      'progress': 0.3,
    },
    {
      'title': 'Sleep Master',
      'description': 'Maintain consistent sleep schedule for 2 weeks',
      'icon': Icons.bedtime_outlined,
      'isCompleted': false,
      'progress': 0.1,
    },
  ];

  final List<Map<String, dynamic>> _socialAchievements = [
    {
      'title': 'Community Helper',
      'description': 'Help 5 other users in the community',
      'icon': Icons.people_outline,
      'isCompleted': true,
      'completedDate': 'Dec 18, 2024',
    },
    {
      'title': 'Motivational Speaker',
      'description': 'Share your story with the community',
      'icon': Icons.mic_none_outlined,
      'isCompleted': false,
      'progress': 0.0,
    },
    {
      'title': 'Support Group Leader',
      'description': 'Lead a support group session',
      'icon': Icons.group_work_outlined,
      'isCompleted': false,
      'progress': 0.0,
    },
  ];

  final List<Map<String, dynamic>> _specialAchievements = [
    {
      'title': 'Money Saver',
      'description': 'Save \$100 by not smoking',
      'icon': Icons.attach_money_outlined,
      'isCompleted': true,
      'completedDate': 'Dec 25, 2024',
    },
    {
      'title': 'Time Master',
      'description': 'Save 50 hours by not smoking',
      'icon': Icons.access_time_outlined,
      'isCompleted': false,
      'progress': 0.4,
    },
    {
      'title': 'Environmental Hero',
      'description': 'Prevent 1000 cigarette butts from polluting',
      'icon': Icons.eco_outlined,
      'isCompleted': false,
      'progress': 0.7,
    },
    {
      'title': 'Stress Buster',
      'description': 'Use alternative stress relief methods 20 times',
      'icon': Icons.spa_outlined,
      'isCompleted': false,
      'progress': 0.2,
    },
  ];
}

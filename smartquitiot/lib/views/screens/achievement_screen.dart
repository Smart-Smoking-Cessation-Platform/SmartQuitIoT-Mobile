import 'package:flutter/material.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF00D09E),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF00D09E),
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
    );
  }

  Widget _buildAllAchievements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 20),
          _buildAchievementSection(
            'Milestone Achievements',
            _milestoneAchievements,
          ),
          const SizedBox(height: 20),
          _buildAchievementSection('Health Achievements', _healthAchievements),
          const SizedBox(height: 20),
          _buildAchievementSection('Social Achievements', _socialAchievements),
          const SizedBox(height: 20),
          _buildAchievementSection(
            'Special Achievements',
            _specialAchievements,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedAchievements() {
    final completedAchievements = [
      ..._milestoneAchievements.where((a) => a['isCompleted']),
      ..._healthAchievements.where((a) => a['isCompleted']),
      ..._socialAchievements.where((a) => a['isCompleted']),
      ..._specialAchievements.where((a) => a['isCompleted']),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(completedAchievements[index]);
      },
    );
  }

  Widget _buildInProgressAchievements() {
    final inProgressAchievements = [
      ..._milestoneAchievements.where((a) => !a['isCompleted']),
      ..._healthAchievements.where((a) => !a['isCompleted']),
      ..._socialAchievements.where((a) => !a['isCompleted']),
      ..._specialAchievements.where((a) => !a['isCompleted']),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inProgressAchievements.length,
      itemBuilder: (context, index) {
        return _buildAchievementCard(inProgressAchievements[index]);
      },
    );
  }

  Widget _buildStatsCard() {
    final totalAchievements = _getAllAchievements().length;
    final completedCount = _getAllAchievements()
        .where((a) => a['isCompleted'])
        .length;
    final progress = completedCount / totalAchievements;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00A085)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievement Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$completedCount of $totalAchievements achievements completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(
    String title,
    List<Map<String, dynamic>> achievements,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        ...achievements.map(
          (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAchievementCard(achievement),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: achievement['isCompleted']
            ? Border.all(color: const Color(0xFF00D09E), width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: achievement['isCompleted']
                  ? const Color(0xFF00D09E)
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['isCompleted']
                  ? Colors.white
                  : Colors.grey[600],
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement['isCompleted']
                        ? const Color(0xFF00D09E)
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement['description'],
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                if (!achievement['isCompleted'] &&
                    achievement['progress'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: achievement['progress'],
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00D09E),
                          ),
                          minHeight: 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(achievement['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievement['isCompleted']) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00D09E),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Completed on ${achievement['completedDate']}',
                        style: const TextStyle(
                          color: Color(0xFF00D09E),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (achievement['isCompleted'])
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF00D09E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 20),
            ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllAchievements() {
    return [
      ..._milestoneAchievements,
      ..._healthAchievements,
      ..._socialAchievements,
      ..._specialAchievements,
    ];
  }

  final List<Map<String, dynamic>> _milestoneAchievements = [
    {
      'title': 'First Day Smoke-Free',
      'description': 'Complete your first 24 hours without smoking',
      'icon': Icons.timer,
      'isCompleted': true,
      'completedDate': 'Dec 15, 2024',
    },
    {
      'title': 'One Week Strong',
      'description': 'Stay smoke-free for 7 consecutive days',
      'icon': Icons.calendar_today,
      'isCompleted': true,
      'completedDate': 'Dec 22, 2024',
    },
    {
      'title': 'One Month Champion',
      'description': 'Reach 30 days smoke-free',
      'icon': Icons.emoji_events,
      'isCompleted': false,
      'progress': 0.8,
    },
    {
      'title': 'Three Month Warrior',
      'description': 'Complete 90 days smoke-free',
      'icon': Icons.military_tech,
      'isCompleted': false,
      'progress': 0.0,
    },
    {
      'title': 'Six Month Hero',
      'description': 'Reach 180 days smoke-free',
      'icon': Icons.workspace_premium,
      'isCompleted': false,
      'progress': 0.0,
    },
    {
      'title': 'One Year Legend',
      'description': 'Complete a full year smoke-free',
      'icon': Icons.celebration,
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
      'icon': Icons.favorite,
      'isCompleted': false,
      'progress': 0.6,
    },
    {
      'title': 'Energy Surge',
      'description': 'Complete 30 days of daily exercise',
      'icon': Icons.fitness_center,
      'isCompleted': false,
      'progress': 0.3,
    },
    {
      'title': 'Sleep Master',
      'description': 'Maintain consistent sleep schedule for 2 weeks',
      'icon': Icons.bedtime,
      'isCompleted': false,
      'progress': 0.0,
    },
  ];

  final List<Map<String, dynamic>> _socialAchievements = [
    {
      'title': 'Community Helper',
      'description': 'Help 5 other users in the community',
      'icon': Icons.people,
      'isCompleted': true,
      'completedDate': 'Dec 18, 2024',
    },
    {
      'title': 'Motivational Speaker',
      'description': 'Share your story with the community',
      'icon': Icons.mic,
      'isCompleted': false,
      'progress': 0.0,
    },
    {
      'title': 'Support Group Leader',
      'description': 'Lead a support group session',
      'icon': Icons.group_work,
      'isCompleted': false,
      'progress': 0.0,
    },
  ];

  final List<Map<String, dynamic>> _specialAchievements = [
    {
      'title': 'Money Saver',
      'description': 'Save \$100 by not smoking',
      'icon': Icons.attach_money,
      'isCompleted': true,
      'completedDate': 'Dec 25, 2024',
    },
    {
      'title': 'Time Master',
      'description': 'Save 50 hours by not smoking',
      'icon': Icons.access_time,
      'isCompleted': false,
      'progress': 0.4,
    },
    {
      'title': 'Environmental Hero',
      'description': 'Prevent 1000 cigarette butts from polluting',
      'icon': Icons.eco,
      'isCompleted': false,
      'progress': 0.7,
    },
    {
      'title': 'Stress Buster',
      'description': 'Use alternative stress relief methods 20 times',
      'icon': Icons.spa,
      'isCompleted': false,
      'progress': 0.2,
    },
  ];
}

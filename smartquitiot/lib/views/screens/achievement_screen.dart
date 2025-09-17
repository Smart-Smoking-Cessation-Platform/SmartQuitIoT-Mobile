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
    )
    );
  }

  Widget _buildAllAchievements() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(),
          const SizedBox(height: 24),
          _buildAchievementSection(
            'Milestone Achievements',
            _milestoneAchievements,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          _buildAchievementSection(
            'Health Achievements',
            _healthAchievements,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 24),
          _buildAchievementSection(
            'Social Achievements',
            _socialAchievements,
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          _buildAchievementSection(
            'Special Achievements',
            _specialAchievements,
            const Color(0xFFFF9800),
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
        final achievement = completedAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildCompletedAchievementCard(achievement),
        );
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
        final achievement = inProgressAchievements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildInProgressAchievementCard(achievement),
        );
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B88A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            '$completedCount of $totalAchievements achievements completed',
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementSection(
      String title,
      List<Map<String, dynamic>> achievements,
      Color sectionColor,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(
                color: sectionColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...achievements.map(
              (achievement) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildAchievementCard(achievement, sectionColor),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement, Color categoryColor) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: achievement['isCompleted']
            ? Border.all(color: const Color(0xFF00D09E), width: 2)
            : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: achievement['isCompleted']
                  ? const Color(0xFF00D09E)
                  : categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              boxShadow: achievement['isCompleted'] ? [
                BoxShadow(
                  color: const Color(0xFF00D09E).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Icon(
              achievement['icon'],
              color: achievement['isCompleted']
                  ? Colors.white
                  : categoryColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
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
                        : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                if (!achievement['isCompleted'] &&
                    achievement['progress'] != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: achievement['progress'],
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(achievement['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          color: categoryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                if (achievement['isCompleted']) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF00D09E),
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Completed on ${achievement['completedDate']}',
                        style: const TextStyle(
                          color: Color(0xFF00D09E),
                          fontSize: 13,
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00D09E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 22),
            ),
        ],
      ),
    );
  }

  Widget _buildCompletedAchievementCard(Map<String, dynamic> achievement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D09E).withOpacity(0.05),
            const Color(0xFF00D09E).withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00D09E), Color(0xFF00B88A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00D09E).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              achievement['icon'],
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement['title'],
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  achievement['description'],
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Color(0xFF00D09E),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Completed on ${achievement['completedDate']}',
                      style: const TextStyle(
                        color: Color(0xFF00D09E),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressAchievementCard(Map<String, dynamic> achievement) {
    final progressColor = _getProgressColor(achievement['progress'] ?? 0.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: progressColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: progressColor.withOpacity(0.3), width: 2),
                ),
                child: Icon(
                  achievement['icon'],
                  color: progressColor,
                  size: 34,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement['title'],
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: progressColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: progressColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'IN PROGRESS',
                            style: TextStyle(
                              color: progressColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement['description'],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (achievement['progress'] != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: progressColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: progressColor.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${(achievement['progress'] * 100).toInt()}%',
                        style: TextStyle(
                          color: progressColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: achievement['progress'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) return const Color(0xFF4CAF50); // Green
    if (progress >= 0.4) return const Color(0xFFFF9800); // Orange
    return const Color(0xFFE91E63); // Pink/Red
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
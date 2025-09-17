import 'package:flutter/material.dart';

class SuggestedMissionsScreen extends StatefulWidget {
  const SuggestedMissionsScreen({super.key});

  @override
  State<SuggestedMissionsScreen> createState() => _SuggestedMissionsScreenState();
}

class _SuggestedMissionsScreenState extends State<SuggestedMissionsScreen> {
  final List<Map<String, dynamic>> missions = [
    {
      'id': 1,
      'title': 'Drink water',
      'description': 'Drink 4L of water per day',
      'icon': Icons.local_drink,
      'color': Color(0xFF2196F3),
      'isCompleted': true,
      'progress': 1.0,
      'points': 10,
      'difficulty': 'Easy',
    },
    {
      'id': 2,
      'title': 'Take a deep breath',
      'description': 'Take a deep breath to refresh',
      'icon': Icons.air,
      'color': Color(0xFF4CAF50),
      'isCompleted': true,
      'progress': 1.0,
      'points': 15,
      'difficulty': 'Easy',
    },
    {
      'id': 3,
      'title': 'Do exercise',
      'description': 'Do an exercise to refresh',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFF9800),
      'isCompleted': true,
      'progress': 1.0,
      'points': 25,
      'difficulty': 'Medium',
    },
    {
      'id': 4,
      'title': 'Meditation session',
      'description': 'Complete a 10-minute mindfulness meditation',
      'icon': Icons.self_improvement,
      'color': Color(0xFF9C27B0),
      'isCompleted': false,
      'progress': 0.0,
      'points': 20,
      'difficulty': 'Medium',
    },
    {
      'id': 5,
      'title': 'Healthy snack',
      'description': 'Choose a healthy snack instead of smoking',
      'icon': Icons.apple,
      'color': Color(0xFF4CAF50),
      'isCompleted': false,
      'progress': 0.0,
      'points': 15,
      'difficulty': 'Easy',
    },
    {
      'id': 6,
      'title': 'Call a friend',
      'description': 'Connect with a supportive friend or family member',
      'icon': Icons.phone,
      'color': Color(0xFFE91E63),
      'isCompleted': false,
      'progress': 0.3,
      'points': 30,
      'difficulty': 'Hard',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final completedMissions = missions.where((m) => m['isCompleted']).length;
    final totalPoints = missions.where((m) => m['isCompleted']).fold<int>(0, (sum, m) => sum + (m['points'] as int));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Missions',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildProgressCard(completedMissions, totalPoints),
            const SizedBox(height: 24),
            _buildMissionsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Color(0xFF00D09E),
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Daily Missions',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete missions to stay motivated and build healthy habits',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9), 
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(int completed, int points) {
    final totalMissions = missions.length;
    final progressPercentage = (completed / totalMissions * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$completed of $totalMissions missions completed',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4CAF50),
                      const Color(0xFF4CAF50).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.stars,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$points pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completed / totalMissions,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progressPercentage%',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMissionsSection() {
    final completedMissions = missions.where((m) => m['isCompleted']).toList();
    final incompleteMissions = missions.where((m) => !m['isCompleted']).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (incompleteMissions.isNotEmpty) ...[
          const Text(
            'Available Missions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          ...incompleteMissions.map((mission) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMissionCard(mission, false),
          )),
        ],
        if (completedMissions.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Completed Missions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          ...completedMissions.map((mission) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildMissionCard(mission, true),
          )),
        ],
      ],
    );
  }

  Widget _buildMissionCard(Map<String, dynamic> mission, bool isCompleted) {
    final color = mission['color'] as Color;

    return GestureDetector(
      onTap: isCompleted ? null : () => _completeMission(mission),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isCompleted
              ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3))
              : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted ? const Color(0xFF4CAF50) : color,
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          mission['icon'],
                          color: isCompleted ? const Color(0xFF4CAF50) : color,
                          size: 28,
                        ),
                      ),
                      if (isCompleted)
                        Positioned(
                          right: -2,
                          top: -2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4CAF50),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mission['title'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF2D3748),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(mission['difficulty']).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mission['difficulty'],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getDifficultyColor(mission['difficulty']),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mission['description'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[400],
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mission['points']} points',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isCompleted ? const Color(0xFF4CAF50) : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (!isCompleted && mission['progress'] > 0) ...[
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        '${(mission['progress'] * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: mission['progress'],
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ],
            if (isCompleted) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.celebration,
                      color: Color(0xFF4CAF50),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Completed',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFF9800);
      case 'Hard':
        return const Color(0xFFE91E63);
      default:
        return Colors.grey;
    }
  }

  void _completeMission(Map<String, dynamic> mission) {
    setState(() {
      mission['isCompleted'] = true;
      mission['progress'] = 1.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mission "${mission['title']}" completed! +${mission['points']} points'),
        backgroundColor: const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class Mission {
  final String title;
  final String description;
  final IconData icon;

  const Mission({
    required this.title,
    required this.description,
    this.icon = Icons.self_improvement,
  });
}

class TodayMissionCard extends StatelessWidget {
  final List<Mission> missions;

  const TodayMissionCard({
    super.key,
    this.missions = const [
      Mission(
        title: "Meditation",
        description:
            "Meditation is an act of control, willing to anything, preparing to do.",
      ),
      Mission(
        title: "Drink Water",
        description: "Drink at least 8 glasses of water today.",
        icon: Icons.local_drink,
      ),
      Mission(
        title: "Short Walk",
        description: "Take a 15-minute walk to refresh your mind.",
        icon: Icons.directions_walk,
      ),
      Mission(
        title: "Read Article",
        description: "Read one article related to health or mindfulness.",
        icon: Icons.article,
      ),
      Mission(
        title: "Stretching",
        description: "Do 5 minutes of stretching to relax your body.",
        icon: Icons.accessibility_new,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header: title + View More
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Today\'s Mission',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Thêm hành động khi nhấn View More
                },
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          /// Danh sách nhiệm vụ
          Column(
            children: missions.map((mission) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(mission.icon, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mission.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold, // bold cho dễ nhìn
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class Mission {
  final String titleKey;
  final String descriptionKey;
  final IconData icon;

  const Mission({
    required this.titleKey,
    required this.descriptionKey,
    this.icon = Icons.self_improvement,
  });
}

class TodayMissionCard extends StatelessWidget {
  final List<Mission> missions;

  const TodayMissionCard({
    super.key,
    this.missions = const [
      Mission(
        titleKey: "mission_meditation_title",
        descriptionKey: "mission_meditation_desc",
      ),
      Mission(
        titleKey: "mission_drink_water_title",
        descriptionKey: "mission_drink_water_desc",
        icon: Icons.local_drink,
      ),
      Mission(
        titleKey: "mission_short_walk_title",
        descriptionKey: "mission_short_walk_desc",
        icon: Icons.directions_walk,
      ),
      Mission(
        titleKey: "mission_read_article_title",
        descriptionKey: "mission_read_article_desc",
        icon: Icons.article,
      ),
      Mission(
        titleKey: "mission_stretching_title",
        descriptionKey: "mission_stretching_desc",
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
              Text(
                'today_mission'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // TODO: Thêm hành động khi nhấn View More
                },
                child: Text(
                  'view_more'.tr(),
                  style: const TextStyle(
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
                            mission.titleKey.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            mission.descriptionKey.tr(),
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

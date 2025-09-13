import 'package:flutter/material.dart';
import 'info_card.dart';
import 'profile_health_card.dart';

class StatsTableCard extends StatelessWidget {
  const StatsTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View More',
                  style: TextStyle(
                    color: Color(0xFF00D09E),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2x2 Grid using Column + Row + Expanded
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      icon: 'lib/assets/calendar.png',
                      title: 'QUIT DAY',
                      value: '1 Day',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: InfoCard(
                      icon: 'lib/assets/salary.png',
                      title: 'MONEY SAVED',
                      value: '45,000 VND',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InfoCard(
                      icon: 'lib/assets/salary.png',
                      title: 'ANNUAL SAVED',
                      value: '500,000 VND',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(child: ProfileHealthCard()),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

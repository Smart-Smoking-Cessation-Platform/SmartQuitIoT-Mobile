import 'package:flutter/material.dart';

import 'community_progress_section.dart';
import 'leaderboard_card.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ AppBar chỉnh sửa
      appBar: AppBar(
        automaticallyImplyLeading: false, // bỏ mũi tên back
        title: const Text(
          'Quit Smoking Leaderboard',
          style: TextStyle(
            fontSize: 16, // chữ nhỏ hơn
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF00D09E), // đổi màu xanh đồng bộ UI
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const CommunityProgressSection(),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildLeaderboardList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    final participants = [
      LeaderboardUser(
        rank: 1,
        name: 'John Doe',
        streak: 45,
        healthScore: 85,
        savings: 1500000,
        points: 3200,
        isUp: true,
      ),
      LeaderboardUser(
        rank: 2,
        name: 'Jane Smith',
        streak: 30,
        healthScore: 78,
        savings: 900000,
        points: 2500,
        isUp: false,
      ),
      LeaderboardUser(
        rank: 3,
        name: 'Nguyen Van A',
        streak: 20,
        healthScore: 70,
        savings: 750000,
        points: 2000,
        isUp: true,
      ),
      LeaderboardUser(
        rank: 4,
        name: 'Tran Thi B',
        streak: 15,
        healthScore: 65,
        savings: 500000,
        points: 1500,
        isUp: false,
      ),
      LeaderboardUser(
        rank: 5,
        name: 'Pham Van C',
        streak: 10,
        healthScore: 60,
        savings: 300000,
        points: 1000,
        isUp: true,
      ),
    ];

    return Column(
      children: participants.map((user) {
        return LeaderboardCard(user: user);
      }).toList(),
    );
  }
}

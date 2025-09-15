import 'package:flutter/material.dart';
import 'package:smartquitiot/models/badge.dart' as mymodels;

class BadgeCard extends StatelessWidget {
  final mymodels.Badge badge; // 👈 dùng model Badge

  const BadgeCard({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Image.asset(badge.imagePath), // ví dụ property
          Text(badge.title),
        ],
      ),
    );
  }
}

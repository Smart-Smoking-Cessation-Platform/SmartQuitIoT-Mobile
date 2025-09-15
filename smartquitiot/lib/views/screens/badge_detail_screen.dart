import 'package:flutter/material.dart';
import 'package:smartquitiot/models/badge.dart' as mymodels;

class BadgeDetailScreen extends StatelessWidget {
  final mymodels.Badge badge; // 👈 dùng model Badge

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(badge.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(badge.imagePath),
            const SizedBox(height: 20),
            Text(badge.description),
          ],
        ),
      ),
    );
  }
}

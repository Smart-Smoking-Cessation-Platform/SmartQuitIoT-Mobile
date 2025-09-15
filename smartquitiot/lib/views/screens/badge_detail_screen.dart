import 'package:flutter/material.dart';
import 'package:smartquitiot/models/badge.dart' as mymodels;

class BadgeDetailScreen extends StatelessWidget {
  final mymodels.Badge badge;

  const BadgeDetailScreen({super.key, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        // 👇 màu text và icon back trắng
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(badge.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👇 dùng image mặc định nếu null hoặc rỗng
            if (badge.imagePath.isNotEmpty)
              Image.asset(badge.imagePath)
            else
              Image.asset('assets/images/default_badge.png'), // ảnh fallback

            const SizedBox(height: 20),
            Text(
              badge.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              badge.description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

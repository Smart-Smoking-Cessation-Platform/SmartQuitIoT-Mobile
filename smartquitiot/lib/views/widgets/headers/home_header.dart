import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart'; // 👈 import NotificationScreen

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment:
            CrossAxisAlignment.start, // ✅ cho phép hiển thị nhiều dòng
        children: [
          /// Bên trái
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SizedBox(height: 4),
              Text(
                'Hello, User...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          /// Bên phải
          Column(
            children: [
              // Hàng icon notification + setting
              Row(
                children: [
                  // 👇 Icon notification có thể click
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificationsScreen(), // 👈 mở NotificationScreen
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'lib/assets/notification.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // 👇 Icon settings (bạn có thể thêm onTap nếu muốn)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1FFF3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.settings,
                      size: 20,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ],
      ),
    );
  }
}

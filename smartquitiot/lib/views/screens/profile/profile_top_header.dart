import 'package:flutter/material.dart';
// ---------------- Header (Back + Notification) ----------------
class ProfileTopHeader extends StatelessWidget {
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;

  const ProfileTopHeader({super.key, this.onBackTap, this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: onBackTap ?? () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: onNotificationTap,
          ),
        ],
      ),
    );
  }
}

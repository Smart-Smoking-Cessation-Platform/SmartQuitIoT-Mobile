import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String status;
  final String avatarPath;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onBackTap;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.status,
    required this.avatarPath,
    this.onNotificationTap,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBackTap ?? () => Navigator.pop(context),
              ),
              Expanded(
                child: const Text(
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
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: onNotificationTap,
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        // Profile Picture
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            border: Border.fromBorderSide(
              BorderSide(color: Colors.white, width: 3),
            ),
          ),
          child: CircleAvatar(
            radius: 48,
            backgroundImage: AssetImage(avatarPath),
            backgroundColor: Colors.transparent,
          ),
        ),
        const SizedBox(height: 20),
        // Name and Status
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        Text(status, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 20),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String status;
  final String avatarPath;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.status,
    required this.avatarPath,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNetworkImage = avatarPath.startsWith('http');

    return Column(
      children: [
        const SizedBox(height: 20),

        // Avatar
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
            backgroundColor: Colors.grey[200],
            backgroundImage: isNetworkImage
                ? NetworkImage(avatarPath)
                : AssetImage(avatarPath) as ImageProvider,
            onBackgroundImageError: (_, __) {},
          ),
        ),

        const SizedBox(height: 15),

        // Name
        Text(
          name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        const SizedBox(height: 4),

        // Status
        Text(status, style: TextStyle(fontSize: 14, color: Colors.grey[600])),

        const SizedBox(height: 20),
      ],
    );
  }
}

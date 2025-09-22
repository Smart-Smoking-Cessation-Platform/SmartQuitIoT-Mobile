import 'package:SmartQuitIoT/views/screens/profile/edit_profile_screen.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_top_header.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/lists/profile_menu_item.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_header_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0xFF1DD1A1), Color(0xFF00D09E)],
              ),
            ),
          ),

          // Header trên cùng: back + title + notification
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ProfileTopHeader(),
          ),

          // Container trắng (bắt đầu dưới header)
          Positioned(
            top: 90, // chỉnh để container bắt đầu dưới header
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1FFF3),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Avatar + Name + Status
                      const SizedBox(height: 20),
                      ProfileHeaderSection(
                        name: 'John Doe',
                        status: 'I Am Gey',
                        avatarPath: "lib/assets/images/profile.png",
                      ),

                      // Menu Items
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        iconColor: const Color(0xFF0984E3),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'My Coach',
                        iconColor: const Color(0xFF0984E3),
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Setting',
                        iconColor: const Color(0xFF0984E3),
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help',
                        iconColor: const Color(0xFF0984E3),
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        iconColor: const Color(0xFF0984E3),
                        onTap: () {},
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
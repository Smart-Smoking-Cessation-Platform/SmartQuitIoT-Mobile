import 'package:SmartQuitIoT/views/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/profile_menu_item.dart';
import '../widgets/profile_header_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1DD1A1), Color(0xFF00D09E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header and Profile Picture
              ProfileHeaderSection(
                name: 'John Doe',
                status: 'I Am Gey',
                avatarPath: "lib/assets/profile.png",
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 0), // kéo lên sát avatar
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1FFF3), // light green
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Menu Items
                          ProfileMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            iconColor: const Color(0xFF0984E3),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const EditProfileScreen(),
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

                          SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

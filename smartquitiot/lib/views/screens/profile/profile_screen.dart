import 'package:SmartQuitIoT/views/screens/profile/edit_profile_screen.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_top_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/views/widgets/lists/profile_menu_item.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_header_section.dart';
import 'package:SmartQuitIoT/viewmodels/user_view_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userViewModelProvider.notifier).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userViewModelProvider);
    final user = userState.user;
    final isLoading = userState.isLoading;
    final error = userState.error;

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
                      const SizedBox(height: 20),

                      // Loading state
                      if (isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(
                              color: Color(0xFF1DD1A1),
                            ),
                          ),
                        )
                      // Error state
                      else if (error != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error loading profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  error,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    ref
                                        .read(userViewModelProvider.notifier)
                                        .loadUserProfile();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1DD1A1),
                                  ),
                                  child: const Text(
                                    'Retry',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      // Success state - Avatar + Name + Status
                      else if (user != null)
                        ProfileHeaderSection(
                          name: user.displayName,
                          status: 'Active Member', // You can customize this
                          avatarPath: user.avatarUrl.isNotEmpty
                              ? user.avatarUrl
                              : "lib/assets/images/profile.png",
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

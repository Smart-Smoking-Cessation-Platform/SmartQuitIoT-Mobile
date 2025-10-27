// lib/views/screens/settings/settings_screen.dart
import 'package:SmartQuitIoT/views/screens/appointments/appointments_screen.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart';
import 'package:SmartQuitIoT/views/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../../utils/snackbar_helper.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF00D09E),
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF00D09E),
        body: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF00D09E),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Setting',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.notifications_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSettingsSection([
                      _buildSettingItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.calendar_month_outlined,
                        title: 'Appointments',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AppointmentsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.analytics_outlined,
                        title: 'Change smoking data',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      _buildSettingItem(
                        icon: Icons.card_membership_outlined,
                        title: 'Membership',
                        titleColor: const Color(0xFF00D09E),
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 15),
                    _buildSettingsSection([
                      _buildSettingItem(
                        icon: Icons.psychology_outlined,
                        title: 'Advice',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.medical_services_outlined,
                        title: 'Nicotine replacement therapy',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.vape_free_outlined,
                        title: 'E-cigs/vapes',
                        onTap: () {},
                      ),
                    ]),
                    const SizedBox(height: 15),
                    _buildSettingsSection([
                      _buildSettingItem(
                        icon: Icons.support_agent_outlined,
                        title: 'Customer support',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.favorite_border,
                        title: 'Our philosophy',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.flag_outlined,
                        title: 'Our mission',
                        onTap: () {},
                      ),
                      _buildSettingItem(
                        icon: Icons.help_outline,
                        title: 'FAQ',
                        onTap: () {},
                      ),

                      // 🔥 Log out button có GoRouter + Snackbar
                      _buildSettingItem(
                        icon: Icons.logout,
                        title: 'Log out',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Confirm Logout'),
                              content: const Text(
                                'Are you sure you want to log out?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(dialogContext);
                                    await ref
                                        .read(authViewModelProvider.notifier)
                                        .logout();

                                    if (context.mounted) {
                                      SnackBarHelper.showSuccess(
                                        context,
                                        'Logout successfully!',
                                      );
                                      context.go('/login');
                                    }
                                  },
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: titleColor ?? const Color(0xFF6B7280), size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: titleColor ?? const Color(0xFF1F2937),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:SmartQuitIoT/views/screens/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Bên trái
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                'welcome'.tr(), // hoặc 'helloUser'.tr()
                style: const TextStyle(
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
              Row(
                children: [
                  /// Notification
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
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
                        'lib/assets/images/notification.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  /// Settings
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                  ),
                  const SizedBox(width: 12),

                  /// Language Switcher (Flag icon)
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: Text(
                            'select_language'.tr(),
                          ), // Thêm vào file json
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Text("🇺🇸"),
                                title: const Text("English"),
                                onTap: () async {
                                  await context.setLocale(const Locale('en'));
                                  Navigator.pop(dialogContext);
                                },
                              ),
                              ListTile(
                                leading: const Text("🇻🇳"),
                                title: const Text("Tiếng Việt"),
                                onTap: () async {
                                  await context.setLocale(const Locale('vi'));
                                  Navigator.pop(dialogContext);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.locale.languageCode == 'en' ? "🇺🇸" : "🇻🇳",
                        style: const TextStyle(fontSize: 18),
                      ),
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

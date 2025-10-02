import 'package:SmartQuitIoT/l10n/app_localizations.dart';
import 'package:SmartQuitIoT/views/screens/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeHeader extends StatefulWidget {
  const HomeHeader({super.key});

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  Locale _currentLocale = const Locale('en'); // default

  void _changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });

    // ⚠️ Nếu bạn muốn thay đổi toàn app thì phải wrap MaterialApp bằng Provider/InheritedWidget
    // rồi update locale. Đây demo trong header thôi.
  }

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
                AppLocalizations.of(context)?.helloUser ?? 'Hello, User...',
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
                        builder: (context) => AlertDialog(
                          title: const Text("Select Language"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Text("🇺🇸"),
                                title: const Text("English"),
                                onTap: () {
                                  _changeLanguage(const Locale('en'));
                                  Navigator.pop(context);
                                },
                              ),
                              ListTile(
                                leading: const Text("🇻🇳"),
                                title: const Text("Tiếng Việt"),
                                onTap: () {
                                  _changeLanguage(const Locale('vi'));
                                  Navigator.pop(context);
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
                        _currentLocale.languageCode == 'en' ? "🇺🇸" : "🇻🇳",
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

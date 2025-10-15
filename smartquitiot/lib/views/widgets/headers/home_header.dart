import 'package:SmartQuitIoT/views/screens/settings/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/auth_provider.dart';
import '../../screens/notifications/notification_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../utils/snackbar_helper.dart';
import '../../../../viewmodels/auth_view_model.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // final username = ref.watch(authViewModelProvider.select((state) => state.username));
    final authState = ref.watch(authViewModelProvider);
    final username = authState.username;
    print('--- >>> HOME_HEADER BUILD: Username is [$username], IsAuthenticated is [${authState.isAuthenticated}]');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'welcome'.tr(args: [username ?? 'User']),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Row(
            children: [
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
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text('select_language'.tr()),
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
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () async {
                  await ref.read(authViewModelProvider.notifier).logout();
                  if (context.mounted) {
                    SnackBarHelper.showSuccess(context, 'Logout successfully!');
                  }
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1FFF3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    size: 20,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
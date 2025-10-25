import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/social_button.dart';
import 'package:SmartQuitIoT/viewmodels/auth_view_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.error != null && previous?.error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.redAccent,
          ),
        );
        ref.read(authViewModelProvider.notifier).clearError();
      }

      if (next.isAuthenticated &&
          (previous == null || !previous.isAuthenticated)) {
        if (next.isFirstLogin == true) {
          context.go('/onboarding');
        } else {
          context.go('/main');
        }
      }
    });

    final isLoading = ref.watch(
      authViewModelProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: Stack(
          children: [
            /// Main content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  /// Logo + App name
                  Column(
                    children: [
                      Image.asset(
                        'lib/assets/logo/logo-2.png',
                        width: 120,
                        height: 120,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'app_name'.tr(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  /// Sign In + Sign Up
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'sign_in'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF00D09E).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => context.go('/signup'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'sign_up'.tr(),
                            style: const TextStyle(
                              color: Color(0xFF00D09E),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 1.2,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'or'.tr(),
                          style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 1.2,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Social login
                  Column(
                    children: [
                      // SocialButton(
                      //   onTap: () async {
                      //     // Dòng code này sẽ xóa sạch cache đăng nhập Google
                      //     await GoogleSignIn.instance.signOut();
                      //     await GoogleSignIn.instance.disconnect();
                      //     print('--- ĐÃ ĐĂNG XUẤT HOÀN TOÀN KHỎI GOOGLE ---');
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text('Đã reset Google Sign-In!')),
                      //     );
                      //   },
                      //   child: Text('Reset Google Sign-In'),
                      // ),
                      SocialButton(
                        onTap: isLoading
                            ? () {}
                            : () => ref
                                  .read(authViewModelProvider.notifier)
                                  .loginWithGoogle(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/assets/images/google.png',
                              width: 20,
                              height: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'sign_in_google'.tr(),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // NÚT FACEBOOK BỊ VÔ HIỆU HÓA
                      // Maybe in the future....
                      // SocialButton(
                      //   onTap: () {},
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       Image.asset(
                      //         'lib/assets/images/facebook.png',
                      //         width: 20,
                      //         height: 20,
                      //       ),
                      //       const SizedBox(width: 12),
                      //       Text(
                      //         'sign_in_facebook'.tr(),
                      //         style: TextStyle(
                      //           color: Colors.black87,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.w500,
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  /// Forgot Password
                  Center(
                    child: GestureDetector(
                      onTap: isLoading ? null : () => context.go('/forgot'),
                      child: RichText(
                        text: TextSpan(
                          text: '${'forgot_password'.tr()} ',
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: 'click_here'.tr(),
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),

            /// Language Switcher (vẫn giữ nguyên)
            Positioned(
              top: 16,
              right: 16,
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('select_language'.tr()),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: const Text("🇺🇸"),
                            title: const Text("English"),
                            onTap: () async {
                              await context.setLocale(const Locale('en'));
                              context.pop();
                            },
                          ),
                          ListTile(
                            leading: const Text("🇻🇳"),
                            title: const Text("Tiếng Việt"),
                            onTap: () async {
                              await context.setLocale(const Locale('vi'));
                              context.pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    context.locale.languageCode == 'en' ? "🇺🇸" : "🇻🇳",
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

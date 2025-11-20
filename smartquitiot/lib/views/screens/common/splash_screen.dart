import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Đợi một chút để hiển thị splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Kiểm tra authentication status
    final authViewModel = ref.read(authViewModelProvider.notifier);
    final isAuthenticated = await authViewModel.checkAuthStatus();

    if (!mounted) return;

    if (isAuthenticated) {
      // User đã đăng nhập, chuyển đến màn hình chính
      final authState = ref.read(authViewModelProvider);
      if (authState.isFirstLogin == true) {
        context.go('/onboarding');
      } else {
        context.go('/main');
      }
    } else {
      // User chưa đăng nhập, chuyển đến welcome screen
      context.go('/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00D09E),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'lib/assets/logo/logo-2.png',
                width: 230,
                height: 230,
              ),
              const SizedBox(height: 20),
              Text(
                'SmartQuit',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

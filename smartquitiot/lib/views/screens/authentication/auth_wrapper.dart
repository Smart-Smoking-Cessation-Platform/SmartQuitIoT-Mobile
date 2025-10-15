// lib/views/auth/auth_wrapper.dart
import 'package:SmartQuitIoT/views/screens/common/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/state/auth_state.dart';
import 'package:SmartQuitIoT/viewmodels/auth_view_model.dart';

import '../../../providers/auth_provider.dart';
import '../onboarding/onboarding_screen.dart';


class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      if (next.isAuthenticated && previous?.isAuthenticated == false) {
        final isFirstLogin = next.isFirstLogin ?? false;

        if (isFirstLogin) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OnboardingScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
      }
    });
    final authState = ref.watch(authViewModelProvider);
    if (authState.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const OnboardingScreen();
    }
  }
}
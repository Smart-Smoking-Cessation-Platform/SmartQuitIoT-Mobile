import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/app_theme.dart';
import 'package:SmartQuitIoT/views/screens/login_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding_screen.dart';
import 'package:SmartQuitIoT/views/screens/signup_screen.dart';
import 'package:SmartQuitIoT/views/screens/splash_screen.dart';
import 'package:SmartQuitIoT/views/screens/welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/questionnaire_screen.dart';
import 'package:SmartQuitIoT/views/screens/_relaunch_screen.dart';
import 'package:SmartQuitIoT/views/screens/forgot_password_screen.dart';
import 'package:SmartQuitIoT/views/screens/debug_home_screen.dart';
import 'package:SmartQuitIoT/views/screens/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/premium_membership_screen.dart';
import 'package:SmartQuitIoT/views/screens/article_detail_screen.dart';
import 'package:SmartQuitIoT/views/screens/community_screen.dart';
import 'package:SmartQuitIoT/views/screens/filter_post_screen.dart';
import 'package:SmartQuitIoT/views/screens/badges_screen.dart';
import 'package:SmartQuitIoT/views/screens/notification_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoke Quit',
      theme: AppTheme.light(),
      home: const SplashScreen(),
   
      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/onboarding': (_) => OnboardingScreen(),
        '/home': (_) => const MainNavigationScreen(),
        '/questionnaire': (_) => const QuestionnaireScreen(),
        '/relaunch': (_) => const RelaunchScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/debug-home': (_) => const DebugHomeScreen(),
      },
    );
  }
}

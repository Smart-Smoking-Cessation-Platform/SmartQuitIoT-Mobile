import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartquitiot/utils/app_theme.dart';
import 'package:smartquitiot/views/screens/login_screen.dart';
import 'package:smartquitiot/views/screens/onboarding_screen.dart';
import 'package:smartquitiot/views/screens/signup_screen.dart';
import 'package:smartquitiot/views/screens/splash_screen.dart';
import 'package:smartquitiot/views/screens/welcome_screen.dart';
import 'package:smartquitiot/views/screens/questionnaire_screen.dart';
import 'package:smartquitiot/views/screens/_relaunch_screen.dart';
import 'package:smartquitiot/views/screens/forgot_password_screen.dart';
import 'package:smartquitiot/views/screens/debug_home_screen.dart';
import 'package:smartquitiot/views/screens/home_screen.dart';

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
        '/home': (_) => const HomeScreen(),
        '/questionnaire': (_) => const QuestionnaireScreen(),
        '/relaunch': (_) => const RelaunchScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/debug-home': (_) => const DebugHomeScreen(),
      },
    );
  }
}

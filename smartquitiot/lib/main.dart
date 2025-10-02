import 'package:SmartQuitIoT/views/screens/common/home_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/utils/app_theme.dart';
import 'package:SmartQuitIoT/views/screens/authentication/login_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/onboarding_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/signup_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/_relaunch_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/forgot_password_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/debug_home_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/api_demo_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

import 'l10n/app_localizations.dart';


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

      localizationsDelegates: const [
        AppLocalizations.delegate, 
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), 
        Locale('vi'), 
      ],
      locale: const Locale('en'), 

      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/onboarding': (_) => OnboardingScreen(),
        '/home': (_) => const MainNavigationScreen(),
        '/relaunch': (_) => const RelaunchScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/debug-home': (_) => const DebugHomeScreen(),
        '/api-demo': (_) => const ApiDemoScreen(),
        '/main': (_) => const HomeScreen(),
      },
    );
  }
}

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
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'lib/assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Smoke Quit',
      theme: AppTheme.light(),
      home: const SplashScreen(),

      // easy_localization tự động inject localizationsDelegates
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

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

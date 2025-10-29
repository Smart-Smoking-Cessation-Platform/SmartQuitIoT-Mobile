import 'package:SmartQuitIoT/views/screens/common/_relaunch_screen.dart';
import 'package:SmartQuitIoT/views/screens/diary/create_diary_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/success_payment_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/create_post_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_detail_screen.dart';
import 'package:SmartQuitIoT/views/screens/posts/post_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import các màn hình
import 'package:SmartQuitIoT/views/screens/common/splash_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/auth_wrapper.dart';
import 'package:SmartQuitIoT/views/screens/authentication/login_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/signup_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/forgot_password_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/onboarding_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/debug_home_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/premium_membership_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_cancel_screen.dart';
import 'package:SmartQuitIoT/views/screens/membership/current_subscription_screen.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_screen.dart';
import 'package:SmartQuitIoT/views/screens/settings/setting_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (_, __) => const AuthWrapper()),
    GoRoute(path: '/welcome', builder: (_, __) => const WelcomeScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (_, __) => const SignUpScreen()),
    GoRoute(path: '/forgot', builder: (_, __) => const ForgotPasswordScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => OnboardingScreen()),
    GoRoute(path: '/main', builder: (_, __) => const MainNavigationScreen()),
    GoRoute(path: '/relaunch', builder: (_, __) => const RelaunchScreen()),
    GoRoute(path: '/debug-home', builder: (_, __) => const DebugHomeScreen()),
    GoRoute(
      path: '/create-post',
      builder: (context, state) => const CreatePostScreen(),
    ),
    GoRoute(
      path: '/posts',
      builder: (context, state) => const PostListScreen(),
    ),
    GoRoute(
      path: '/posts/:id',
      builder: (context, state) {
        final idStr = state.pathParameters['id'];
        final id = int.tryParse(idStr ?? '');
        if (id == null) {
          return const Scaffold(body: Center(child: Text('Invalid Post ID')));
        }
        return PostDetailScreen(postId: id);
      },
    ),

    GoRoute(
      path: '/premium',
      builder: (_, __) => const PremiumMembershipScreen(),
    ),
    GoRoute(
      path: '/membership',
      builder: (context, state) => const PremiumMembershipScreen(),
    ),
    GoRoute(
      path: '/my-subscription',
      builder: (context, state) => const CurrentSubscriptionScreen(),
    ),
    GoRoute(
      path: '/diary/create',
      builder: (context, state) => const CreateDiaryScreen(),
    ),
    GoRoute(
      path: '/payment/success',
      builder: (context, state) {
        final selectedPlan = state.extra is Map
            ? (state.extra as Map)['selectedPlan'] ?? ''
            : '';
        final paymentMethod = state.extra is Map
            ? (state.extra as Map)['paymentMethod'] ?? ''
            : '';
        return SuccessScreen(
          selectedPlan: selectedPlan,
          paymentMethod: paymentMethod,
        );
      },
    ),
    GoRoute(
      path: '/payment/cancel',
      builder: (context, state) {
        return const PaymentCancelScreen();
      },
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

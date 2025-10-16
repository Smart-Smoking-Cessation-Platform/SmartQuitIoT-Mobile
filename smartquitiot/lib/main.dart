import 'dart:async';
import 'package:SmartQuitIoT/providers/membership_provider.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_cancel_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_links/app_links.dart';

// Screens
import 'package:SmartQuitIoT/views/screens/common/home_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/splash_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/payment_success_screen.dart';
import 'package:SmartQuitIoT/views/screens/payment/premium_membership_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/login_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/signup_screen.dart';
import 'package:SmartQuitIoT/views/screens/authentication/forgot_password_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/onboarding_screen.dart';
import 'package:SmartQuitIoT/views/screens/onboarding/welcome_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/_relaunch_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/debug_home_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/main_navigation_screen.dart';
import 'package:SmartQuitIoT/views/screens/common/api_demo_screen.dart';
import 'package:SmartQuitIoT/utils/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await GoogleSignIn.instance.initialize(
    serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
  );

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

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  late AppLinks _appLinks;

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    _linkSubscription = _appLinks.uriLinkStream.listen((uri) async {
      if (uri != null) {
        debugPrint('Deep link nhận được (stream): $uri');
        await Future.delayed(const Duration(milliseconds: 300));
        _onDeepLink(uri);
      }
    });

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('🔥 Deep link nhận được (initial): $initialUri');
      await Future.delayed(const Duration(milliseconds: 300));
      _onDeepLink(initialUri);
    }
  }

  void _onDeepLink(Uri uri) async {
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;

    final path = uri.pathSegments.join('/');
    final params = uri.queryParameters;
    final code = params['code'] ?? '';
    final id = params['id'] ?? '';
    final cancelStr = params['cancel'] ?? 'false';
    final cancel = cancelStr.toLowerCase() == 'true';
    final statusStr = params['status'] ?? '';
    final orderCodeNum = int.tryParse(params['orderCode'] ?? '') ?? 0;

    String membershipStatus;
    if (cancel || !(path.contains('success') || statusStr.toUpperCase() == 'PAID' || statusStr.toUpperCase() == 'SUCCESS')) {
      membershipStatus = 'UNAVAILABLE';
    } else {
      membershipStatus = 'AVAILABLE';
    }

    final Map<String, dynamic> body = {
      'code': code,
      'id': id,
      'cancel': cancel,
      'status': statusStr,
      'orderCode': orderCodeNum,
    };

    debugPrint('🔗 Deep link received: $uri');
    debugPrint('➡︎ Sending process body: $body');

    showDialog(
      context: navigator.context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));

    try {
      await ref.read(membershipViewModelProvider.notifier).processPaymentResult(body);
    } catch (e) {
      debugPrint('Error processing payment result: $e');
    }

    navigator.pop();

    if (cancel) {
      navigator.pushNamedAndRemoveUntil(
        '/payment-cancel',
            (_) => false,
        arguments: body,
      );
    } else if (membershipStatus == 'AVAILABLE') {
      navigator.pushNamedAndRemoveUntil(
        '/payment-success',
            (_) => false,
        arguments: body,
      );
    } else {
      ScaffoldMessenger.of(navigator.context).showSnackBar(
        SnackBar(content: Text('Payment failed for order: $orderCodeNum')),
      );
    }
  }



  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Smoke Quit',
      theme: AppTheme.light(),
      home: const SplashScreen(),

      // Easy Localization
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,

      routes: {
        '/welcome': (_) => const WelcomeScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignUpScreen(),
        '/onboarding': (_) => OnboardingScreen(),
        '/home': (_) => const HomeScreen(),
        '/relaunch': (_) => const RelaunchScreen(),
        '/forgot': (_) => const ForgotPasswordScreen(),
        '/debug-home': (_) => const DebugHomeScreen(),
        '/api-demo': (_) => const ApiDemoScreen(),
        '/main': (_) => const MainNavigationScreen(),
        '/payment-success': (_) => const PaymentSuccessScreen(),
        '/payment-cancel': (_) => const PaymentCancelScreen(),
        '/premium': (_) => const PremiumMembershipScreen(),
      },
    );
  }
}

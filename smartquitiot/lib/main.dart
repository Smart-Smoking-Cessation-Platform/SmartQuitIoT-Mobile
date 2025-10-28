import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Services & Providers
import 'package:SmartQuitIoT/providers/membership_provider.dart';
import 'package:SmartQuitIoT/services/token_storage_service.dart';
import 'package:SmartQuitIoT/services/app_token_manager.dart';

// Theme & Router
import 'package:SmartQuitIoT/utils/app_theme.dart';
import 'package:SmartQuitIoT/routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppTokenManager.instance.init();

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
        _handleDeepLink(uri);
      }
    });

    final initialUri = await _appLinks.getInitialLink();
    if (initialUri != null) {
      debugPrint('🔥 Deep link nhận được (initial): $initialUri');
      await Future.delayed(const Duration(milliseconds: 300));
      _handleDeepLink(initialUri);
    }
  }

  Future<void> _handleDeepLink(Uri uri) async {
    final router = appRouter;
    final path = uri.pathSegments.join('/');
    final params = uri.queryParameters;

    final code = params['code'] ?? '';
    final id = params['id'] ?? '';
    final cancel = params['cancel']?.toLowerCase() == 'true';
    final statusStr = params['status'] ?? '';
    final orderCodeNum = int.tryParse(params['orderCode'] ?? '') ?? 0;

    String membershipStatus;
    if (cancel ||
        !(path.contains('success') ||
            statusStr.toUpperCase() == 'PAID' ||
            statusStr.toUpperCase() == 'SUCCESS')) {
      membershipStatus = 'UNAVAILABLE';
    } else {
      membershipStatus = 'AVAILABLE';
    }

    final body = {
      'code': code,
      'id': id,
      'cancel': cancel,
      'status': statusStr,
      'orderCode': orderCodeNum,
    };

    debugPrint('🔗 Deep link received: $uri');
    debugPrint('➡︎ Sending process body: $body');

    showDialog(
      context: rootNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2));

    try {
      await ref
          .read(membershipViewModelProvider.notifier)
          .processPaymentResult(body);
    } catch (e) {
      debugPrint('Error processing payment result: $e');
    }

    if (rootNavigatorKey.currentContext!.mounted) {
      Navigator.of(rootNavigatorKey.currentContext!).pop();
    }

    if (cancel) {
      router.go('/payment/cancel', extra: body);
    } else if (membershipStatus == 'AVAILABLE') {
      router.go('/payment/success', extra: body);
    } else {
      ScaffoldMessenger.of(rootNavigatorKey.currentContext!).showSnackBar(
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
    return MaterialApp.router(
      title: 'SmartQuit IoT',
      theme: AppTheme.light(),
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        ...context.localizationDelegates,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
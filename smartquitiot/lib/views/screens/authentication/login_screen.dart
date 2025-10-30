import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../services/token_storage_service.dart';
import 'package:SmartQuitIoT/views/widgets/inputs/custom_text_field.dart';
import 'package:SmartQuitIoT/views/widgets/headers/auth_header.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/primary_button.dart';
import 'package:SmartQuitIoT/views/widgets/forms/auth_divider.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/social_login_buttons.dart';
import '../../../models/state/auth_state.dart';
import '../../../utils/notification_helper.dart';
import 'package:SmartQuitIoT/providers/user_provider.dart';
import 'package:SmartQuitIoT/providers/websocket_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;
  bool _isFormValid = false;
  bool _isNavigating = false;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final usernameOrEmail = _username.text.trim();
    final password = _password.text.trim();

    final authViewModel = ref.read(authViewModelProvider.notifier);
    final success = await authViewModel.login(usernameOrEmail, password);

    if (!success && mounted) {
      final error = ref.read(authViewModelProvider).error;
      if (error != null) {
        NotificationHelper.showTopNotification(
          context,
          title: 'Login Failed',
          message: error,
          isError: true,
        );
        ref.read(authViewModelProvider.notifier).clearError();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authViewModelProvider, (previous, next) async {
      // Báo lỗi đăng nhập
      if (next.error != null && previous?.error != next.error) {
        NotificationHelper.showTopNotification(
          context,
          title: 'Login Failed',
          message: next.error!,
          isError: true,
        );
        ref.read(authViewModelProvider.notifier).clearError();
      }

      // Đăng nhập thành công (handle cả previous = null và previous.isAuthenticated = false)
      if (next.isAuthenticated && (previous?.isAuthenticated != true)) {
        setState(() {
          _isNavigating = true;
        });

        // Show success notification
        NotificationHelper.showTopNotification(
          context,
          title: '🎉 Success',
          message: 'Login successful! Redirecting...',
        );

        final tokenStorage = TokenStorageService();
        await tokenStorage.saveTokens(
          next.accessToken ?? '',
          next.refreshToken ?? '',
        );

        // Initialize WebSocket connection
        try {
          debugPrint('🔌 [LoginScreen] Initializing WebSocket...');
          final userService = ref.read(userServiceProvider);
          final userProfile = await userService.getUserProfile();
          final memberId = userProfile.id;
          
          debugPrint('👤 [LoginScreen] Member ID: $memberId');
          final websocketManager = ref.read(websocketManagerProvider);
          await websocketManager.initialize(memberId);
          debugPrint('✅ [LoginScreen] WebSocket initialized successfully!');
        } catch (e) {
          debugPrint('❌ [LoginScreen] WebSocket initialization error: $e');
          // Continue login flow even if WebSocket fails
        }

        // Wait 2 seconds with spinner visible
        await Future.delayed(const Duration(seconds: 2));
        if (!mounted) return;

        final isFirstLogin = next.isFirstLogin ?? false;
        if (isFirstLogin) {
          context.go('/onboarding');
        } else {
          context.go('/main');
        }

        setState(() {
          _isNavigating = false;
        });
      }
    });

    final authState = ref.watch(authViewModelProvider);
    const greenColor = Color(0xFF00D09E);

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeader(title: 'hello'.tr(), height: 120),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  onChanged: () {
                    setState(() {
                      _isFormValid = _formKey.currentState?.validate() ?? false;
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CustomTextField(
                        controller: _username,
                        label: 'username'.tr(),
                        hint: 'username_hint'.tr(),
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username or email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _password,
                        label: 'password'.tr(),
                        hint: 'password_hint'.tr(),
                        obscure: _obscure,
                        onToggle: () => setState(() => _obscure = !_obscure),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      /// Nút login
                      (authState.isLoading || _isNavigating)
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: greenColor,
                              ),
                            )
                          : PrimaryButton(
                              text: 'sign_in'.tr(),
                              onPressed: _isFormValid ? _handleLogin : null,
                            ),

                      const SizedBox(height: 16),

                      /// Forgot password
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/forgot'),
                          child: Text(
                            'forgot_password'.tr(),
                            style: const TextStyle(
                              color: greenColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const AuthDivider(),
                      const SizedBox(height: 24),

                      /// Social login
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: SocialLoginButtons(
                          onGoogleTap: () async {
                            await ref
                                .read(authViewModelProvider.notifier)
                                .loginWithGoogle();
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Đăng ký tài khoản
                      Center(
                        child: TextButton(
                          onPressed: () => context.push('/signup'),
                          child: RichText(
                            text: TextSpan(
                              text: "no_account".tr(),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'sign_up'.tr(),
                                  style: const TextStyle(
                                    color: greenColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

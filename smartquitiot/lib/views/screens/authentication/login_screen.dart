import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:SmartQuitIoT/views/widgets/inputs/custom_text_field.dart';
import 'package:SmartQuitIoT/views/widgets/headers/auth_header.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/primary_button.dart';
import 'package:SmartQuitIoT/views/widgets/forms/auth_divider.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/social_login_buttons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3), // Light green background
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              AuthHeader(title: 'hello'.tr(), height: 120),

              const SizedBox(height: 24),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _email,
                      label: 'email'.tr(),
                      hint: 'email_hint'.tr(),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _password,
                      label: 'password'.tr(),
                      hint: 'password_hint'.tr(),
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    PrimaryButton(
                      text: 'sign_in'.tr(),
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        '/onboarding',
                      ),
                    ),

                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/forgot'),
                        child: Text(
                          'forgot_password'.tr(),
                          style: const TextStyle(
                            color: Color(0xFF00D09E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    const SizedBox(height: 8),

                    // Divider
                    const AuthDivider(),

                    const SizedBox(height: 24),

                    // Social login buttons
                    const SocialLoginButtons(),

                    const SizedBox(height: 24),

                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signup'),
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
                                  color: Color(0xFF00D09E),
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
            ],
          ),
        ),
      ),
    );
  }
}

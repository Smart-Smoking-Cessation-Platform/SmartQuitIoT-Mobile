import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/auth_header.dart';
import '../widgets/primary_button.dart';
import '../widgets/auth_divider.dart';
import '../widgets/social_login_buttons.dart';

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
              const AuthHeader(title: 'Hello!', height: 120),

              const SizedBox(height: 24),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _password,
                      label: 'Password',
                      hint: '••••••••',
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    PrimaryButton(
                      text: 'Sign In',
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
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
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
                          text: const TextSpan(
                            text: "Doesn't have account yet? ",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign Up',
                                style: TextStyle(
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

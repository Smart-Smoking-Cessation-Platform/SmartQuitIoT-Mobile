import 'package:flutter/material.dart';
import 'package:smartquitiot/views/widgets/auth_text_field.dart';
import 'package:smartquitiot/views/widgets/curved_header.dart';
import 'package:smartquitiot/views/widgets/primary_button.dart';
import 'package:smartquitiot/views/widgets/social_icon_circle.dart';

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
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFDADCE0),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CurvedHeader(
                child: Text(
                  'Hello!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    AuthTextField(
                      controller: _password,
                      label: 'Mật Khẩu',
                      hint: '••••••••',
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Sign In',
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    PrimaryButton(
                      label: 'Sign Up',
                      filled: false,
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text('or'),
                        ),
                        Expanded(child: Divider(color: scheme.outlineVariant)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SocialIconCircle(
                          asset: 'lib/assets/facebook.png',
                          onTap: () {},
                          background: const Color(0xFF1877F2),
                          border: const Color(0xFF1877F2),
                        ),
                        const SizedBox(width: 16),
                        SocialIconCircle(
                          asset: 'lib/assets/google.png',
                          onTap: () {},
                          background: Colors.white,
                          border: scheme.outline,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/forgot'),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Forgot password? ',
                                style: TextStyle(color: Colors.black87),
                              ),
                              TextSpan(
                                text: 'Click here',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signup'),
                        child: const Text("Doesn't have account yet? Sign Up"),
                      ),
                    ),
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

// Header replaced by reusable CurvedHeader

// Old inline social row removed in favor of SocialIconCircle widget

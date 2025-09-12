import 'package:flutter/material.dart';

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
              Container(
                height: 120,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09E), // Dark green
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hello!',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Form fields
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _CustomTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'example@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _CustomTextField(
                      controller: _password,
                      label: 'Password',
                      hint: '••••••••',
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 32),

                    // Sign In Button
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E),
                        borderRadius: BorderRadius.circular(28),
                      ),
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushReplacementNamed(context, '/home'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

                    // Sign Up Button (outlined)
                    // Container(
                    //   width: double.infinity,
                    //   height: 56,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white.withOpacity(0.8),
                    //     borderRadius: BorderRadius.circular(28),
                    //     border: Border.all(
                    //       color: const Color(0xFF00D09E).withOpacity(0.3),
                    //       width: 1,
                    //     ),
                    //   ),
                    //   child: OutlinedButton(
                    //     onPressed: () =>
                    //         Navigator.pushNamed(context, '/signup'),
                    //     style: OutlinedButton.styleFrom(
                    //       backgroundColor: Colors.transparent,
                    //       side: BorderSide.none,
                    //       shape: RoundedRectangleBorder(
                    //         borderRadius: BorderRadius.circular(28),
                    //       ),
                    //     ),
                    //     child: const Text(
                    //       'Sign Up',
                    //       style: TextStyle(
                    //         color: Color(0xFF00D09E),
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    const SizedBox(height: 8),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'or',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ),
                        Expanded(
                          child: Container(height: 1, color: Colors.black26),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Social login buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialIconCircle(
                          asset: 'lib/assets/facebook.png',
                          onTap: () {},
                          background: const Color(0xFF1877F2),
                          borderColor: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        _SocialIconCircle(
                          asset: 'lib/assets/google.png',
                          onTap: () {},
                          background: Colors.white,
                          borderColor: Colors.grey.shade300,
                        ),
                      ],
                    ),

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

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final VoidCallback? onToggle;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.keyboardType,
    this.obscure = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF00D09E).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: const Color(0xFF00D09E).withOpacity(0.3),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00D09E), width: 2),
            ),
            suffixIcon: onToggle != null
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: const Color(0xFF00D09E),
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

class _SocialIconCircle extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;
  final Color background;
  final Color borderColor;

  const _SocialIconCircle({
    required this.asset,
    required this.onTap,
    required this.background,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: Image.asset(asset, width: 28, height: 28)),
      ),
    );
  }
}

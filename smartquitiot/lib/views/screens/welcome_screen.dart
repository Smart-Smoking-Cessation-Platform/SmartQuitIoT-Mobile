import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3), // Light green background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Logo và title
              Column(
                children: [
                  // Logo từ assets
                  Image.asset('lib/assets/logo.png', width: 120, height: 120),
                  const SizedBox(height: 24),
                  Text(
                    'SMART QUIT',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00D09E),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Cụm 1: Sign In và Sign Up buttons
              Column(
                children: [
                  // Sign In button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09E),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sign Up button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFF00D09E).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: OutlinedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Color(0xFF00D09E),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Divider đơn giản
              Row(
                children: [
                  Expanded(child: Container(height: 1, color: Colors.black26)),
                  Expanded(child: Container(height: 1, color: Colors.black26)),
                ],
              ),

              const SizedBox(height: 24),

              // Cụm 2: Social login buttons
              Column(
                children: [
                  // Google Sign In
                  _SocialButton(
                    onTap: () => Navigator.pushNamed(context, '/onboarding'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/google.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Sign in with Google',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Facebook Sign In
                  _SocialButton(
                    onTap: () => Navigator.pushNamed(context, '/onboarding'),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'lib/assets/facebook.png',
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Login with Facebook',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Cụm 3: Forgot Password
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/forgot'),
                  child: RichText(
                    text: const TextSpan(
                      text: 'Forgot Password? ',
                      style: TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Click Here',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _SocialButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.black12, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: child,
      ),
    );
  }
}

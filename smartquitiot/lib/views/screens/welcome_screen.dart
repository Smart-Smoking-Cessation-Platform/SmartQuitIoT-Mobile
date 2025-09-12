import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              width: double.infinity,
              color: scheme.primary,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    'lib/assets/logo.png',
                    width: 96,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SmartQuit',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/login'),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: OutlinedButton.styleFrom(
                      shape: const StadiumBorder(),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Sign Up'),
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    color: Colors.white,
                    borderColor: scheme.outline,
                    icon: Icons.g_mobiledata,
                    label: 'Sign in with Google',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _SocialButton(
                    color: const Color(0xFF1877F2),
                    borderColor: const Color(0xFF1877F2),
                    icon: Icons.facebook,
                    iconColor: Colors.white,
                    labelColor: Colors.white,
                    label: 'Continue with Facebook',
                    onTap: () {},
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? labelColor;
  final String label;

  const _SocialButton({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor ?? Colors.black87),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: labelColor ?? Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback? onFacebookTap;
  final VoidCallback? onGoogleTap;
  final Color? backgroundColor;
  final Color? borderColor;

  const SocialLoginButtons({
    super.key,
    this.onFacebookTap,
    this.onGoogleTap,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          asset: 'lib/assets/facebook.png',
          onTap: onFacebookTap ?? () {},
          background: backgroundColor ?? Colors.white,
          borderColor: borderColor ?? Colors.grey.shade300,
        ),
        const SizedBox(width: 16),
        Image.asset(
          asset: 'lib/assets/google.png',
          onTap: onGoogleTap ?? () {},
          background: backgroundColor ?? Colors.white,
          borderColor: borderColor ?? Colors.grey.shade300,
        ),
      ],
    );
  }
}

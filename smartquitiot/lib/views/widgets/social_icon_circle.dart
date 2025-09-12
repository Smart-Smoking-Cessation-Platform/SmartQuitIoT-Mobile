import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialIconCircle extends StatelessWidget {
  final String asset; // supports svg or png
  final Color? background;
  final Color? border;
  final VoidCallback onTap;

  const SocialIconCircle({
    super.key,
    required this.asset,
    required this.onTap,
    this.background,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSvg = asset.toLowerCase().endsWith('.svg');
    return Material(
      color: background ?? Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: border ?? Colors.black12),
          ),
          alignment: Alignment.center,
          child: isSvg
              ? SvgPicture.asset(asset, width: 24, height: 24)
              : Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

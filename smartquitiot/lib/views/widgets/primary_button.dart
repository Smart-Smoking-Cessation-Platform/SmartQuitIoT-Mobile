import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool filled;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = true,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle outlined = OutlinedButton.styleFrom(
      shape: const StadiumBorder(),
      minimumSize: const Size.fromHeight(48),
    );
    if (!filled) {
      return OutlinedButton(
        onPressed: onPressed,
        style: outlined,
        child: Text(label),
      );
    }
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}

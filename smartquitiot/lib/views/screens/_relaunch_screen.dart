import 'package:flutter/material.dart';

class RelaunchScreen extends StatefulWidget {
  const RelaunchScreen({super.key});

  @override
  State<RelaunchScreen> createState() => _RelaunchScreenState();
}

class _RelaunchScreenState extends State<RelaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDADCE0),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('lib/assets/logo.png', width: 160, height: 160),
                const SizedBox(height: 12),
                Text(
                  'Welcome to SmartQuit',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

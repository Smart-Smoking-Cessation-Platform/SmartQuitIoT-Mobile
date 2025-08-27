import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartquitiot/utils/app_theme.dart';
import 'package:smartquitiot/views/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smoke Quit',
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}

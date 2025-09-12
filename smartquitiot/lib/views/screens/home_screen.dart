import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartquitiot/viewmodels/home_view_model.dart';
import '../widgets/hero_timer_card.dart';
import '../widgets/stats_row.dart';
import '../widgets/progress_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeViewModelProvider);
    final vm = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFDADCE0),
      appBar: AppBar(
        title: const Text('SmartQuit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Navigator.pushReplacementNamed(context, '/welcome'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const HeroTimerCard(),
          const SizedBox(height: 16),
          StatsRow(
            daysQuit: 1,
            cigarettesAvoided: state.counter,
            moneySaved: '10.000',
          ),
          const SizedBox(height: 16),
          const ProgressCard(
            title: 'Quit Plan',
            progress: 0.1,
            progressText: 'Preparation 0%',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/onboarding'),
            child: const Text('Start Onboarding'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: vm.increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

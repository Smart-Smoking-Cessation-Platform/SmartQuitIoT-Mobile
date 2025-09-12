import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartquitiot/viewmodels/home_view_model.dart';

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
          _HeroTimerCard(),
          const SizedBox(height: 16),
          _StatsRow(counter: state.counter),
          const SizedBox(height: 16),
          _ProgressCard(),
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

class _HeroTimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: s.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time_filled, size: 64, color: s.onPrimary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, User…',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: s.onPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  '1 h 30 m 20 s',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: s.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final int counter;
  const _StatsRow({required this.counter});

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    Widget stat(IconData icon, String label, String value) => Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: s.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );

    return Row(
      children: [
        stat(Icons.calendar_today, 'days quit', '1'),
        const SizedBox(width: 12),
        stat(Icons.smoke_free, 'avoided', '$counter'),
        const SizedBox(width: 12),
        stat(Icons.attach_money, 'saved', '10.000'),
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: s.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quit Plan', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.1,
            color: s.primary,
            backgroundColor: s.surfaceContainerHigh,
            minHeight: 10,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          const SizedBox(height: 8),
          Text('Preparation 0%'),
        ],
      ),
    );
  }
}

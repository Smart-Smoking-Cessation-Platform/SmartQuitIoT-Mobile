import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/widgets/common/question_widget.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final TextEditingController _years = TextEditingController();
  final TextEditingController _packCost = TextEditingController();
  final TextEditingController _cigsPerPack = TextEditingController();
  int _wakeOption = 0;

  @override
  void dispose() {
    _years.dispose();
    _packCost.dispose();
    _cigsPerPack.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Question')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            QuestionWidget(
              question: 'How Long Have You Smoked?',
              child: QuestionCard(
                child: TextField(
                  controller: _years,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Years'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            QuestionWidget(
              question: 'How Much Does It Cost To Buy A Pack Of Cigarettes?',
              child: QuestionCard(
                child: TextField(
                  controller: _packCost,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Price'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            QuestionWidget(
              question: 'How Many Cigarettes In A Pack?',
              child: QuestionCard(
                child: TextField(
                  controller: _cigsPerPack,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: '20'),
                ),
              ),
            ),
            const SizedBox(height: 16),
            QuestionWidget(
              question:
                  'How Soon After Waking Do You Smoke Your First Cigarette?',
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _wakeOptions(scheme),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              child: const Text('Finish'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 10, color: scheme.outlineVariant),
                const SizedBox(width: 6),
                Icon(Icons.circle, size: 10, color: scheme.outlineVariant),
                const SizedBox(width: 6),
                Icon(Icons.circle, size: 10, color: scheme.primary),
                const SizedBox(width: 6),
                Icon(Icons.circle, size: 10, color: scheme.outlineVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _wakeOptions(ColorScheme scheme) {
    final List<String> options = [
      '5 minutes',
      '5-10 minutes',
      '31-60 minutes',
      'Other',
    ];
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: List.generate(options.length, (i) {
          return RadioListTile<int>(
            title: Text(options[i]),
            value: i,
            groupValue: _wakeOption,
            onChanged: (v) => setState(() => _wakeOption = v ?? 0),
          );
        }),
      ),
    );
  }
}

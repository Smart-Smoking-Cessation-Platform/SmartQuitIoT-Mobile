import 'package:SmartQuitIoT/views/screens/questionaires/question_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class QuestionOptionsCard extends StatefulWidget {
  final String question;
  final List<String> options;
  final EdgeInsetsGeometry? margin;

  const QuestionOptionsCard({
    super.key,
    required this.question,
    required this.options,
    this.margin,
  });

  @override
  State<QuestionOptionsCard> createState() => _QuestionOptionsCardState();
}

class _QuestionOptionsCardState extends State<QuestionOptionsCard> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: widget.question,
      margin: widget.margin,
      child: Column(
        children: widget.options.map((option) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Radio<String>(
              value: option,
              groupValue: _selectedValue,
              onChanged: (value) => setState(() => _selectedValue = value),
              activeColor: const Color(0xFF00D09E),
            ),
            title: Text(option),
          );
        }).toList(),
      ),
    );
  }
}
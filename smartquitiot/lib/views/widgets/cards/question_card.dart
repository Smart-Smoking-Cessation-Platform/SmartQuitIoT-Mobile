import 'package:flutter/material.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final Widget child;
  final EdgeInsetsGeometry? margin;

  const QuestionCard({
    super.key,
    required this.question,
    required this.child,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: margin ?? const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class QuestionInputCard extends StatelessWidget {
  final String question;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final EdgeInsetsGeometry? margin;

  const QuestionInputCard({
    super.key,
    required this.question,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: question,
      margin: margin,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.black87, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class QuestionOptionsCard extends StatelessWidget {
  final String question;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final EdgeInsetsGeometry? margin;

  const QuestionOptionsCard({
    super.key,
    required this.question,
    required this.options,
    this.selectedValue,
    this.onChanged,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return QuestionCard(
      question: question,
      margin: margin,
      child: Column(
        children: options.map((option) {
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Radio<String>(
              value: option,
              groupValue: selectedValue,
              onChanged: onChanged,
              activeColor: const Color(0xFF00D09E),
            ),
            title: Text(option),
          );
        }).toList(),
      ),
    );
  }
}

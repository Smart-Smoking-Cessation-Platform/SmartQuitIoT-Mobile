import 'package:SmartQuitIoT/views/screens/questionaires/question_card.dart';
import 'package:flutter/material.dart';

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
          fillColor: const Color(0xFFF9F9F9), // nhạt, không quá chói
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00D09E), width: 1.5),
          ),
        ),
      ),
    );
  }
}
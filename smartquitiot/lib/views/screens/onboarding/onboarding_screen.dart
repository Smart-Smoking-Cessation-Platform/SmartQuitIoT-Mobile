import 'package:SmartQuitIoT/views/screens/questionaires/question_input_card.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/questionaires/question_card.dart';
import 'package:SmartQuitIoT/views/widgets/common/page_indicator.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/primary_button.dart';

import '../questionaires/question_options_card.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: Column(
        children: [
          // Header
          Container(
            height: 90,
            width: double.infinity,
            color: const Color(0xFF00D09E),
            alignment: Alignment.center,
            child: Text(
              _currentIndex == 0
                  ? 'Welcome To SmartQuit'
                  : _currentIndex == 1
                  ? "Let’s Talk About Your Smoking Status"
                  : "Questions",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Nội dung PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              children: [
                // PAGE 1: Welcome
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/images/Group.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Are You Ready To Save Your Life?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // PAGE 2: Let’s Talk
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/images/health.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tell us about your smoking habits so we can help you better.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // PAGE 3: Questions 1
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ListView(
                    children: [
                      QuestionInputCard(
                        question: 'How Long Have You Smoked?',
                        controller: TextEditingController(),
                        hintText: 'Nhập thông tin...',
                      ),
                      QuestionInputCard(
                        question:
                            'How Much Does It Cost To Buy A Pack Of Cigarettes?',
                        controller: TextEditingController(),
                        hintText: 'Nhập thông tin...',
                      ),
                      QuestionInputCard(
                        question: 'How Many Cigarettes In A Pack?',
                        controller: TextEditingController(),
                        hintText: 'Nhập thông tin...',
                      ),
                      QuestionOptionsCard(
                        question:
                            'How Soon After Waking Do You Smoke Your First Cigarette?',
                        options: [
                          '5 minutes',
                          '5–10 minutes',
                          '31–60 minutes',
                          'Other',
                        ],
                      ),
                    ],
                  ),
                ),

                // PAGE 4: Questions 2
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  child: ListView(
                    children: [
                      QuestionOptionsCard(
                        question:
                            'How Many Cigarettes Do You Smoke Per Day On Average?',
                        options: ['1–10', '11–20', '21–30', '30+'],
                      ),
                      QuestionOptionsCard(
                        question:
                            'Do You Find It Difficult To Refrain From Smoking In Places Where It Is Forbidden?',
                        options: ['Yes', 'No'],
                      ),
                      QuestionOptionsCard(
                        question: 'Which Cigarette Would You Hate To Give Up?',
                        options: ['First in the morning', 'Any other'],
                      ),
                      QuestionOptionsCard(
                        question:
                            'Do You Smoke More Frequently In The Morning?',
                        options: ['Yes', 'No'],
                      ),
                      QuestionOptionsCard(
                        question:
                            'Do You Smoke Even If You Are Sick In Bed Most Of The Day?',
                        options: ['Yes', 'No'],
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: 'Finish',
                        onPressed: () {
                          // Navigate sang màn hình chính
                          Navigator.pushNamed(context, '/relaunch');
                        },
                        width: 200,
                        height: 50,
                        borderRadius: 30,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PageIndicator(currentIndex: _currentIndex, totalPages: 4),
          ),
        ],
      ),
    );
  }
}

import 'package:SmartQuitIoT/views/screens/questionaires/question_input_card.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
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
                  ? 'welcome_to_smartquit'.tr()
                  : _currentIndex == 1
                  ? "talk_smoking_status".tr()
                  : "questions".tr(),
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
                      Text(
                        'ready_to_save'.tr(),
                        style: const TextStyle(
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
                      Text(
                        'tell_smoking_habits'.tr(),
                        style: const TextStyle(
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
                        question: 'how_long_smoked'.tr(),
                        controller: TextEditingController(),
                        hintText: 'input_hint'.tr(),
                      ),
                      QuestionInputCard(
                        question: 'cost_per_pack'.tr(),
                        controller: TextEditingController(),
                        hintText: 'input_hint'.tr(),
                      ),
                      QuestionInputCard(
                        question: 'cigarettes_per_pack'.tr(),
                        controller: TextEditingController(),
                        hintText: 'input_hint'.tr(),
                      ),
                      QuestionOptionsCard(
                        question: 'first_cigarette_time'.tr(),
                        options: [
                          '5_minutes'.tr(),
                          '5_10_minutes'.tr(),
                          '31_60_minutes'.tr(),
                          'other'.tr(),
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
                        question: 'cigarettes_per_day'.tr(),
                        options: [
                          '1_10'.tr(),
                          '11_20'.tr(),
                          '21_30'.tr(),
                          '30_plus'.tr(),
                        ],
                      ),
                      QuestionOptionsCard(
                        question: 'difficult_refrain'.tr(),
                        options: ['yes'.tr(), 'no'.tr()],
                      ),
                      QuestionOptionsCard(
                        question: 'hate_to_give_up'.tr(),
                        options: ['first_in_morning'.tr(), 'any_other'.tr()],
                      ),
                      QuestionOptionsCard(
                        question: 'smoke_more_morning'.tr(),
                        options: ['yes'.tr(), 'no'.tr()],
                      ),
                      QuestionOptionsCard(
                        question: 'smoke_even_sick'.tr(),
                        options: ['yes'.tr(), 'no'.tr()],
                      ),
                      const SizedBox(height: 40),
                      PrimaryButton(
                        text: 'finish'.tr(),
                        onPressed: () {
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

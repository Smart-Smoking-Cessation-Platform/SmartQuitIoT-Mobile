import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../models/request/create_quit_plan_request.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../utils/notification_helper.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/page_indicator.dart';
import '../questionaires/question_input_card.dart';
import '../questionaires/question_options_card.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  // Controllers
  final TextEditingController _smokeAvgController = TextEditingController();
  final TextEditingController _yearsController = TextEditingController();
  final TextEditingController _moneyController = TextEditingController();
  final TextEditingController _cigarettesPerPackController =
      TextEditingController();
  final TextEditingController _quitPlanNameController = TextEditingController();
  final TextEditingController _nicotineAmountController = TextEditingController();

  // Options
  int? _selectedFirstCigaretteOptionMinutes;
  bool? _difficultRefrain;
  bool? _hateToGiveUp;
  bool? _smokeMoreMorning;
  bool? _smokeEvenSick;
  bool _useNRT = false;
  final List<String> _selectedInterests = [];

  // Validation flag
  bool _submitted = false;

  // First cigarette options
  final Map<String, int> firstCigaretteOptions = {
    "≤5 minutes": 5,
    "6–30 minutes": 30,
    "31–60 minutes": 60,
    ">60 minutes": 120,
  };

  // Interest options
  final List<String> interestOptions = [
    "All Interests",
    "Sports and Exercise",
    "Art and Creativity",
    "Cooking and Food",
    "Reading, Learning and Writing",
    "Music and Entertainment",
    "Nature and Outdoor Activities",
  ];

  @override
  void initState() {
    super.initState();

    // Format cost input with thousand separator
    _moneyController.addListener(() {
      final text = _moneyController.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final number = int.tryParse(text);
      if (number != null) {
        final formatted = NumberFormat('#,###', 'en_US').format(number);
        if (formatted != _moneyController.text) {
          _moneyController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });

    // Format nicotine amount with thousand separator
    _nicotineAmountController.addListener(() {
      final text = _nicotineAmountController.text.replaceAll(',', '');
      if (text.isEmpty) return;
      final number = double.tryParse(text);
      if (number != null) {
        final formatted = NumberFormat('#,###.##', 'en_US').format(number);
        if (formatted != _nicotineAmountController.text) {
          _nicotineAmountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      }
    });
  }

  /// Validate and return first error page index, -1 if no error
  int _validateAndGetFirstErrorPage() {
    setState(() => _submitted = true);

    // Page 3 errors
    if (_smokeAvgController.text.isEmpty ||
        _yearsController.text.isEmpty ||
        _moneyController.text.isEmpty ||
        _cigarettesPerPackController.text.isEmpty ||
        _nicotineAmountController.text.isEmpty ||
        _selectedFirstCigaretteOptionMinutes == null) {
      return 2;
    }

    // Page 4 errors
    if (_difficultRefrain == null ||
        _hateToGiveUp == null ||
        _smokeMoreMorning == null ||
        _smokeEvenSick == null ||
        _selectedInterests.isEmpty) {
      return 3;
    }

    return -1; // no error
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final quitPlanState = ref.watch(quitPlanViewModelProvider);

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
                  ? 'Welcome to SmartQuit'
                  : _currentIndex == 1
                  ? "Talk Smoking Status"
                  : "Questions",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // PageView
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              children: [
                // Page 1
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/images/Group.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Ready to save your health?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Page 2
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: size.height * 0.3,
                        child: Image.asset('lib/assets/images/health.png'),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Tell us about your smoking habits',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Page 3
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      QuestionInputCard(
                        question: 'Quit plan name',
                        controller: _quitPlanNameController,
                        hintText: 'Enter your plan name',
                        errorText:
                            _submitted && _quitPlanNameController.text.isEmpty
                            ? 'You must enter a name'
                            : null,
                      ),
                      QuestionInputCard(
                        question: 'Average cigarettes smoked per day',
                        controller: _smokeAvgController,
                        hintText: 'Enter number of cigarettes',
                        keyboardType: TextInputType.number,
                        errorText: _submitted && _smokeAvgController.text.isEmpty
                            ? 'You must enter a value'
                            : null,
                      ),
                      QuestionInputCard(
                        question: 'How many years have you smoked?',
                        controller: _yearsController,
                        hintText: 'Enter number of years',
                        keyboardType: TextInputType.number,
                        errorText: _submitted && _yearsController.text.isEmpty
                            ? 'You must enter a value'
                            : null,
                      ),
                      QuestionInputCard(
                        question: 'Cost per cigarette pack',
                        controller: _moneyController,
                        hintText: 'Enter cost',
                        keyboardType: TextInputType.number,
                        errorText: _submitted && _moneyController.text.isEmpty
                            ? 'You must enter a value'
                            : null,
                      ),
                      QuestionInputCard(
                        question: 'Cigarettes per pack',
                        controller: _cigarettesPerPackController,
                        hintText: 'Enter number of cigarettes',
                        keyboardType: TextInputType.number,
                        errorText:
                            _submitted &&
                                _cigarettesPerPackController.text.isEmpty
                            ? 'You must enter a value'
                            : null,
                      ),
                      QuestionInputCard(
                        question: 'Amount of nicotine per cigarette (mg)',
                        controller: _nicotineAmountController,
                        hintText: 'Enter nicotine amount (e.g., 1.2)',
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        errorText:
                            _submitted &&
                                _nicotineAmountController.text.isEmpty
                            ? 'You must enter a value'
                            : null,
                      ),
                      QuestionOptionsCard(
                        question:
                            'How soon after waking do you smoke your first cigarette?',
                        options: firstCigaretteOptions.keys.toList(),
                        onSelected: (option) {
                          setState(() {
                            _selectedFirstCigaretteOptionMinutes =
                                firstCigaretteOptions[option]!;
                          });
                        },
                        errorText:
                            _submitted &&
                                _selectedFirstCigaretteOptionMinutes == null
                            ? 'You must select an option'
                            : null,
                      ),
                    ],
                  ),
                ),

                // Page 4
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ListView(
                    children: [
                      QuestionOptionsCard(
                        question: 'Difficult to refrain in forbidden places?',
                        options: ['Yes', 'No'],
                        onSelected: (option) =>
                            setState(() => _difficultRefrain = option == 'Yes'),
                        errorText: _submitted && _difficultRefrain == null
                            ? 'You must select an option'
                            : null,
                      ),
                      QuestionOptionsCard(
                        question: 'Which cigarette would you hate to give up?',
                        options: ['First in the morning', 'Any other'],
                        onSelected: (option) => setState(
                          () =>
                              _hateToGiveUp = option == 'First in the morning',
                        ),
                        errorText: _submitted && _hateToGiveUp == null
                            ? 'You must select an option'
                            : null,
                      ),
                      QuestionOptionsCard(
                        question:
                            'Do you smoke more frequently in the morning?',
                        options: ['Yes', 'No'],
                        onSelected: (option) =>
                            setState(() => _smokeMoreMorning = option == 'Yes'),
                        errorText: _submitted && _smokeMoreMorning == null
                            ? 'You must select an option'
                            : null,
                      ),
                      QuestionOptionsCard(
                        question: 'Do you smoke even if sick?',
                        options: ['Yes', 'No'],
                        onSelected: (option) =>
                            setState(() => _smokeEvenSick = option == 'Yes'),
                        errorText: _submitted && _smokeEvenSick == null
                            ? 'You must select an option'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Interests
                      const Text(
                        "Select your interests",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: interestOptions.map((option) {
                          final isSelected = _selectedInterests.contains(
                            option,
                          );
                          return FilterChip(
                            label: Text(
                              option,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            selected: isSelected,
                            backgroundColor: Colors.white,
                            selectedColor: const Color(0xFF00D09E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _selectedInterests.add(option);
                                } else {
                                  _selectedInterests.remove(option);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      if (_submitted && _selectedInterests.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: Text(
                            'You must select at least one interest',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Use NRT
                      Row(
                        children: [
                          Checkbox(
                            value: _useNRT,
                            onChanged: (val) =>
                                setState(() => _useNRT = val ?? false),
                          ),
                          const Text("Use Nicotine Replacement Therapy"),
                          const SizedBox(width: 5),
                          const Tooltip(
                            message:
                                "NRT helps reduce withdrawal symptoms by replacing nicotine safely.",
                            child: Icon(Icons.info_outline, size: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // Submit
                      quitPlanState is AsyncLoading
                          ? const Center(child: CircularProgressIndicator())
                          : PrimaryButton(
                              text: 'Finish',
                              onPressed: () async {
                                final errorPage =
                                    _validateAndGetFirstErrorPage();
                                if (errorPage != -1) {
                                  _pageController.animateToPage(
                                    errorPage,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeInOut,
                                  );
                                  NotificationHelper.showTopNotification(
                                    context,
                                    title: "Error",
                                    message:
                                        "Please fix the highlighted errors",
                                    isError: true,
                                  );
                                  return;
                                }

                                final request = CreateQuitPlanRequest(
                                  startDate: DateTime.now().toIso8601String(),
                                  useNRT: _useNRT,
                                  quitPlanName: _quitPlanNameController.text
                                      .trim(),
                                  smokeAvgPerDay:
                                      int.tryParse(_smokeAvgController.text) ??
                                      0,
                                  numberOfYearsOfSmoking:
                                      int.tryParse(_yearsController.text) ?? 0,
                                  moneyPerPackage: double.parse(
                                    _moneyController.text.replaceAll(',', ''),
                                  ),
                                  cigarettesPerPackage:
                                      int.tryParse(
                                        _cigarettesPerPackController.text,
                                      ) ??
                                      0,
                                  minutesAfterWakingToSmoke:
                                      _selectedFirstCigaretteOptionMinutes!,
                                  smokingInForbiddenPlaces: _difficultRefrain!,
                                  cigaretteHateToGiveUp: _hateToGiveUp!,
                                  morningSmokingFrequency: _smokeMoreMorning!,
                                  smokeWhenSick: _smokeEvenSick!,
                                  interests: _selectedInterests,
                                  amountOfNicotinePerCigarettes: double.parse(
                                    _nicotineAmountController.text.replaceAll(',', ''),
                                  ),
                                );

                                try {
                                  await ref
                                      .read(quitPlanViewModelProvider.notifier)
                                      .createPlan(request);

                                  print(
                                    '✅ [OnboardingScreen] Quit plan created successfully',
                                  );

                                  NotificationHelper.showTopNotification(
                                    context,
                                    title: "Success",
                                    message:
                                        "Quit plan \"${_quitPlanNameController.text.trim()}\" created successfully",
                                  );

                                  // Give backend time to initialize phase and missions
                                  print(
                                    '⏳ [OnboardingScreen] Waiting for backend to initialize phase...',
                                  );
                                  await Future.delayed(
                                    const Duration(seconds: 3),
                                  );

                                  // Trigger refresh for quit plan and missions cards
                                  print(
                                    '🔄 [OnboardingScreen] Backend ready, triggering cards refresh...',
                                  );
                                  ref
                                      .read(missionRefreshProvider.notifier)
                                      .refreshAll();

                                  print(
                                    '🚀 [OnboardingScreen] Navigating to main screen...',
                                  );
                                  // Navigate immediately, cards sẽ tự retry nếu chưa sẵn sàng
                                  context.go('/main');
                                } catch (e) {
                                  print(
                                    '❌ [OnboardingScreen] Error creating quit plan: $e',
                                  );
                                  NotificationHelper.showTopNotification(
                                    context,
                                    title: 'Error',
                                    message: e.toString(),
                                    isError: true,
                                  );
                                }
                              },
                              width: 200,
                              height: 50,
                              borderRadius: 30,
                            ),
                      if (quitPlanState is AsyncError)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Error: ${quitPlanState.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Page indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: PageIndicator(currentIndex: _currentIndex, totalPages: 4),
          ),
        ],
      ),
    );
  }
}

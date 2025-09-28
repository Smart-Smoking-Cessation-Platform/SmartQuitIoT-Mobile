import 'package:SmartQuitIoT/views/screens/quitplans/quit_plan_options.dart';
import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/diary/diary_date_selector.dart';
import 'package:SmartQuitIoT/views/widgets/cards/smoking_choice_card.dart';
import 'package:SmartQuitIoT/views/widgets/cards/mood_slider_card.dart';
import 'package:SmartQuitIoT/views/screens/common/home_screen.dart';
class CreateDiaryScreen extends StatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  State<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends State<CreateDiaryScreen> {
  DateTime selectedDate = DateTime.now();
  bool hasSmoked = false;
  int cigarettesSmoked = 0;
  double moneySpent = 0.0;
  double cravingLevel = 5.0;
  double moodLevel = 5.0;
  double confidenceLevel = 5.0;
  double anxietyLevel = 5.0;
  final TextEditingController notesController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Entry Diary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiaryDateSelector(
              selectedDate: selectedDate,
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 24),
            SmokingChoiceCard(
              title: 'Have You Smoked Since Your Last Entry?',
              subtitle: '',
              isSelected: hasSmoked,
              onTap: () {
                setState(() {
                  hasSmoked = !hasSmoked;
                  if (!hasSmoked) {
                    cigarettesSmoked = 0;
                    moneySpent = 0.0;
                  }
                });
              },
            ),
            if (hasSmoked) ...[
              const SizedBox(height: 24),
              _buildSmokingDetails(),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  MoodSliderCard(
                    title: 'Cravings',
                    subtitle: 'How strong was your desire to smoke?',
                    value: cravingLevel,
                    onChanged: (value) => setState(() => cravingLevel = value),
                    icon: Icons.psychology,
                    color: const Color(0xFFE91E63),
                  ),
                  const SizedBox(height: 24),
                  MoodSliderCard(
                    title: 'Mood',
                    subtitle: 'How did you feel today?',
                    value: moodLevel,
                    onChanged: (value) => setState(() => moodLevel = value),
                    icon: Icons.sentiment_satisfied,
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 24),
                  MoodSliderCard(
                    title: 'Confidence Level',
                    subtitle: 'How confident you feel?',
                    value: confidenceLevel,
                    onChanged: (value) =>
                        setState(() => confidenceLevel = value),
                    icon: Icons.psychology_alt,
                    color: const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 24),
                  MoodSliderCard(
                    title: 'Anxiety',
                    subtitle: 'How anxious was anxiety?',
                    value: anxietyLevel,
                    onChanged: (value) => setState(() => anxietyLevel = value),
                    icon: Icons.airline_seat_recline_normal,
                    color: const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Date',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _selectDate(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF00D09E).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Color(0xFF00D09E),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF00D09E)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmokingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Have You Smoked Since Your Last Entry?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      hasSmoked = false;
                      cigarettesSmoked = 0;
                      moneySpent = 0.0;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: !hasSmoked
                          ? const Color(0xFF4CAF50).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: !hasSmoked
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: !hasSmoked
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent,
                            border: Border.all(
                              color: !hasSmoked
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: !hasSmoked
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'No',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: !hasSmoked
                                ? const Color(0xFF4CAF50)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      hasSmoked = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: hasSmoked
                          ? const Color(0xFFE91E63).withOpacity(0.1)
                          : Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasSmoked
                            ? const Color(0xFFE91E63)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: hasSmoked
                                ? const Color(0xFFE91E63)
                                : Colors.transparent,
                            border: Border.all(
                              color: hasSmoked
                                  ? const Color(0xFFE91E63)
                                  : Colors.grey[400]!,
                              width: 2,
                            ),
                          ),
                          child: hasSmoked
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Yes',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: hasSmoked
                                ? const Color(0xFFE91E63)
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmokingDetails() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE91E63).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNumberInput(
            'How Many Did You Smoke?',
            cigarettesSmoked,
            (value) => setState(() => cigarettesSmoked = value),
            Icons.smoke_free,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 24),
          _buildNumberInput(
            'How Much You Spent On NRT Since Last Entry (\$)',
            moneySpent.toInt(),
            (value) => setState(() => moneySpent = value.toDouble()),
            Icons.attach_money,
            const Color(0xFFE91E63),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInput(
    String title,
    int value,
    Function(int) onChanged,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: '0',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            onChanged: (text) {
              final number = int.tryParse(text) ?? 0;
              onChanged(number);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSlider(
            'Cravings',
            'How strong was your desire to smoke?',
            cravingLevel,
            (value) => setState(() => cravingLevel = value),
            Icons.psychology,
            const Color(0xFFE91E63),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            'Mood',
            'How did you feel today?',
            moodLevel,
            (value) => setState(() => moodLevel = value),
            Icons.sentiment_satisfied,
            const Color(0xFF2196F3),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            'Confidence Level',
            'How confident you feel?',
            confidenceLevel,
            (value) => setState(() => confidenceLevel = value),
            Icons.psychology_alt,
            const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 24),
          _buildSlider(
            'Anxiety',
            'How anxious was anxiety?',
            anxietyLevel,
            (value) => setState(() => anxietyLevel = value),
            Icons.airline_seat_recline_normal,
            const Color(0xFFFF9800),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String title,
    String subtitle,
    double value,
    Function(double) onChanged,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('1', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            Expanded(
              child: Slider(
                value: value,
                min: 1.0,
                max: 10.0,
                divisions: 90,
                activeColor: color,
                inactiveColor: color.withOpacity(0.2),
                thumbColor: color,
                onChanged: onChanged,
              ),
            ),
            Text('10', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notes,
                  color: Color(0xFF9C27B0),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Notes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // 👇 nền trắng hoàn toàn
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              // 👇 viền xám nhẹ
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: TextField(
              controller: notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 14, color: Color(0xFF2D3748)),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter notes...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          padding: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF00D09E).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            const Text(
              'Save',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00D09E),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _saveDiary() {
      // Show success and go back to HomeScreen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Diary saved successfully!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      // Navigate to HomeScreen and remove all previous routes
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false, // This predicate removes all routes
      );
    }
  }




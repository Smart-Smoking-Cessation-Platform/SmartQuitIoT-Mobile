import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:intl/intl.dart';

class CreateDiaryScreen extends ConsumerStatefulWidget {
  const CreateDiaryScreen({super.key});

  @override
  ConsumerState<CreateDiaryScreen> createState() => _CreateDiaryScreenState();
}

class _CreateDiaryScreenState extends ConsumerState<CreateDiaryScreen> {
  DateTime selectedDate = DateTime.now();
  bool hasSmoked = false;
  int cigarettesSmoked = 0;
  double cravingLevel = 5.0;
  double moodLevel = 5.0;
  double confidenceLevel = 5.0;
  double anxietyLevel = 5.0;
  final NumberFormat currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'VND',
    decimalDigits: 0,
  );

  // Triggers
  List<String> selectedTriggers = [];
  final List<String> availableTriggers = [
    "Morning",
    "After Meal",
    "Gaming",
    "Party",
    "Coffee",
    "Stress",
    "Boredom",
    "Driving",
    "Sadness",
    "Work",
  ];

  // NRT
  bool isUseNrt = false;
  double moneySpentOnNrt = 0.0;

  // IoT Data
  bool isConnectIoTDevice = false;
  int steps = 0;
  int heartRate = 0;
  int spo2 = 0;
  int activityMinutes = 0;
  int respiratoryRate = 0;
  double sleepDuration = 0.0;
  int sleepQuality = 5;
  final TextEditingController notesController = TextEditingController();
  final TextEditingController moneyController = TextEditingController();

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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date Selector
              _buildDateSelector(),
              const SizedBox(height: 20),

              // Smoking Status
              _buildSmokingSection(),
              const SizedBox(height: 20),

              // Mood Sliders
              _buildMoodSection(),
              const SizedBox(height: 20),

              // Triggers
              _buildTriggersSection(),
              const SizedBox(height: 20),

              // NRT
              _buildNrtSection(),
              const SizedBox(height: 20),

              // IoT Data
              _buildIoTSection(),
              const SizedBox(height: 20),

              // Notes
              _buildNotesSection(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF00D09E)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF00D09E)),
            const SizedBox(width: 12),
            Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF00D09E)),
          ],
        ),
      ),
    );
  }

  Widget _buildSmokingSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Did You Smoke Today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildChoiceButton('No', !hasSmoked, () {
                  setState(() {
                    hasSmoked = false;
                    cigarettesSmoked = 0;
                  });
                }),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceButton('Yes', hasSmoked, () {
                  setState(() => hasSmoked = true);
                }),
              ),
            ],
          ),
          if (hasSmoked) ...[
            const SizedBox(height: 20),
            const Text(
              'How many cigarettes?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  cigarettesSmoked = int.tryParse(value) ?? 0;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoiceButton(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D09E) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00D09E) : Colors.grey[300]!,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            cravingLevel,
            const Color(0xFFE91E63),
            (v) => setState(() => cravingLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Mood',
            moodLevel,
            const Color(0xFF2196F3),
            (v) => setState(() => moodLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Confidence',
            confidenceLevel,
            const Color(0xFF4CAF50),
            (v) => setState(() => confidenceLevel = v),
          ),
          const Divider(height: 32),
          _buildSlider(
            'Anxiety',
            anxietyLevel,
            const Color(0xFFFF9800),
            (v) => setState(() => anxietyLevel = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    Color color,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              '${value.round()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 10,
          divisions: 10,
          activeColor: color,
          inactiveColor: color.withOpacity(0.2),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTriggersSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Triggers',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableTriggers.map((trigger) {
              final isSelected = selectedTriggers.contains(trigger);
              return InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedTriggers.remove(trigger);
                    } else {
                      selectedTriggers.add(trigger);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00D09E)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00D09E)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    trigger,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNrtSection() {
    final moneyController = TextEditingController(
      text: moneySpentOnNrt > 0
          ? currencyFormatter.format(moneySpentOnNrt)
          : '',
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Using NRT?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Switch(
                value: isUseNrt,
                activeColor: const Color(0xFF00D09E),
                onChanged: (value) {
                  setState(() {
                    isUseNrt = value;
                    if (!value) moneySpentOnNrt = 0.0;
                  });
                },
              ),
            ],
          ),
          if (isUseNrt) ...[
            const SizedBox(height: 12),
            const Text(
              'Money spent on NRT',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: moneyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                // Loại bỏ ký tự không phải số
                final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');
                final parsed = double.tryParse(numericString) ?? 0;
                setState(() {
                  moneySpentOnNrt = parsed;
                  // Cập nhật lại controller với format VND
                  moneyController.value = TextEditingValue(
                    text: parsed == 0 ? '' : currencyFormatter.format(parsed),
                    selection: TextSelection.collapsed(
                      offset: parsed == 0
                          ? 0
                          : currencyFormatter.format(parsed).length,
                    ),
                  );
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIoTSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Health Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getDataFromIoT,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.bluetooth, color: Colors.white, size: 20),
              label: const Text(
                'Connect IOT device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (isConnectIoTDevice) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  _buildDataRow('Steps', '$steps', Icons.directions_walk),
                  _buildDataRow('Heart Rate', '$heartRate bpm', Icons.favorite),
                  _buildDataRow('SpO2', '$spo2%', Icons.healing),
                  _buildDataRow(
                    'Active Minutes',
                    '$activityMinutes min',
                    Icons.fitness_center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'How are you feeling today?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveDiary,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00D09E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Save Diary',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  void _getDataFromIoT() {
    setState(() {
      steps = 8500;
      heartRate = 72;
      spo2 = 98;
      activityMinutes = 45;
      respiratoryRate = 16;
      sleepDuration = 7.5;
      sleepQuality = 8;
      isConnectIoTDevice = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Health data synced successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _saveDiary() async {
    final diaryNotifier = ref.read(diaryRecordNotifierProvider.notifier);

    final request = DiaryRecordRequest(
      date: selectedDate.toIso8601String().split('T')[0],
      haveSmoked: hasSmoked,
      cigarettesSmoked: cigarettesSmoked,
      triggers: selectedTriggers,
      isUseNrt: isUseNrt,
      moneySpentOnNrt: moneySpentOnNrt,
      cravingLevel: cravingLevel.round(),
      moodLevel: moodLevel.round(),
      confidenceLevel: confidenceLevel.round(),
      anxietyLevel: anxietyLevel.round(),
      note: notesController.text,
      isConnectIoTDevice: isConnectIoTDevice,
      steps: steps,
      heartRate: heartRate,
      spo2: spo2,
      activityMinutes: activityMinutes,
      respiratoryRate: respiratoryRate,
      sleepDuration: sleepDuration,
      sleepQuality: sleepQuality,
    );

    await diaryNotifier.createDiaryRecord(request);

    if (mounted) {
      final state = ref.read(diaryRecordNotifierProvider);
      state.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Diary saved successfully!'),
              backgroundColor: Color(0xFF4CAF50),
            ),
          );
          Navigator.popUntil(context, (route) {
            return route.settings.name == '/main';
          });
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: const Color(0xFFE53E3E),
            ),
          );
        },
      );
    }
  }
}

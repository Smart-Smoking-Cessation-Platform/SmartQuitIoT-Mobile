import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/providers/diary_refresh_provider.dart';
import 'package:SmartQuitIoT/models/diary_record.dart';
import 'package:intl/intl.dart';
import 'package:health/health.dart';

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
  
  // Health instance
  final Health _health = Health();
  
  // Money formatter without VND symbol (dấu phẩy)
  final NumberFormat moneyFormatter = NumberFormat('#,###', 'en_US');

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
  
  // Health data controllers
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController heartRateController = TextEditingController();
  final TextEditingController spo2Controller = TextEditingController();
  final TextEditingController activityMinutesController = TextEditingController();
  final TextEditingController respiratoryRateController = TextEditingController();
  final TextEditingController sleepDurationController = TextEditingController();
  final TextEditingController sleepQualityController = TextEditingController();

  @override
  void dispose() {
    notesController.dispose();
    moneyController.dispose();
    stepsController.dispose();
    heartRateController.dispose();
    spo2Controller.dispose();
    activityMinutesController.dispose();
    respiratoryRateController.dispose();
    sleepDurationController.dispose();
    sleepQualityController.dispose();
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            'Today: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Icon(Icons.lock, color: Colors.grey[500], size: 20),
        ],
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
    final localMoneyController = TextEditingController(
      text: moneySpentOnNrt > 0
          ? moneyFormatter.format(moneySpentOnNrt)
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
                activeThumbColor: const Color(0xFF00D09E),
                onChanged: (value) {
                  setState(() {
                    isUseNrt = value;
                    if (!value) {
                      moneySpentOnNrt = 0.0;
                      moneyController.clear();
                    }
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
                if (numericString.isEmpty) {
                  setState(() {
                    moneySpentOnNrt = 0.0;
                  });
                  return;
                }
                final parsed = int.tryParse(numericString) ?? 0;
                final formatted = moneyFormatter.format(parsed);
                
                // Chỉ update khi format khác với text hiện tại
                if (formatted != value) {
                  setState(() {
                    moneySpentOnNrt = parsed.toDouble();
                  });
                  
                  // Tính toán cursor position
                  final cursorPosition = formatted.length;
                  moneyController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: cursorPosition),
                  );
                } else {
                  setState(() {
                    moneySpentOnNrt = parsed.toDouble();
                  });
                }
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
          const SizedBox(height: 16),
          // Health data input fields
          _buildHealthDataFields(),
        ],
      ),
    );
  }

  Widget _buildHealthDataFields() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildHealthField(
                'Steps',
                stepsController,
                Icons.directions_walk,
                (value) => steps = int.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthField(
                'Heart Rate (bpm)',
                heartRateController,
                Icons.favorite,
                (value) => heartRate = int.tryParse(value) ?? 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthField(
                'SpO2 (%)',
                spo2Controller,
                Icons.healing,
                (value) => spo2 = int.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthField(
                'Activity (min)',
                activityMinutesController,
                Icons.fitness_center,
                (value) => activityMinutes = int.tryParse(value) ?? 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildHealthField(
                'Respiratory Rate',
                respiratoryRateController,
                Icons.air,
                (value) => respiratoryRate = int.tryParse(value) ?? 0,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildHealthField(
                'Sleep Duration (h)',
                sleepDurationController,
                Icons.bedtime,
                (value) => sleepDuration = double.tryParse(value) ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildHealthField(
          'Sleep Quality (1-10)',
          sleepQualityController,
          Icons.star,
          (value) => sleepQuality = int.tryParse(value) ?? 5,
        ),
      ],
    );
  }

  Widget _buildHealthField(
    String label,
    TextEditingController controller,
    IconData icon,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: const Color(0xFF00D09E)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3748),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
          ),
          onChanged: onChanged,
        ),
      ],
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


  // Future<void> _getDataFromIoT() async {
  //   try {
  //     // Request health permissions
  //     final types = [
  //       HealthDataType.STEPS,
  //       HealthDataType.HEART_RATE,
  //       HealthDataType.RESPIRATORY_RATE,
  //       HealthDataType.ACTIVE_ENERGY_BURNED,
  //     ];
      
  //     final permissions = types.map((e) => HealthDataAccess.READ).toList();
  //     bool? granted = await _health.requestAuthorization(types, permissions: permissions);
      
  //     if (granted != true) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Health permissions denied. Please enable in settings.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       return;
  //     }

  //     // Fetch health data for today
  //     final now = DateTime.now();
  //     final startOfDay = DateTime(now.year, now.month, now.day);
      
  //     final healthData = await _health.getHealthDataFromTypes(
  //       types: types,
  //       startTime: startOfDay,
  //       endTime: now,
  //     );

  //     // Process and update health data
  //     int fetchedSteps = 0;
  //     int fetchedHeartRate = 0;
  //     int fetchedRespiratoryRate = 0;
  //     int fetchedActivityMinutes = 0;

  //     for (var data in healthData) {
  //       final value = (data.value as NumericHealthValue).numericValue;
        
  //       switch (data.type) {
  //         case HealthDataType.STEPS:
  //           fetchedSteps += value.toInt();
  //           break;
  //         case HealthDataType.HEART_RATE:
  //           if (fetchedHeartRate == 0 || data.dateTo.isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
  //             fetchedHeartRate = value.toInt();
  //           }
  //           break;
  //         case HealthDataType.RESPIRATORY_RATE:
  //           if (fetchedRespiratoryRate == 0) {
  //             fetchedRespiratoryRate = value.toInt();
  //           }
  //           break;
  //         case HealthDataType.ACTIVE_ENERGY_BURNED:
  //           fetchedActivityMinutes = (value / 5).toInt(); // Rough conversion
  //           break;
  //         default:
  //           // Handle other health data types
  //           break;
  //       }
  //     }

  //     setState(() {
  //       steps = fetchedSteps > 0 ? fetchedSteps : 0; // Fallback to sample data
  //       heartRate = fetchedHeartRate > 0 ? fetchedHeartRate : 0;
  //       spo2 = 0; // Not available in Health API, use default
  //       activityMinutes = fetchedActivityMinutes > 0 ? fetchedActivityMinutes : 0;
  //       respiratoryRate = fetchedRespiratoryRate > 0 ? fetchedRespiratoryRate : 0;
  //       sleepDuration = 0; // Not available in basic Health API
  //       sleepQuality = 0; // Not available in basic Health API
  //       isConnectIoTDevice = true;
        
  //       // Update text controllers
  //       stepsController.text = steps.toString();
  //       heartRateController.text = heartRate.toString();
  //       spo2Controller.text = spo2.toString();
  //       activityMinutesController.text = activityMinutes.toString();
  //       respiratoryRateController.text = respiratoryRate.toString();
  //       sleepDurationController.text = sleepDuration.toString();
  //       sleepQualityController.text = sleepQuality.toString();
  //     });

  //     _showFlushBar(
  //       message: 'Health data synced successfully!',
  //       backgroundColor: Color(0xFF00D09E),
  //       icon: Icons.check_circle,
  //     );
  //   } catch (e) {
  //     print('Error fetching health data: $e');
  //     _showFlushBar(
  //       message: 'Failed to sync health data: ${e.toString()}',
  //       backgroundColor: Colors.redAccent,
  //       icon: Icons.error_outline,
  //     );
  //   }
  // }

  Future<void> _getDataFromIoT() async {
  try {
    // Request health permissions
    final types = [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.RESPIRATORY_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.BASAL_ENERGY_BURNED,  
      
    ];

    final permissions = types.map((e) => HealthDataAccess.READ).toList();
    bool? granted = await _health.requestAuthorization(types, permissions: permissions);

    if (granted != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health permissions denied. Please enable in settings.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Fetch health data for today
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final healthData = await _health.getHealthDataFromTypes(
      types: types,
      startTime: startOfDay,
      endTime: now,
    );

    // Process and update health data
    int fetchedSteps = 0;
    int fetchedHeartRate = 0;
    int fetchedRespiratoryRate = 0;
    int fetchedActivityMinutes = 0;
    double totalSleepMinutes = 0;
    double deepSleepMinutes = 0;
    double remSleepMinutes = 0;
    double totalSleepSessionMinutes = 0;

    for (var data in healthData) {
      final value = (data.value is NumericHealthValue)
          ? ((data.value as NumericHealthValue).numericValue ?? 0.0)
          : 0.0;

      switch (data.type) {
        case HealthDataType.STEPS:
          fetchedSteps += value.toInt();
          break;

        case HealthDataType.HEART_RATE:
          // Lấy nhịp tim gần nhất hoặc trung bình
          if (fetchedHeartRate == 0 ||
              data.dateTo.isAfter(DateTime.now().subtract(const Duration(hours: 1)))) {
            fetchedHeartRate = value.toInt();
          }
          break;

        case HealthDataType.RESPIRATORY_RATE:
          if (fetchedRespiratoryRate == 0) {
            fetchedRespiratoryRate = value.toInt();
          }
          break;

        case HealthDataType.ACTIVE_ENERGY_BURNED:
          // Ước lượng phút hoạt động (trung bình ~6 kcal/phút)
          fetchedActivityMinutes += (value / 6).round();
          break;

        case HealthDataType.SLEEP_ASLEEP:
        case HealthDataType.SLEEP_DEEP:
        case HealthDataType.SLEEP_REM:
        case HealthDataType.SLEEP_LIGHT:
          totalSleepMinutes += data.dateTo.difference(data.dateFrom).inMinutes.toDouble();
          if (data.type == HealthDataType.SLEEP_DEEP) {
            deepSleepMinutes += data.dateTo.difference(data.dateFrom).inMinutes.toDouble();
          }
          if (data.type == HealthDataType.SLEEP_REM) {
            remSleepMinutes += data.dateTo.difference(data.dateFrom).inMinutes.toDouble();
          }
          break;

        case HealthDataType.SLEEP_SESSION:
          totalSleepSessionMinutes += data.dateTo.difference(data.dateFrom).inMinutes.toDouble();
          break;

        default:
          break;
      }
    }

    // ✅ Tính toán sleep metrics
    double sleepDuration = totalSleepMinutes > 0 ? totalSleepMinutes / 60.0 : 0; // giờ
    double sleepQuality = 0;
    if (totalSleepMinutes > 0) {
      sleepQuality = ((deepSleepMinutes + remSleepMinutes) / totalSleepMinutes) * 100;
    }

    // Cập nhật UI
    setState(() {
      steps = fetchedSteps > 0 ? fetchedSteps : 0;
      heartRate = fetchedHeartRate > 0 ? fetchedHeartRate : 0;
      spo2 = 0; // ❌ Health API không cung cấp
      activityMinutes = fetchedActivityMinutes > 0 ? fetchedActivityMinutes : 0;
      respiratoryRate = fetchedRespiratoryRate > 0 ? fetchedRespiratoryRate : 0;
      sleepDuration = sleepDuration > 0 ? sleepDuration : 0;
      sleepQuality = sleepQuality > 0 ? sleepQuality : 0;
      isConnectIoTDevice = true;

      // Update text controllers
      stepsController.text = steps.toString();
      heartRateController.text = heartRate.toString();
      spo2Controller.text = spo2.toString();
      activityMinutesController.text = activityMinutes.toString();
      respiratoryRateController.text = respiratoryRate.toString();
      sleepDurationController.text = sleepDuration.toStringAsFixed(1);
      sleepQualityController.text = sleepQuality.toStringAsFixed(1);
    });

    _showFlushBar(
      message: 'Health data synced successfully!',
      backgroundColor: const Color(0xFF00D09E),
      icon: Icons.check_circle,
    );
  } catch (e) {
    print('Error fetching health data: $e');
    _showFlushBar(
      message: 'Failed to sync health data: ${e.toString()}',
      backgroundColor: Colors.redAccent,
      icon: Icons.error_outline,
    );
  }
}

  
  void _showFlushBar({
  required String message,
  Color backgroundColor = const Color(0xFF00D09E),
  IconData icon = Icons.check_circle,
  Duration duration = const Duration(seconds: 3),
}) {
  Flushbar(
    message: message,
    icon: Icon(icon, size: 28, color: Colors.white),
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: backgroundColor,
    duration: duration,
    flushbarPosition: FlushbarPosition.TOP,
    forwardAnimationCurve: Curves.easeOutBack,
    reverseAnimationCurve: Curves.easeIn,
    boxShadows: [
      BoxShadow(
        color: backgroundColor.withOpacity(0.4),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  ).show(context);
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

    if (!mounted) return;
    
    final state = ref.read(diaryRecordNotifierProvider);
    state.whenOrNull(
      data: (_) {
        // Trigger metrics refresh after successful diary creation
        ref.read(metricsRefreshProvider.notifier).refreshMetrics();
        
        // Trigger diary charts refresh to update analytics
        ref.read(diaryChartsRefreshProvider.notifier).refreshCharts();
        
        // Trigger diary history refresh to update history list
        ref.read(diaryRefreshProvider.notifier).refreshDiaryHistory();
        print('✅ [CreateDiary] Triggered diary history refresh');
        
        if (!mounted) return;
        
        // Show success flushbar
        Flushbar(
          message: '🎉 Diary saved successfully!',
          icon: const Icon(Icons.check_circle, size: 28, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
          flushbarPosition: FlushbarPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeIn,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          onStatusChanged: (status) {
            // Navigate back after flushbar is dismissed
            if (status == FlushbarStatus.DISMISSED && mounted) {
              Navigator.of(context).pop();
            }
          },
        ).show(context);
      },
      error: (error, _) {
        if (!mounted) return;
        
        // Show error flushbar
        Flushbar(
          message: error.toString(),
          icon: const Icon(Icons.error_outline, size: 28, color: Colors.white),
          margin: const EdgeInsets.all(16),
          borderRadius: BorderRadius.circular(16),
          backgroundColor: const Color(0xFFE53E3E),
          duration: const Duration(seconds: 4),
          flushbarPosition: FlushbarPosition.TOP,
          forwardAnimationCurve: Curves.easeOutBack,
          reverseAnimationCurve: Curves.easeIn,
          boxShadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ).show(context);
      },
    );
  }
}

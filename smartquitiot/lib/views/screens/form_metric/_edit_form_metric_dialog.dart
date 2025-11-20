import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../models/response/form_metric_response.dart';

// Custom formatter for money input
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,###', 'vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit characters (including commas)
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // If no digits, return empty
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Parse and format with commas
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    // Keep cursor at the end
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class EditFormMetricDialog extends StatefulWidget {
  final FormMetricDTO currentData;

  const EditFormMetricDialog({super.key, required this.currentData});

  @override
  State<EditFormMetricDialog> createState() => _EditFormMetricDialogState();
}

class _EditFormMetricDialogState extends State<EditFormMetricDialog> {
  // Controllers
  late TextEditingController _smokeAvgController;
  late TextEditingController _yearsSmokingController;
  late TextEditingController _minutesAfterWakingController;
  late TextEditingController _cigarettesPerPackageController;
  late TextEditingController _moneyPerPackageController;
  late TextEditingController _nicotineAmountController;

  // Interests options
  final List<String> _availableInterests = [
    'All Interests',
    'Sports and Exercise',
    'Art and Creativity',
    'Cooking and Food',
    'Reading, Learning and Writing',
    'Music and Entertainment',
    'Nature and Outdoor Activities',
  ];

  // Triggers options
  final List<String> _availableTriggers = [
    'Morning',
    'After Meal',
    'Gaming',
    'Party',
    'Coffee',
    'Stress',
    'Boredom',
    'Driving',
    'Sadness',
    'Work',
  ];

  // Selected values
  late List<String> _selectedInterests;
  late List<String> _selectedTriggers;
  late bool _smokingInForbiddenPlaces;
  late bool _cigaretteHateToGiveUp;
  late bool _morningSmokingFrequency;
  late bool _smokeWhenSick;

  @override
  void initState() {
    super.initState();

    // Initialize controllers
    _smokeAvgController = TextEditingController(
      text: widget.currentData.smokeAvgPerDay.toString(),
    );
    _yearsSmokingController = TextEditingController(
      text: widget.currentData.numberOfYearsOfSmoking.toString(),
    );
    _minutesAfterWakingController = TextEditingController(
      text: widget.currentData.minutesAfterWakingToSmoke.toString(),
    );
    _cigarettesPerPackageController = TextEditingController(
      text: widget.currentData.cigarettesPerPackage.toString(),
    );

    // Format money with comma separator
    final formattedMoney = NumberFormat(
      '#,###',
      'vi_VN',
    ).format(widget.currentData.moneyPerPackage);
    _moneyPerPackageController = TextEditingController(text: formattedMoney);

    _nicotineAmountController = TextEditingController(
      text: widget.currentData.amountOfNicotinePerCigarettes.toString(),
    );

    // Initialize selections and filter out empty strings
    _selectedInterests = widget.currentData.interests
        .where((interest) => interest.isNotEmpty && interest.trim().isNotEmpty)
        .map((interest) => interest.trim())
        .toList();
    _selectedTriggers = widget.currentData.triggered
        .where((trigger) => trigger.isNotEmpty && trigger.trim().isNotEmpty)
        .map((trigger) => trigger.trim())
        .toList();
    _smokingInForbiddenPlaces = widget.currentData.smokingInForbiddenPlaces;
    _cigaretteHateToGiveUp = widget.currentData.cigaretteHateToGiveUp;
    _morningSmokingFrequency = widget.currentData.morningSmokingFrequency;
    _smokeWhenSick = widget.currentData.smokeWhenSick;
  }

  @override
  void dispose() {
    _smokeAvgController.dispose();
    _yearsSmokingController.dispose();
    _minutesAfterWakingController.dispose();
    _cigarettesPerPackageController.dispose();
    _moneyPerPackageController.dispose();
    _nicotineAmountController.dispose();
    super.dispose();
  }

  bool _validateFields() {
    // Validate all required fields
    if (_smokeAvgController.text.trim().isEmpty) {
      _showError('Please enter average cigarettes per day');
      return false;
    }
    if (_yearsSmokingController.text.trim().isEmpty) {
      _showError('Please enter years of smoking');
      return false;
    }
    if (_minutesAfterWakingController.text.trim().isEmpty) {
      _showError('Please enter minutes after waking');
      return false;
    }
    if (_cigarettesPerPackageController.text.trim().isEmpty) {
      _showError('Please enter cigarettes per package');
      return false;
    }
    if (_moneyPerPackageController.text.trim().isEmpty) {
      _showError('Please enter money per package');
      return false;
    }
    if (_nicotineAmountController.text.trim().isEmpty) {
      _showError('Please enter nicotine amount');
      return false;
    }
    if (_selectedInterests.isEmpty) {
      _showError('Please select at least one interest');
      return false;
    }
    if (_selectedTriggers.isEmpty) {
      _showError('Please select at least one trigger');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSave() {
    // Validate first
    if (!_validateFields()) {
      return;
    }

    // Debug: Log selected triggers and interests before saving
    debugPrint(
      '🔍 [EditFormMetricDialog] Selected triggers: $_selectedTriggers',
    );
    debugPrint(
      '🔍 [EditFormMetricDialog] Selected triggers count: ${_selectedTriggers.length}',
    );
    debugPrint(
      '🔍 [EditFormMetricDialog] Selected interests: $_selectedInterests',
    );
    debugPrint(
      '🔍 [EditFormMetricDialog] Selected interests count: ${_selectedInterests.length}',
    );

    // Ensure triggers and interests are not empty (validation should have caught this, but double-check)
    if (_selectedTriggers.isEmpty) {
      _showError('Please select at least one trigger');
      return;
    }
    if (_selectedInterests.isEmpty) {
      _showError('Please select at least one interest');
      return;
    }

    // Parse money - strip any non-digit characters before parsing
    final moneyText = _moneyPerPackageController.text.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    // Create new lists and filter out empty strings/null values
    final triggersList = _selectedTriggers
        .where((trigger) => trigger.isNotEmpty && trigger.trim().isNotEmpty)
        .map((trigger) => trigger.trim())
        .toList();
    final interestsList = _selectedInterests
        .where((interest) => interest.isNotEmpty && interest.trim().isNotEmpty)
        .map((interest) => interest.trim())
        .toList();

    debugPrint(
      '🔍 [EditFormMetricDialog] Triggers list to save: $triggersList',
    );
    debugPrint(
      '🔍 [EditFormMetricDialog] Interests list to save: $interestsList',
    );

    // Double-check: ensure no empty strings
    if (triggersList.any((t) => t.isEmpty)) {
      _showError('Invalid triggers detected. Please try again.');
      return;
    }
    if (interestsList.any((i) => i.isEmpty)) {
      _showError('Invalid interests detected. Please try again.');
      return;
    }

    final updatedData = FormMetricDTO(
      id: widget.currentData.id,
      smokeAvgPerDay:
          int.tryParse(_smokeAvgController.text) ??
          widget.currentData.smokeAvgPerDay,
      numberOfYearsOfSmoking:
          int.tryParse(_yearsSmokingController.text) ??
          widget.currentData.numberOfYearsOfSmoking,
      minutesAfterWakingToSmoke:
          int.tryParse(_minutesAfterWakingController.text) ??
          widget.currentData.minutesAfterWakingToSmoke,
      cigarettesPerPackage:
          int.tryParse(_cigarettesPerPackageController.text) ??
          widget.currentData.cigarettesPerPackage,
      moneyPerPackage:
          double.tryParse(moneyText) ?? widget.currentData.moneyPerPackage,
      amountOfNicotinePerCigarettes:
          double.tryParse(_nicotineAmountController.text) ??
          widget.currentData.amountOfNicotinePerCigarettes,
      smokingInForbiddenPlaces: _smokingInForbiddenPlaces,
      cigaretteHateToGiveUp: _cigaretteHateToGiveUp,
      morningSmokingFrequency: _morningSmokingFrequency,
      smokeWhenSick: _smokeWhenSick,
      estimatedMoneySavedOnPlan: widget.currentData.estimatedMoneySavedOnPlan,
      estimatedNicotineIntakePerDay:
          widget.currentData.estimatedNicotineIntakePerDay,
      interests: interestsList,
      triggered: triggersList,
    );

    debugPrint(
      '🔍 [EditFormMetricDialog] Updated data triggers: ${updatedData.triggered}',
    );
    debugPrint(
      '🔍 [EditFormMetricDialog] Updated data interests: ${updatedData.interests}',
    );

    Navigator.pop(context, updatedData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Edit Form Metric',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _handleSave,
            icon: const Icon(Icons.check, color: Colors.white),
            label: const Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smoking Habits Section
            _buildSectionTitle('Smoking Habits', Icons.smoking_rooms),
            const SizedBox(height: 16),
            _buildTextField(
              'Average Cigarettes Per Day',
              _smokeAvgController,
              Icons.smoking_rooms,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Years of Smoking',
              _yearsSmokingController,
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Minutes After Waking',
              _minutesAfterWakingController,
              Icons.access_time,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Cigarettes Per Package',
              _cigarettesPerPackageController,
              Icons.inventory_2,
            ),

            const SizedBox(height: 24),

            // Financial Section
            _buildSectionTitle('Financial Information', Icons.money),
            const SizedBox(height: 16),
            _buildMoneyTextField(
              'Money Per Package',
              _moneyPerPackageController,
              Icons.money,
            ),

            const SizedBox(height: 24),

            // Nicotine Section
            _buildSectionTitle('Nicotine Information', Icons.water_drop),
            const SizedBox(height: 16),
            _buildTextField(
              'Nicotine Per Cigarette (mg)',
              _nicotineAmountController,
              Icons.water_drop,
            ),

            const SizedBox(height: 24),

            // Smoking Behaviors
            _buildSectionTitle('Smoking Behaviors', Icons.psychology),
            const SizedBox(height: 16),
            _buildSwitchTile(
              'Smoking in Forbidden Places',
              _smokingInForbiddenPlaces,
              (value) => setState(() => _smokingInForbiddenPlaces = value),
              Icons.location_off,
            ),
            _buildRadioSelection(
              'Cigarette Hate to Give Up',
              _cigaretteHateToGiveUp,
              Icons.favorite,
            ),
            _buildSwitchTile(
              'Morning Smoking Frequency',
              _morningSmokingFrequency,
              (value) => setState(() => _morningSmokingFrequency = value),
              Icons.wb_sunny,
            ),
            _buildSwitchTile(
              'Smoke When Sick',
              _smokeWhenSick,
              (value) => setState(() => _smokeWhenSick = value),
              Icons.medical_services,
            ),

            const SizedBox(height: 24),

            // Interests Selection
            _buildSectionTitle('Your Interests', Icons.interests),
            const SizedBox(height: 12),
            _buildMultiSelectSection(
              _availableInterests,
              _selectedInterests,
              const Color(0xFF00B386),
            ),

            const SizedBox(height: 24),

            // Triggers Selection
            _buildSectionTitle('Smoking Triggers', Icons.warning_amber),
            const SizedBox(height: 12),
            _buildMultiSelectSection(
              _availableTriggers,
              _selectedTriggers,
              const Color(0xFFFF6B6B),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF00D09E), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00D09E)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [ThousandsSeparatorInputFormatter()],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF00D09E)),
          hintText: 'e.g., 20,000',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
        secondary: Icon(icon, color: const Color(0xFF00D09E)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF00D09E),
      ),
    );
  }

  Widget _buildRadioSelection(String title, bool currentValue, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF00D09E)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Radio Options
          RadioListTile<bool>(
            title: const Row(
              children: [
                Icon(Icons.wb_sunny, size: 20, color: Color(0xFF00D09E)),
                SizedBox(width: 8),
                Text(
                  'The first in the morning',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            value: true,
            groupValue: currentValue,
            activeColor: const Color(0xFF00D09E),
            onChanged: (value) {
              setState(() {
                _cigaretteHateToGiveUp = value!;
              });
            },
          ),
          RadioListTile<bool>(
            title: const Row(
              children: [
                Icon(Icons.schedule, size: 20, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Any other',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            value: false,
            groupValue: currentValue,
            activeColor: Colors.orange,
            onChanged: (value) {
              setState(() {
                _cigaretteHateToGiveUp = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectSection(
    List<String> options,
    List<String> selected,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((option) {
          final isSelected = selected.contains(option);
          return FilterChip(
            label: Text(option),
            selected: isSelected,
            onSelected: (value) {
              setState(() {
                if (value) {
                  selected.add(option);
                } else {
                  selected.remove(option);
                }
              });
            },
            backgroundColor: Colors.grey.shade100,
            selectedColor: color.withOpacity(0.2),
            checkmarkColor: color,
            labelStyle: TextStyle(
              color: isSelected ? color : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          );
        }).toList(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:logger/logger.dart';
import 'package:go_router/go_router.dart';
import '../../../viewmodels/form_metric_view_model.dart';
import '../../../models/request/update_form_metric_request.dart';
import '../../../models/response/form_metric_response.dart';
import '_edit_form_metric_dialog.dart';
import '_create_new_quit_plan_dialog.dart';

final logger = Logger();

class FormMetricDetailScreen extends ConsumerStatefulWidget {
  const FormMetricDetailScreen({super.key});

  @override
  ConsumerState<FormMetricDetailScreen> createState() =>
      _FormMetricDetailScreenState();
}

class _FormMetricDetailScreenState
    extends ConsumerState<FormMetricDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Load form metric on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formMetricViewModelProvider.notifier).loadFormMetric();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(formMetricViewModelProvider);
    final formMetric = state.formMetric;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 80,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF00D09E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.go('/main'),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text(
                'Form Metric Detail',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF00D09E), Color(0xFF00B386)],
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (state.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref
                            .read(formMetricViewModelProvider.notifier)
                            .loadFormMetric();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (formMetric != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FTND Score Card
                    Center(child: _buildFTNDScoreCard(formMetric.ftndScore)),

                    const SizedBox(height: 24),

                    // Smoking Habits Section
                    _buildSectionTitle('Smoking Habits'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.smoking_rooms,
                      title: 'Average Cigarettes Per Day',
                      value: '${formMetric.formMetricDTO.smokeAvgPerDay}',
                      color: const Color(0xFF00D09E),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Years of Smoking',
                      value:
                          '${formMetric.formMetricDTO.numberOfYearsOfSmoking}',
                      color: const Color(0xFF00B386),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Minutes After Waking to Smoke',
                      value:
                          '${formMetric.formMetricDTO.minutesAfterWakingToSmoke}',
                      color: const Color(0xFF00D09E),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.inventory_2,
                      title: 'Cigarettes Per Package',
                      value: '${formMetric.formMetricDTO.cigarettesPerPackage}',
                      color: const Color(0xFF00B386),
                    ),

                    const SizedBox(height: 24),

                    // Nicotine Intake Section
                    _buildSectionTitle('Nicotine Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.water_drop,
                      title: 'Nicotine Per Cigarette',
                      value:
                          '${formMetric.formMetricDTO.amountOfNicotinePerCigarettes} mg',
                      color: const Color(0xFF00D09E),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.science,
                      title: 'Estimated Daily Nicotine Intake',
                      value:
                          '${formMetric.formMetricDTO.estimatedNicotineIntakePerDay} mg',
                      color: const Color(0xFF00B386),
                    ),

                    const SizedBox(height: 24),

                    // Financial Information
                    _buildSectionTitle('Financial Impact'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.money,
                      title: 'Money Per Package',
                      value: NumberFormat(
                        '#,###',
                        'vi_VN',
                      ).format(formMetric.formMetricDTO.moneyPerPackage),
                      color: const Color(0xFF00B386),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.savings,
                      title: 'Estimated Money Saved on Plan',
                      value: NumberFormat('#,###', 'vi_VN').format(
                        formMetric.formMetricDTO.estimatedMoneySavedOnPlan,
                      ),
                      color: const Color(0xFF00D09E),
                      isHighlight: true,
                    ),

                    const SizedBox(height: 24),

                    // Smoking Behaviors
                    _buildSectionTitle('Smoking Behaviors'),
                    const SizedBox(height: 12),
                    _buildBehaviorCard(
                      icon: Icons.location_off,
                      title: 'Smoking in Forbidden Places',
                      value: formMetric.formMetricDTO.smokingInForbiddenPlaces,
                    ),
                    const SizedBox(height: 12),
                    _buildSpecialBehaviorCard(
                      icon: Icons.favorite,
                      title: 'Cigarette Hate to Give Up',
                      value: formMetric.formMetricDTO.cigaretteHateToGiveUp,
                    ),
                    const SizedBox(height: 12),
                    _buildBehaviorCard(
                      icon: Icons.wb_sunny,
                      title: 'Morning Smoking Frequency',
                      value: formMetric.formMetricDTO.morningSmokingFrequency,
                    ),
                    const SizedBox(height: 12),
                    _buildBehaviorCard(
                      icon: Icons.medical_services,
                      title: 'Smoke When Sick',
                      value: formMetric.formMetricDTO.smokeWhenSick,
                    ),

                    const SizedBox(height: 24),

                    // Interests Section
                    if (formMetric.formMetricDTO.interests.isNotEmpty) ...[
                      _buildSectionTitle('Interests'),
                      const SizedBox(height: 12),
                      _buildChipList(
                        formMetric.formMetricDTO.interests,
                        const Color(0xFF00B386),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Triggers Section
                    if (formMetric.formMetricDTO.triggered.isNotEmpty) ...[
                      _buildSectionTitle('Smoking Triggers'),
                      const SizedBox(height: 12),
                      _buildChipList(
                        formMetric.formMetricDTO.triggered,
                        const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Update Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => _showUpdateDialog(formMetric.formMetricDTO),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.edit, size: 24),
                                  SizedBox(width: 8),
                                  Text(
                                    'Update Form Metric',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            )
          else
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'No data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFTNDScoreCard(int score) {
    String getDependencyLevel() {
      if (score <= 2) return 'Very Low';
      if (score <= 4) return 'Low';
      if (score <= 6) return 'Medium';
      if (score <= 8) return 'High';
      return 'Very High';
    }

    Color getScoreColor() {
      if (score <= 2) return Colors.green;
      if (score <= 4) return Colors.lightGreen;
      if (score <= 6) return const Color(0xFF00D09E);
      if (score <= 8) return Colors.deepOrange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'FTND Score',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: TextStyle(
              color: getScoreColor(),
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: getScoreColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: getScoreColor().withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${getDependencyLevel()} Dependency',
              style: TextStyle(
                color: getScoreColor(),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlight ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlight ? color : Colors.grey.shade300,
          width: isHighlight ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? color : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBehaviorCard({
    required IconData icon,
    required String title,
    required bool value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: value
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value ? Colors.red : Colors.green,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: value ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value ? 'Yes' : 'No',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialBehaviorCard({
    required IconData icon,
    required String title,
    required bool value,
  }) {
    final displayText = value ? 'The first in the morning' : 'Any other';
    final displayColor = value ? const Color(0xFF00D09E) : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: displayColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: displayColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: displayColor,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: displayColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              value ? Icons.wb_sunny : Icons.schedule,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipList(List<String> items, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                item,
                style: TextStyle(
                  color: Color.lerp(color, Colors.black, 0.3),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showUpdateDialog(FormMetricDTO currentData) {
    logger.i('📝 [FormMetricDetail] Opening edit dialog');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFormMetricDialog(currentData: currentData),
        fullscreenDialog: true,
      ),
    ).then((updatedData) {
      if (updatedData != null && mounted) {
        logger.i('✅ [FormMetricDetail] Edit dialog returned updated data');
        _handleUpdate(updatedData as FormMetricDTO);
      } else {
        logger.w('⚠️ [FormMetricDetail] Edit dialog cancelled');
      }
    });
  }

  Future<void> _handleUpdate(FormMetricDTO currentData) async {
    logger.i('🔄 [FormMetricDetail] Starting update process');

    final request = UpdateFormMetricRequest(
      smokeAvgPerDay: currentData.smokeAvgPerDay,
      numberOfYearsOfSmoking: currentData.numberOfYearsOfSmoking,
      cigarettesPerPackage: currentData.cigarettesPerPackage,
      minutesAfterWakingToSmoke: currentData.minutesAfterWakingToSmoke,
      smokingInForbiddenPlaces: currentData.smokingInForbiddenPlaces,
      cigaretteHateToGiveUp: currentData.cigaretteHateToGiveUp,
      morningSmokingFrequency: currentData.morningSmokingFrequency,
      smokeWhenSick: currentData.smokeWhenSick,
      moneyPerPackage: currentData.moneyPerPackage,
      estimatedMoneySavedOnPlan: currentData.estimatedMoneySavedOnPlan,
      amountOfNicotinePerCigarettes: currentData.amountOfNicotinePerCigarettes,
      estimatedNicotineIntakePerDay: currentData.estimatedNicotineIntakePerDay,
      interests: currentData.interests,
      triggered: currentData.triggered,
    );

    logger.d('📦 [FormMetricDetail] Request data: ${request.toJson()}');

    final response = await ref
        .read(formMetricViewModelProvider.notifier)
        .updateFormMetric(request: request);

    if (!mounted) {
      logger.w('⚠️ [FormMetricDetail] Widget unmounted, aborting');
      return;
    }

    if (response != null) {
      logger.i(
        '✅ [FormMetricDetail] Update successful - FTND Score: ${response.ftndScore}, Alert: ${response.alert}',
      );

      // Show success message
      Flushbar(
        message: 'Form metric updated successfully!',
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      // Check if alert is true -> show warning dialog
      if (response.alert) {
        logger.w(
          '⚠️ [FormMetricDetail] Alert triggered - showing quit plan warning dialog',
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        _showAlertDialog(response.ftndScore);
      }
    } else {
      final state = ref.read(formMetricViewModelProvider);
      logger.e('❌ [FormMetricDetail] Update failed: ${state.error}');

      // Show error message
      Flushbar(
        message: state.error ?? 'Failed to update form metric',
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  void _showAlertDialog(int newFtndScore) {
    logger.w(
      '⚠️ [FormMetricDetail] Showing alert dialog for new FTND score: $newFtndScore',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.orange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Important Notice',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                'You have updated fields that affect your FTND score.',
                style: TextStyle(fontSize: 15, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // FTND Score Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'New FTND Score:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$newFtndScore',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Impact message
              const Text(
                'This may affect your quit plan, phases, and missions.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 12),

              // Question
              const Text(
                'Would you like to create a new quit plan based on your updated information?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Buttons - Vertical Stack
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    logger.i(
                      '🔄 [FormMetricDetail] User chose to create new quit plan',
                    );
                    Navigator.pop(context); // Close alert dialog
                    // Show create new quit plan dialog
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const CreateNewQuitPlanDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Create New Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    logger.i(
                      '✅ [FormMetricDetail] User chose to keep current plan',
                    );
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Keep Current Plan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

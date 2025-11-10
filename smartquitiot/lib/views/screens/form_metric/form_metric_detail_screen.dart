import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:logger/logger.dart';
import '../../../viewmodels/form_metric_view_model.dart';
import '../../../models/request/update_form_metric_request.dart';
import '../../../models/response/form_metric_response.dart';
import '_edit_form_metric_dialog.dart';

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
              onPressed: () => Navigator.pop(context),
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
                    colors: [
                      Color(0xFF00D09E),
                      Color(0xFF00B386),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          if (state.isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(),
              ),
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
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
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
                    Center(
                      child: _buildFTNDScoreCard(formMetric.ftndScore),
                    ),
                    
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
                      value: '${formMetric.formMetricDTO.numberOfYearsOfSmoking}',
                      color: const Color(0xFF00B386),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Minutes After Waking to Smoke',
                      value: '${formMetric.formMetricDTO.minutesAfterWakingToSmoke}',
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
                      value: '${formMetric.formMetricDTO.amountOfNicotinePerCigarettes} mg',
                      color: const Color(0xFF00D09E),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.science,
                      title: 'Estimated Daily Nicotine Intake',
                      value: '${formMetric.formMetricDTO.estimatedNicotineIntakePerDay} mg',
                      color: const Color(0xFF00B386),
                    ),

                    const SizedBox(height: 24),

                    // Financial Information
                    _buildSectionTitle('Financial Impact'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.money,
                      title: 'Money Per Package',
                      value: NumberFormat('#,###', 'vi_VN')
                          .format(formMetric.formMetricDTO.moneyPerPackage),
                      color: const Color(0xFF00B386),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.savings,
                      title: 'Estimated Money Saved on Plan',
                      value: NumberFormat('#,###', 'vi_VN').format(
                          formMetric.formMetricDTO.estimatedMoneySavedOnPlan),
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
                    _buildBehaviorCard(
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
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
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
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
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
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
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
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
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
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
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 16,
                color: color,
              ),
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
      logger.i('✅ [FormMetricDetail] Update successful - FTND Score: ${response.ftndScore}, Alert: ${response.alert}');
      
      // Show success message
      Flushbar(
        message: 'Form metric updated successfully!',
        icon: const Icon(
          Icons.check_circle,
          color: Colors.white,
        ),
        backgroundColor: const Color(0xFF00D09E),
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);

      // Check if alert is true -> show warning dialog
      if (response.alert) {
        logger.w('⚠️ [FormMetricDetail] Alert triggered - showing quit plan warning dialog');
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
        icon: const Icon(
          Icons.error_outline,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(12),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  void _showAlertDialog(int newFtndScore) {
    logger.w('⚠️ [FormMetricDetail] Showing alert dialog for new FTND score: $newFtndScore');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 32,
            ),
            SizedBox(width: 12),
            Text(
              'Important Notice',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You have updated fields that affect your FTND score.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'New FTND Score:',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$newFtndScore',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'This may affect your quit plan, phases, and missions.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Would you like to create a new quit plan based on your updated information?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              logger.i('✅ [FormMetricDetail] User chose to keep current plan');
              Navigator.pop(context);
            },
            child: const Text(
              'Keep Current Plan',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              logger.i('🔄 [FormMetricDetail] User chose to create new quit plan');
              Navigator.pop(context);
              // TODO: Navigate to create new quit plan screen
              // context.go('/create-quit-plan');
              Flushbar(
                message: 'Create new quit plan feature coming soon!',
                icon: const Icon(
                  Icons.info_outline,
                  color: Colors.white,
                ),
                backgroundColor: const Color(0xFF00D09E),
                duration: const Duration(seconds: 2),
                margin: const EdgeInsets.all(8),
                borderRadius: BorderRadius.circular(12),
                flushbarPosition: FlushbarPosition.TOP,
              ).show(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create New Plan'),
          ),
        ],
      ),
    );
  }
}

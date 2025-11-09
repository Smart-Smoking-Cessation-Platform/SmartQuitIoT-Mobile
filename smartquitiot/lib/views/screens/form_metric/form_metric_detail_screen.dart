import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../viewmodels/form_metric_view_model.dart';

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
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Your Metrics',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6A11CB),
                      Color(0xFF2575FC),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.assessment_rounded,
                    size: 80,
                    color: Colors.white.withOpacity(0.3),
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
                    _buildFTNDScoreCard(formMetric.ftndScore),
                    
                    const SizedBox(height: 24),

                    // Smoking Habits Section
                    _buildSectionTitle('Smoking Habits'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.smoking_rooms,
                      title: 'Average Cigarettes Per Day',
                      value: '${formMetric.formMetricDTO.smokeAvgPerDay}',
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Years of Smoking',
                      value: '${formMetric.formMetricDTO.numberOfYearsOfSmoking}',
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Minutes After Waking to Smoke',
                      value: '${formMetric.formMetricDTO.minutesAfterWakingToSmoke}',
                      color: Colors.purple,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.inventory_2,
                      title: 'Cigarettes Per Package',
                      value: '${formMetric.formMetricDTO.cigarettesPerPackage}',
                      color: Colors.teal,
                    ),

                    const SizedBox(height: 24),

                    // Nicotine Intake Section
                    _buildSectionTitle('Nicotine Information'),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.water_drop,
                      title: 'Nicotine Per Cigarette',
                      value: '${formMetric.formMetricDTO.amountOfNicotinePerCigarettes} mg',
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.science,
                      title: 'Estimated Daily Nicotine Intake',
                      value: '${formMetric.formMetricDTO.estimatedNicotineIntakePerDay} mg',
                      color: Colors.deepOrange,
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
                      color: Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.savings,
                      title: 'Estimated Money Saved on Plan',
                      value: NumberFormat('#,###', 'vi_VN').format(
                          formMetric.formMetricDTO.estimatedMoneySavedOnPlan),
                      color: Colors.lightGreen,
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
                        Colors.purple,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Triggers Section
                    if (formMetric.formMetricDTO.triggered.isNotEmpty) ...[
                      _buildSectionTitle('Smoking Triggers'),
                      const SizedBox(height: 12),
                      _buildChipList(
                        formMetric.formMetricDTO.triggered,
                        Colors.red,
                      ),
                      const SizedBox(height: 24),
                    ],
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
      if (score <= 6) return Colors.orange;
      if (score <= 8) return Colors.deepOrange;
      return Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            getScoreColor(),
            getScoreColor().withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: getScoreColor().withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'FTND Score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${getDependencyLevel()} Dependency',
              style: const TextStyle(
                color: Colors.white,
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
}

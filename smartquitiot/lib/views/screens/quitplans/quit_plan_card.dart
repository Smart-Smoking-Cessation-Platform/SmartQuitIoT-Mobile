import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import '../../../providers/mission_refresh_provider.dart';
import 'quit_plan_screen.dart';

class QuitPlanCard extends ConsumerStatefulWidget {
  const QuitPlanCard({super.key});

  @override
  ConsumerState<QuitPlanCard> createState() => _QuitPlanCardState();
}

class _QuitPlanCardState extends ConsumerState<QuitPlanCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();

    // Animation cho glow effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Delay để tránh race condition khi navigate từ onboarding
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('⏳ [QuitPlanCard] Waiting 500ms before initial load...');
      await Future.delayed(const Duration(milliseconds: 500));
      print('🚀 [QuitPlanCard] Auto-loading quit plan...');
      ref
          .read(quitPlanHomepageViewModelProvider.notifier)
          .loadQuitPlanHomePage();
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanHomepageViewModelProvider);

    // Listen for mission refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [QuitPlanCard] Refresh triggered - reloading quit plan...');
        ref
            .read(quitPlanHomepageViewModelProvider.notifier)
            .loadQuitPlanHomePage();
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      );
    }

    if (state.hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error: ${state.error}',
                style: TextStyle(color: Colors.red[700], fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    if (!state.hasQuitPlan) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'No quit plan available',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    final quitPlan = state.quitPlan!;
    const Color progressColorStart = Color(0xFF00D09E);
    const Color progressColorEnd = Color(0xFF3FCF8E);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smoke_free,
                color: Color(0xFF00D09E),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quit Plan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    quitPlan.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: _getPhaseTextColor(quitPlan.name),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                minimumSize: const Size(0, 32),
              ),
              child: const Text(
                'View More',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Duration and Date Info
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                icon: Icons.calendar_today,
                label: 'Duration',
                value: '${quitPlan.durationDay} days',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoCard(
                icon: Icons.flag,
                label: 'Start Date',
                value: _formatDate(quitPlan.startDate),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 📊 Statistics Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FFFE),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.analytics_outlined, 
                    size: 18, 
                    color: const Color(0xFF00D09E)),
                  const SizedBox(width: 8),
                  const Text(
                    'Phase Statistics',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Avg Craving',
                      value: quitPlan.avgCravingLevel.toStringAsFixed(1),
                      icon: Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Avg Cigarettes',
                      value: quitPlan.avgCigarettes.toStringAsFixed(1),
                      icon: Icons.smoking_rooms,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildStatItem(
                label: 'Total Cigarettes',
                value: quitPlan.fmCigarettesTotal.toStringAsFixed(0),
                icon: Icons.local_fire_department,
                color: Colors.deepOrange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 🎯 Conditions to Pass Section
        if (quitPlan.condition.rules.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D09E).withOpacity(0.1),
                  const Color(0xFF3FCF8E).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.verified_outlined, 
                      size: 18, 
                      color: const Color(0xFF00D09E)),
                    const SizedBox(width: 8),
                    const Text(
                      'Conditions to Pass',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00D09E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildConditionRules(quitPlan.condition),
              ],
            ),
          ),
        const SizedBox(height: 16),

        // 🔥 Styled Phase Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _getPhaseGradient(quitPlan.currentPhaseDetail.name),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _getPhaseIcon(quitPlan.currentPhaseDetail.name),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      quitPlan.currentPhaseDetail.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Day ${quitPlan.currentPhaseDetail.dayIndex}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Today: ${quitPlan.currentPhaseDetail.missionProgress} missions',
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 🌈 Styled Progress Bar with Glow
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Progress',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F8F2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, _) {
                    final glow = 4 + (_glowController.value * 6);
                    return Container(
                      height: 12,
                      width:
                          MediaQuery.of(context).size.width *
                          0.7 *
                          quitPlan.progressPercentage,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [progressColorStart, progressColorEnd],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: progressColorStart.withOpacity(0.5),
                            blurRadius: glow,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Positioned(
                  right: 0,
                  child: Text(
                    '${quitPlan.progressPercent}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Color _getPhaseTextColor(String phaseName) {
    switch (phaseName.trim().toLowerCase()) {
      case 'preparation':
        return const Color(0xFF4A90E2); // xanh dương
      case 'onset':
        return const Color(0xFFFF9800);
      case 'peak craving':
        return const Color(0xFFE91E63);
      case 'maintenance':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF00D09E); // xanh lá default
    }
  }

  List<Color> _getPhaseGradient(String phaseName) {
    switch (phaseName.trim().toLowerCase()) {
      case 'preparation':
        return [const Color(0xFF4A90E2), const Color(0xFF50E3C2)];
      case 'onset':
        return [const Color(0xFFFFC107), const Color(0xFFFF9800)];
      case 'peak craving':
        return [const Color(0xFFF44336), const Color(0xFFE91E63)];
      case 'maintenance':
        return [const Color(0xFF9C27B0), const Color(0xFFBA68C8)];
      default:
        return [const Color(0xFF00D09E), const Color(0xFF00E676)];
    }
  }

  // 🧭 Icon cho từng giai đoạn
  Widget _getPhaseIcon(String phaseName) {
    switch (phaseName.toLowerCase()) {
      case 'preparation':
        return const Icon(
          Icons.lightbulb_outline,
          color: Colors.white,
          size: 20,
        );
      case 'onset':
        return const Icon(Icons.timeline, color: Colors.white, size: 20);
      case 'peak craving':
        return const Icon(
          Icons.local_fire_department,
          color: Colors.white,
          size: 20,
        );
      case 'subsiding':
        return const Icon(Icons.water_drop, color: Colors.white, size: 20);
      case 'maintenance':
        return const Icon(Icons.eco, color: Colors.white, size: 20);
      default:
        return const Icon(Icons.flag, color: Colors.white, size: 20);
    }
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConditionRules(condition) {
    final rules = condition.rules;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (condition.logic != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Logic: ${condition.logic}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
        const SizedBox(height: 8),
        ...rules.map<Widget>((rule) => _buildRule(rule)).toList(),
      ],
    );
  }

  Widget _buildRule(rule, {int indent = 0}) {
    return Container(
      margin: EdgeInsets.only(left: indent * 16.0, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // If this rule has nested rules (OR logic)
          if (rule.rules != null && rule.rules!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.alt_route, size: 14, color: Colors.blue[700]),
                const SizedBox(width: 6),
                Text(
                  'Logic: ${rule.logic ?? "AND"}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...rule.rules!.map<Widget>((nestedRule) => 
              _buildRule(nestedRule, indent: indent + 1)
            ).toList(),
          ] else ...[
            // Single rule display
            Row(
              children: [
                Icon(Icons.check_circle_outline, size: 14, color: Colors.green[700]),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatFieldName(rule.field),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatRuleCondition(rule),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatFieldName(String? field) {
    if (field == null) return '';
    switch (field) {
      case 'progress':
        return 'Mission Progress';
      case 'craving_level_avg':
        return 'Average Craving Level';
      case 'avg_cigarettes':
        return 'Average Cigarettes';
      default:
        return field.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _formatRuleCondition(rule) {
    final operator = rule.operator ?? '';
    
    // Handle formula-based rules
    if (rule.formula != null) {
      final formula = rule.formula!;
      final base = formula['base'] ?? '';
      final percent = formula['percent'] ?? 0;
      final op = formula['operator'] ?? '';
      return 'Must be $operator ${(percent * 100).toInt()}% $op $base';
    }
    
    // Simple value-based rules
    final value = rule.value;
    return 'Must be $operator $value';
  }
}

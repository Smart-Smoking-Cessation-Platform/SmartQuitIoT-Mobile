import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/quit_plan_detail_provider.dart';
import '../../../models/quit_plan_detail.dart';
import '../../../models/quit_phase.dart';
import '../../../utils/phase_theme.dart';

class QuitPlanDetailScreen extends ConsumerStatefulWidget {
  final int quitPlanId;

  const QuitPlanDetailScreen({super.key, required this.quitPlanId});

  @override
  ConsumerState<QuitPlanDetailScreen> createState() =>
      _QuitPlanDetailScreenState();
}

class _QuitPlanDetailScreenState extends ConsumerState<QuitPlanDetailScreen> {
  int selectedPhaseIndex = 0;
  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(quitPlanDetailViewModelProvider.notifier)
          .loadQuitPlanDetail(widget.quitPlanId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanDetailViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan Details'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(quitPlanDetailViewModelProvider.notifier)
                  .loadQuitPlanDetail(widget.quitPlanId);
            },
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(quitPlanDetailViewModelProvider.notifier)
                    .loadQuitPlanDetail(widget.quitPlanId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('No data found'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(data),
                if (data.formMetricDTO != null)
                  _buildFormMetrics(data.formMetricDTO!),
                _buildStats(data),
                if (data.phases != null && data.phases!.isNotEmpty)
                  _buildPhasesList(data.phases!, data),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(QuitPlanDetail data) {
    final planName = data.name.trim().isEmpty ? 'Quit Plan' : data.name.trim();
    final ftndScoreLabel = data.ftndScore > 0
        ? data.ftndScore.toString()
        : 'N/A';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.smoke_free,
                  color: Color(0xFF00D09E),
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      planName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'FTND Score: $ftndScoreLabel',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (data.useNRT == true)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NRT',
                    style: TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                '${_formatDate(data.startDate)} → ${_formatDate(data.endDate)}',

                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormMetrics(FormMetricDTO metrics) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      margin: const EdgeInsets.all(16),
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
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.analytics,
                  color: Color(0xFF00D09E),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Smoking Metrics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildMetricChip(
                '${metrics.smokeAvgPerDay} cigs/day',
                Icons.smoke_free,
                const Color(0xFFEF4444),
              ),
              _buildMetricChip(
                '${metrics.numberOfYearsOfSmoking} years',
                Icons.calendar_today,
                const Color(0xFF3B82F6),
              ),
              _buildMetricChip(
                '${formatter.format(metrics.estimatedMoneySavedOnPlan)} đ saved',
                Icons.savings,
                const Color(0xFF00D09E),
              ),
              _buildMetricChip(
                '${metrics.estimatedNicotineIntakePerDay.toStringAsFixed(0)} mg nicotine/day',
                Icons.science,
                const Color(0xFF8B5CF6),
              ),
            ],
          ),
          if (metrics.triggered.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Triggers:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: metrics.triggered
                  .map(
                    (t) => Chip(
                      label: Text(t, style: const TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
                      side: BorderSide(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(fontSize: 12, color: color)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildStats(QuitPlanDetail data) {
    final totalMissions = data.totalMissions;
    final completedMissions = data.completedMissions;
    final progress = totalMissions > 0
        ? completedMissions / totalMissions
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                'Phases',
                '${data.phases?.length ?? 0}',
                Icons.flag,
                const Color(0xFF3B82F6),
              ),
              _buildStatItem(
                'Missions',
                '$completedMissions/$totalMissions',
                Icons.task_alt,
                const Color(0xFF10B981),
              ),
              _buildStatItem(
                'Progress',
                '${(progress * 100).toInt()}%',
                Icons.trending_up,
                const Color(0xFFF59E0B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF00D09E)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPhasesList(List<QuitPhaseDetail> phases, QuitPlanDetail plan) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: phases.length,
      itemBuilder: (context, index) {
        final phase = phases[index];
        final phaseName = (phase.name ?? '').trim();
        final fallbackName = plan.name.trim();
        final themeKey = phaseName.isNotEmpty
            ? phaseName
            : (fallbackName.isNotEmpty ? fallbackName : 'Quit Plan');
        final phaseTheme = resolvePhaseTheme(themeKey);
        final isExpanded = selectedPhaseIndex == index;

        // Xử lý progress an toàn
        final totalMissions = phase.totalMissions ?? 0;
        final completedMissions = phase.completedMissions ?? 0;
        final phaseProgress = (totalMissions > 0)
            ? (completedMissions / totalMissions)
            : 0.0;
        final phasePercent = (phaseProgress * 100).toInt();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: phaseTheme.primaryColor.withOpacity(0.18),
              width: 1,
            ),
          ),
          elevation: 0,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    selectedPhaseIndex = isExpanded ? -1 : index;
                    selectedDayIndex = 0;
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: phaseTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              phaseTheme.icon,
                              color: phaseTheme.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  phase.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_formatDate(phase.startDate)} → ${_formatDate(phase.endDate)}',

                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isFailedStatus(phase.status)
                                  ? Colors.redAccent.withOpacity(0.15)
                                  : phaseTheme.primaryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _formatStatus(phase.status),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isFailedStatus(phase.status)
                                    ? Colors.redAccent
                                    : phaseTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildPhaseInfoChips(phase, phaseTheme),
                      // Progress bar giai đoạn
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: phaseProgress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: phaseTheme.primaryColor.withOpacity(
                            0.1,
                          ),
                          valueColor: AlwaysStoppedAnimation(
                            phaseTheme.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$phasePercent% completed',
                            style: TextStyle(
                              fontSize: 10,
                              color: phaseTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) _buildPhaseDetails(plan, phase, phaseTheme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseDetails(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final days = phase.details ?? [];
    final isFailed = _isFailedStatus(phase.status);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFailed) _buildFailedPhaseBanner(plan, phase, theme),
          if ((phase.reason ?? '').isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: theme.primaryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      phase.reason ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (phase.avgCravingLevel != null ||
              phase.avgCigarettes != null ||
              phase.fmCigarettesTotal != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FFFE),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Phase Statistics',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (phase.avgCravingLevel != null)
                        Expanded(
                          child: _buildSmallStat(
                            label: 'Avg Craving',
                            value: phase.avgCravingLevel!.toStringAsFixed(1),
                            color: Colors.red,
                          ),
                        ),
                      if (phase.avgCigarettes != null) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildSmallStat(
                            label: 'Avg Cigs',
                            value: phase.avgCigarettes!.toStringAsFixed(1),
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (phase.fmCigarettesTotal != null) ...[
                    const SizedBox(height: 6),
                    _buildSmallStat(
                      label: 'Total Cigarettes',
                      value: phase.fmCigarettesTotal!.toStringAsFixed(0),
                      color: Colors.deepOrange,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (phase.condition != null &&
              (phase.condition!.rules?.isNotEmpty ?? false)) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.verified_outlined,
                        size: 16,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Conditions to Pass',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildPhaseConditions(
                    phase.condition!,
                    theme,
                    phase.fmCigarettesTotal ?? 0,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (days.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No missions available yet',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            )
          else ...[
            const Text(
              'Days:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70, // tăng chút để vừa chữ day + date
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                itemBuilder: (context, dayIdx) {
                  final day = days[dayIdx];
                  final isSelected = selectedDayIndex == dayIdx;
                  final missions = day.missions ?? [];
                  final completed = missions
                      .where((m) => m.status == 'COMPLETED')
                      .length;

                  return GestureDetector(
                    onTap: () => setState(() => selectedDayIndex = dayIdx),
                    child: Container(
                      width: 80, // tăng chút rộng để ngày không bị ép
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.primaryColor
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Day ${day.dayIndex}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDate(day.date),

                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),

                          const SizedBox(height: 4),
                          Text(
                            '$completed/${missions.length}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white70
                                  : theme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            if (selectedDayIndex < days.length)
              _buildMissionsList(days[selectedDayIndex].missions ?? [], theme),
          ],
        ],
      ),
    );
  }

  Widget _buildMissionsList(List<QuitMissionItem> missions, PhaseTheme theme) {
    if (missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No missions for this day')),
      );
    }

    return Column(
      children: missions.map((mission) {
        final completed = mission.status == 'COMPLETED';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: completed
                ? Colors.green.withOpacity(0.05)
                : theme.primaryColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: completed
                  ? Colors.green
                  : theme.primaryColor.withOpacity(0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: completed ? Colors.green : theme.primaryColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      mission.name ?? '',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: completed ? Colors.green : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              if ((mission.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Text(
                    mission.description ?? '',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSmallStat({
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhaseConditions(
    PhaseCondition condition,
    PhaseTheme theme,
    double fmCigarettesTotal,
  ) {
    final rules = condition.rules ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (condition.logic != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Logic: ${condition.logic}',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
              ),
            ),
          ),
        if (fmCigarettesTotal > 0)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Baseline total cigarettes: ${fmCigarettesTotal.toStringAsFixed(1)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: theme.primaryColor,
              ),
            ),
          ),
        const SizedBox(height: 6),
        ...rules
            .map<Widget>(
              (rule) => _buildPhaseRule(
                rule,
                theme,
                fmCigarettesTotal: fmCigarettesTotal,
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildPhaseRule(
    PhaseRule rule,
    PhaseTheme theme, {
    int indent = 0,
    required double fmCigarettesTotal,
  }) {
    return Container(
      margin: EdgeInsets.only(left: indent * 12.0, bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rule.rules != null && rule.rules!.isNotEmpty) ...[
            Row(
              children: [
                Icon(Icons.alt_route, size: 12, color: theme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  'Logic: ${rule.logic ?? "AND"}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...rule.rules!
                .map<Widget>(
                  (nestedRule) => _buildPhaseRule(
                    nestedRule,
                    theme,
                    indent: indent + 1,
                    fmCigarettesTotal: fmCigarettesTotal,
                  ),
                )
                .toList(),
          ] else ...[
            Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 12,
                  color: theme.primaryColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _formatPhaseFieldName(rule.field),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        _formatPhaseRuleCondition(
                          rule,
                          fmCigarettesTotal: fmCigarettesTotal,
                        ),
                        style: TextStyle(fontSize: 10, color: Colors.grey[700]),
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

  String _formatPhaseFieldName(String? field) {
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

  String _formatPhaseRuleCondition(
    PhaseRule rule, {
    required double fmCigarettesTotal,
  }) {
    final operator = rule.operator ?? '';

    if (rule.formula != null) {
      final formula = rule.formula!;
      final base = (formula['base'] ?? '').toString();
      final percent = (formula['percent'] ?? 0) as num;
      final op = (formula['operator'] ?? '').toString();
      final percentLabel = (percent * 100).toStringAsFixed(
        percent * 100 % 1 == 0 ? 0 : 1,
      );

      if (base == 'fm_cigarettes_total' && fmCigarettesTotal > 0) {
        final computed = fmCigarettesTotal * percent;
        return 'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)} (≤ ${computed.toStringAsFixed(1)})';
      }

      return 'Must be $operator $percentLabel% $op ${_formatFormulaBase(base)}';
    }

    final value = rule.value;
    if (value == null) {
      return 'Must be $operator value';
    }

    String displayValue = value.toString();
    if (rule.field == 'progress' && value is num) {
      displayValue = '${value.toString()}%';
    }

    return 'Must be $operator $displayValue';
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'Unknown';
    final normalized = status.replaceAll('_', ' ').toLowerCase();
    return normalized
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  bool _isFailedStatus(String? status) =>
      status != null && status.toUpperCase() == 'FAILED';

  String _formatBoolean(
    bool value, {
    String trueLabel = 'Yes',
    String falseLabel = 'No',
  }) => value ? trueLabel : falseLabel;

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'N/A';
    try {
      final parsed = DateTime.parse(dateTime).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(parsed);
    } catch (_) {
      return dateTime;
    }
  }

  Widget _buildFailedPhaseBanner(
    QuitPlanDetail plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final planName = plan.name.trim();
    final displayPlanName = planName.isEmpty ? 'Quit Plan' : planName;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text('😞', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Oh no! Phase failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'This phase did not meet the exit criteria. Review the statistics and conditions below to understand what happened.',
            style: TextStyle(fontSize: 13),
          ),
          if ((phase.reason ?? '').isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Plan: $displayPlanName',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhaseInfoChips(QuitPhaseDetail phase, PhaseTheme theme) {
    final chips = <Widget>[];

    if (phase.createdAt != null && phase.createdAt!.isNotEmpty) {
      chips.add(
        _buildInfoChip(
          icon: Icons.event,
          label: 'Created',
          value: _formatDateTime(phase.createdAt),
          theme: theme,
        ),
      );
    }

    if (phase.keepPhase != null) {
      chips.add(
        _buildInfoChip(
          icon: Icons.shield,
          label: 'Keep Phase',
          value: _formatBoolean(
            phase.keepPhase!,
            trueLabel: 'Allowed',
            falseLabel: 'Disabled',
          ),
          theme: theme,
        ),
      );
    }

    if (phase.redo != null) {
      chips.add(
        _buildInfoChip(
          icon: Icons.refresh,
          label: 'Redo',
          value: _formatBoolean(
            phase.redo!,
            trueLabel: 'Available',
            falseLabel: 'Unavailable',
          ),
          theme: theme,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Wrap(spacing: 10, runSpacing: 10, children: chips),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String value,
    required PhaseTheme theme,
    Color? valueColor,
  }) {
    final effectiveColor = valueColor ?? theme.primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: effectiveColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: effectiveColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: effectiveColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: effectiveColor.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatFormulaBase(String base) {
    switch (base) {
      case 'fm_cigarettes_total':
        return 'baseline total cigarettes';
      case 'progress':
        return 'mission progress';
      default:
        return base.replaceAll('_', ' ');
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return '';
    }
  }
}

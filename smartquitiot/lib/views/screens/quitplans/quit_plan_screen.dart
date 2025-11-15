import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../../../models/quit_phase.dart';
import '../../../models/request/create_new_quit_plan_request.dart';
import '../../../utils/phase_theme.dart';
import '../../../viewmodels/form_metric_view_model.dart';
import '../../../models/response/form_metric_response.dart';
import '../../../models/request/update_form_metric_request.dart';
import '../../widgets/mission_complete_dialog.dart';
import '../diary/diary_screen.dart';
import '../form_metric/_edit_form_metric_dialog.dart';
import 'quit_plan_history_screen.dart';

class QuitPlanScreen extends ConsumerStatefulWidget {
  const QuitPlanScreen({super.key});

  @override
  ConsumerState<QuitPlanScreen> createState() => _QuitPlanScreenState();
}

class _QuitPlanScreenState extends ConsumerState<QuitPlanScreen> {
  int selectedPhaseIndex = 0;
  int selectedDayIndex = 0;
  final Set<int> locallyCompletedMissionIds = <int>{};

  void _showMissionCompleteDialog(QuitMissionItem mission, int phaseId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MissionCompleteDialog(
        phaseId: phaseId,
        phaseDetailMissionId: mission.id ?? 0,
        missionCode: mission.code ?? '',
        missionName: mission.name ?? '',
        missionDescription: mission.description ?? '',
        onCompleted: () {
          // Refresh the quit plan data after mission completion
          ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
          // Also add to local completed set for immediate UI update
          setState(() {
            locallyCompletedMissionIds.add(mission.id ?? 0);
          });
        },
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF00D09E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quitPlanViewModelApiProvider);

    // Listen for quit plan refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print('🔄 [QuitPlanScreen] Refresh triggered - reloading quit plan...');
        ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const QuitPlanHistoryScreen(),
                ),
              );
            },
            tooltip: 'Quit Plan History',
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
                    .read(quitPlanViewModelApiProvider.notifier)
                    .loadQuitPlan(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (data) {
          // Check if quit plan is inactive - treat as if no quit plan exists
          if (data == null ||
              data.active == false ||
              (data.phases?.isEmpty ?? true)) {
            return const Center(child: Text('No quit plan found'));
          }

          final phases = data.phases!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(data),
                _buildStats(phases),
                _buildPhasesList(phases, data),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DiaryScreen()),
          );
        },
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white, // ✅ thêm dòng này
        icon: const Icon(Icons.book), // icon giờ sẽ tự trắng
        label: const Text('Diary'),
      ),
    );
  }

  Widget _buildHeader(QuitPhase data) {
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
                      data.name ?? 'Quit Plan',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'FTND Score: ${data.ftndScore ?? 'N/A'}',
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

  Widget _buildStats(List<QuitPhaseDetail> phases) {
    final totalMissions = phases.fold<int>(
      0,
      (sum, p) => sum + (p.totalMissions ?? 0),
    );
    final completedMissions = phases.fold<int>(
      0,
      (sum, p) => sum + (p.completedMissions ?? 0),
    );
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
                '${phases.length}',
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

  Widget _buildPhasesList(List<QuitPhaseDetail> phases, QuitPhase plan) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: phases.length,
      itemBuilder: (context, index) {
        final phase = phases[index];
        final phaseTheme = resolvePhaseTheme(phase.name ?? plan.name ?? '');
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
                      const SizedBox(height: 10),
                      _buildPhaseInfoChips(phase, phaseTheme),
                      const SizedBox(height: 8),
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
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final days = phase.details ?? [];
    final isFailed = _isFailedStatus(phase.status);
    final shouldShowBanner = isFailed && (phase.keepPhase != true);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (shouldShowBanner) _buildFailedPhaseBanner(plan, phase, theme),
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
                    phase.durationDay ?? 0,
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
                      .where(
                        (m) =>
                            m.status == 'COMPLETED' ||
                            locallyCompletedMissionIds.contains(m.id),
                      )
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

  /// Check if a given date is today
  bool _isToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      final date = DateTime.parse(dateString);
      final today = DateTime.now();
      return date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;
    } catch (e) {
      return false;
    }
  }

  /// Check if all missions for a day are completed
  bool _areAllMissionsCompleted(List<QuitMissionItem> missions) {
    if (missions.isEmpty) return false;
    return missions.every((mission) {
      final missionId = mission.id ?? -1;
      return mission.status == 'COMPLETED' ||
          locallyCompletedMissionIds.contains(missionId);
    });
  }

  Widget _buildMissionsList(List<QuitMissionItem> missions, PhaseTheme theme) {
    if (missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No missions for this day')),
      );
    }

    // Get the current selected day to check if it's today and if all missions are completed
    final quitPhaseState = ref.read(quitPlanViewModelApiProvider);
    String? selectedDayDate;
    quitPhaseState.when(
      data: (quitPhase) {
        if (quitPhase != null &&
            quitPhase.phases != null &&
            selectedPhaseIndex < quitPhase.phases!.length) {
          final currentPhase = quitPhase.phases![selectedPhaseIndex];
          final days = currentPhase.details ?? [];
          if (selectedDayIndex < days.length) {
            selectedDayDate = days[selectedDayIndex].date;
          }
        }
      },
      loading: () {},
      error: (error, stack) {},
    );

    final isSelectedDayToday = _isToday(selectedDayDate);
    final allMissionsCompleted = _areAllMissionsCompleted(missions);
    final showCongratulations = isSelectedDayToday && allMissionsCompleted;

    return Column(
      children: [
        if (showCongratulations)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.primaryColor.withOpacity(0.12),
                  theme.primaryColor.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('🎉', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text('🎆', style: TextStyle(fontSize: 20)),
                    SizedBox(width: 8),
                    Text('✨', style: TextStyle(fontSize: 18)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have completed all missions for today!\nCome back tomorrow for new challenges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ...missions.map((mission) {
          final missionId = mission.id ?? -1;
          final completed =
              mission.status == 'COMPLETED' ||
              locallyCompletedMissionIds.contains(missionId);

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
                if (!completed && missionId != -1) ...[
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isSelectedDayToday
                          ? () {
                              final quitPhaseState = ref.read(
                                quitPlanViewModelApiProvider,
                              );
                              quitPhaseState.when(
                                data: (quitPhase) {
                                  if (quitPhase != null &&
                                      quitPhase.phases != null &&
                                      selectedPhaseIndex <
                                          quitPhase.phases!.length) {
                                    final currentPhase =
                                        quitPhase.phases![selectedPhaseIndex];
                                    _showMissionCompleteDialog(
                                      mission,
                                      currentPhase.id ?? 0,
                                    );
                                  }
                                },
                                loading: () {},
                                error: (error, stack) {},
                              );
                            }
                          : null,
                      style: TextButton.styleFrom(
                        backgroundColor: isSelectedDayToday
                            ? theme.primaryColor
                            : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isSelectedDayToday
                            ? 'Complete Mission'
                            : 'Not Available Yet',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ],
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
    int durationDay,
  ) {
    final rules = condition.rules ?? [];

    // Use fmCigarettesTotal as baseline if available
    double baselineTotal = fmCigarettesTotal;

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
        if (baselineTotal > 0)
          Container(
            margin: const EdgeInsets.only(top: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Baseline: ${baselineTotal.toStringAsFixed(0)} cigarettes',
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
                fmCigarettesTotal: baselineTotal,
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

    return Wrap(spacing: 10, runSpacing: 10, children: chips);
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

  Widget _buildFailedPhaseBanner(
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
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
            'This phase did not meet the exit criteria. You can choose to keep your progress or restart with a new anchor date.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => _showFailedPhaseDialog(plan, phase, theme),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.build),
              label: const Text('Review options'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback? onTap,
    required bool isLoading,
    required PhaseTheme theme,
    bool isPrimary = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLoading ? Colors.grey.shade300 : color.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: isLoading
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            children: [
              // Icon in circular background
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey.shade200
                      : color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      )
                    : Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLoading
                            ? Colors.grey.shade400
                            : Colors.black87,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isLoading
                            ? Colors.grey.shade400
                            : Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLoading)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: color,
                    size: 14,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showFailedPhaseDialog(
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) async {
    final planId = plan.id;
    final phaseId = phase.id;
    if (planId == null || phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    String? processingAction;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> setProcessing(String? action) async {
              setDialogState(() {
                processingAction = action;
              });
            }

            Future<void> handleKeepPhase() async {
              await setProcessing('keep');
              try {
                await ref
                    .read(quitPlanViewModelApiProvider.notifier)
                    .keepPhase(quitPlanId: planId, phaseId: phaseId);
                if (!mounted) return;
                Navigator.of(context).pop();
                _showSnack('Phase kept successfully. 🎯');
                // Refresh quit plan data
                ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
              } catch (e) {
                await setProcessing(null);
                _showSnack(
                  'Keep phase failed: ${_errorMessage(e)}',
                  isError: true,
                );
              }
            }

            Future<void> handleRedoPhase() async {
              await setProcessing('redo');
              final now = DateTime.now();
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: now.add(const Duration(days: 365)),
                helpText: 'Choose restart date',
              );

              if (selectedDate == null) {
                await setProcessing(null);
                return;
              }

              final formattedDate = DateFormat(
                'yyyy-MM-dd',
              ).format(selectedDate);

              try {
                await ref
                    .read(quitPlanViewModelApiProvider.notifier)
                    .redoPhase(phaseId: phaseId, anchorStart: formattedDate);
                if (!mounted) return;
                Navigator.of(context).pop();
                _showSnack('Phase restarted from $formattedDate. 🔄');
                // Refresh quit plan data
                ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
              } catch (e) {
                await setProcessing(null);
                _showSnack(
                  'Redo phase failed: ${_errorMessage(e)}',
                  isError: true,
                );
              }
            }

            Future<void> handleCreateNewPlan() async {
              await setProcessing('create');
              Navigator.of(
                context,
              ).pop(); // Close the failed phase dialog first

              // Show create new plan dialog
              if (!mounted) return;
              await _showCreateNewPlanDialog(theme);
              await setProcessing(null);
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 400,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section - White background
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 20, 16, 18),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEEAEA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.redAccent[700],
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Phase Failed',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Choose your next action',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: Colors.black54,
                                size: 18,
                              ),
                            ),
                            onPressed: processingAction == null
                                ? () => Navigator.of(context).pop()
                                : null,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                    // Content Section with scroll
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info Message
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(
                                    0xFF90CAF9,
                                  ).withOpacity(0.4),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF2196F3,
                                      ).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline_rounded,
                                      color: Color(0xFF1976D2),
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'This phase did not meet the exit criteria. Select an option below to continue your journey.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.blue.shade900,
                                        height: 1.4,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Action Options
                            // Keep Phase Option
                            _buildActionCard(
                              icon: Icons.shield_outlined,
                              title: 'Keep Phase',
                              description:
                                  'Preserve your current progress and continue',
                              color: const Color(0xFF00D09E),
                              onTap: processingAction == null
                                  ? handleKeepPhase
                                  : null,
                              isLoading: processingAction == 'keep',
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            // Redo Phase Option
                            _buildActionCard(
                              icon: Icons.refresh_outlined,
                              title: 'Redo Phase',
                              description:
                                  'Restart this phase with a new anchor date',
                              color: const Color(0xFF3B82F6),
                              onTap: processingAction == null
                                  ? handleRedoPhase
                                  : null,
                              isLoading: processingAction == 'redo',
                              theme: theme,
                            ),
                            const SizedBox(height: 12),
                            // Create New Plan Option
                            _buildActionCard(
                              icon: Icons.add_circle_outline,
                              title: 'Create New Plan',
                              description:
                                  'Start fresh with a completely new quit plan',
                              color: theme.primaryColor,
                              onTap: processingAction == null
                                  ? handleCreateNewPlan
                                  : null,
                              isLoading: processingAction == 'create',
                              theme: theme,
                              isPrimary: true,
                            ),
                            const SizedBox(height: 18),
                            // Cancel Button
                            Center(
                              child: TextButton(
                                onPressed: processingAction == null
                                    ? () => Navigator.of(context).pop()
                                    : null,
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showCreateNewPlanDialog(PhaseTheme theme) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final dateController = TextEditingController();
    bool useNRT = false;
    DateTime? selectedDate;
    bool isProcessing = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> selectDate() async {
              final now = DateTime.now();
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(now.year, now.month, now.day),
                lastDate: now.add(const Duration(days: 365)),
                helpText: 'Select Start Date',
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF00D09E),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null) {
                setDialogState(() {
                  selectedDate = pickedDate;
                  dateController.text = DateFormat(
                    'yyyy-MM-dd',
                  ).format(pickedDate);
                });
              }
            }

            Future<void> handleCreate() async {
              if (!formKey.currentState!.validate()) {
                return;
              }

              if (selectedDate == null) {
                _showSnack('Please select a start date', isError: true);
                return;
              }

              setDialogState(() {
                isProcessing = true;
              });

              try {
                final request = CreateNewQuitPlanRequest(
                  startDate: dateController.text,
                  useNRT: useNRT,
                  quitPlanName: nameController.text.trim(),
                );

                await ref
                    .read(quitPlanViewModelProvider.notifier)
                    .createNewPlan(request);

                if (!mounted) return;

                Navigator.of(context).pop();
                _showSnack('New quit plan created successfully! 🎉');

                // Show form metric dialog to create new form metric
                await _showCreateFormMetricDialog();

                // Refresh quit plan data
                ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
              } catch (e) {
                setDialogState(() {
                  isProcessing = false;
                });
                _showSnack(
                  'Failed to create new plan: ${_errorMessage(e)}',
                  isError: true,
                );
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              elevation: 8,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: theme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.add_circle_outline,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Create New Quit Plan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey),
                              onPressed: isProcessing
                                  ? null
                                  : () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Plan Name Field
                        TextFormField(
                          controller: nameController,
                          enabled: !isProcessing,
                          decoration: InputDecoration(
                            labelText: 'Quit Plan Name',
                            hintText: 'Enter quit plan name',
                            prefixIcon: Icon(
                              Icons.label_outline,
                              color: theme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter quit plan name';
                            }
                            if (value.trim().length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Start Date Field
                        TextFormField(
                          controller: dateController,
                          enabled: !isProcessing,
                          readOnly: true,
                          onTap: selectDate,
                          decoration: InputDecoration(
                            labelText: 'Start Date',
                            hintText: 'Select start date',
                            prefixIcon: Icon(
                              Icons.calendar_today,
                              color: theme.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: theme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select start date';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Use NRT Toggle
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.medical_services_outlined,
                                color: theme.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Use NRT',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Nicotine Replacement Therapy',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: useNRT,
                                onChanged: isProcessing
                                    ? null
                                    : (value) {
                                        setDialogState(() {
                                          useNRT = value;
                                        });
                                      },
                                activeColor: theme.primaryColor,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: isProcessing
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(
                                    color: Colors.grey.shade300,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: isProcessing ? null : handleCreate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: isProcessing
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text(
                                        'Create',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    dateController.dispose();
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

      if (base == 'fm_cigarettes_total') {
        if (fmCigarettesTotal > 0) {
          final computed = fmCigarettesTotal * percent;
          final computedRounded = computed.toStringAsFixed(1);
          // Show the computed value prominently with clear explanation
          return 'Must be $operator $computedRounded cigarettes\n($percentLabel% of your baseline: ${fmCigarettesTotal.toStringAsFixed(0)} cigarettes)';
        } else {
          // If baseline is not available, still show the percentage
          return 'Must be $operator $percentLabel% of baseline total cigarettes';
        }
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

  String _errorMessage(Object error) {
    final message = error.toString();
    return message.replaceFirst('Exception: ', '');
  }

  Future<void> _showCreateFormMetricDialog() async {
    // Create default form metric data for new creation
    final defaultFormMetric = FormMetricDTO(
      id: 0,
      smokeAvgPerDay: 0,
      numberOfYearsOfSmoking: 0,
      cigarettesPerPackage: 0,
      minutesAfterWakingToSmoke: 0,
      smokingInForbiddenPlaces: false,
      cigaretteHateToGiveUp: false,
      morningSmokingFrequency: false,
      smokeWhenSick: false,
      moneyPerPackage: 0,
      estimatedMoneySavedOnPlan: 0,
      amountOfNicotinePerCigarettes: 0,
      estimatedNicotineIntakePerDay: 0,
      interests: [],
      triggered: [],
    );

    if (!mounted) return;

    final updatedData = await Navigator.push<FormMetricDTO>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditFormMetricDialog(currentData: defaultFormMetric),
        fullscreenDialog: true,
      ),
    );

    if (updatedData != null && mounted) {
      try {
        // Create form metric using updateFormMetric API (which creates if doesn't exist)
        final request = UpdateFormMetricRequest(
          smokeAvgPerDay: updatedData.smokeAvgPerDay,
          numberOfYearsOfSmoking: updatedData.numberOfYearsOfSmoking,
          cigarettesPerPackage: updatedData.cigarettesPerPackage,
          minutesAfterWakingToSmoke: updatedData.minutesAfterWakingToSmoke,
          smokingInForbiddenPlaces: updatedData.smokingInForbiddenPlaces,
          cigaretteHateToGiveUp: updatedData.cigaretteHateToGiveUp,
          morningSmokingFrequency: updatedData.morningSmokingFrequency,
          smokeWhenSick: updatedData.smokeWhenSick,
          moneyPerPackage: updatedData.moneyPerPackage,
          estimatedMoneySavedOnPlan: updatedData.estimatedMoneySavedOnPlan,
          amountOfNicotinePerCigarettes:
              updatedData.amountOfNicotinePerCigarettes,
          estimatedNicotineIntakePerDay:
              updatedData.estimatedNicotineIntakePerDay,
          interests: updatedData.interests,
          triggered: updatedData.triggered,
        );

        final response = await ref
            .read(formMetricViewModelProvider.notifier)
            .updateFormMetric(request: request);

        if (response != null && mounted) {
          _showSnack('Form metric created successfully! ✅');
        } else {
          _showSnack('Failed to create form metric', isError: true);
        }
      } catch (e) {
        if (mounted) {
          _showSnack(
            'Failed to create form metric: ${_errorMessage(e)}',
            isError: true,
          );
        }
      }
    }
  }
}

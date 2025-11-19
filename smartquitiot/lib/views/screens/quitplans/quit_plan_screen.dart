import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:another_flushbar/flushbar.dart';
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
import '../form_metric/_create_form_metric_dialog.dart';
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
  final Set<int> _notifiedNewPhases =
      <int>{}; // Track new phases that already showed notification
  List<QuitPhaseDetail>?
  _previousPhases; // Track previous phases to detect new ones

  int? _phaseActionInProgressId;
  String? _phaseActionInProgressType;

  static const String _phaseActionKeepKey = 'keep';
  static const String _phaseActionRedoKey = 'redo';

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
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: isError ? Colors.redAccent : const Color(0xFF00D09E),
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
  }

  void _setPhaseActionLoading(int? phaseId, String? actionKey) {
    if (!mounted) return;
    setState(() {
      _phaseActionInProgressId = phaseId;
      _phaseActionInProgressType = actionKey;
    });
  }

  bool _isPhaseActionLoading(int? phaseId, String actionKey) {
    return _phaseActionInProgressId == phaseId &&
        _phaseActionInProgressType == actionKey;
  }

  bool get _hasPhaseActionInProgress =>
      _phaseActionInProgressId != null && _phaseActionInProgressType != null;

  Future<T> _withBlockingLoader<T>(
    Future<T> Function() task, {
    String message = 'Processing...',
  }) async {
    if (!mounted) {
      return await task();
    }

    bool overlayOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: _BlockingLoader(message: message),
      ),
    ).whenComplete(() {
      overlayOpen = false;
    });

    try {
      return await task();
    } finally {
      if (overlayOpen && mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  Future<void> _handleKeepPhaseAction(
    QuitPhase plan,
    QuitPhaseDetail phase,
  ) async {
    final planId = plan.id;
    final phaseId = phase.id;
    if (planId == null || phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    _setPhaseActionLoading(phaseId, _phaseActionKeepKey);

    try {
      await _withBlockingLoader(() async {
        await ref
            .read(quitPlanViewModelApiProvider.notifier)
            .keepPhase(quitPlanId: planId, phaseId: phaseId);
      });
      if (!mounted) return;
      _showSnack('Phase kept successfully.');
      await Future.delayed(const Duration(seconds: 5));
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      _showSnack('Keep phase failed: ${_errorMessage(e)}', isError: true);
    } finally {
      _setPhaseActionLoading(null, null);
    }
  }

  Future<void> _handleRedoPhaseAction(QuitPhaseDetail phase) async {
    final phaseId = phase.id;
    if (phaseId == null) {
      _showSnack('Missing phase information.', isError: true);
      return;
    }

    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Choose restart date',
    );

    if (selectedDate == null) {
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    _setPhaseActionLoading(phaseId, _phaseActionRedoKey);

    try {
      await _withBlockingLoader(() async {
        await ref
            .read(quitPlanViewModelApiProvider.notifier)
            .redoPhase(phaseId: phaseId, anchorStart: formattedDate);
      });
      if (!mounted) return;
      _showSnack('Phase restarted from $formattedDate.');
      ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
    } catch (e) {
      _showSnack('Redo phase failed: ${_errorMessage(e)}', isError: true);
    } finally {
      _setPhaseActionLoading(null, null);
    }
  }

  /// Check if there's a new phase created after a failed phase (redo scenario)
  bool _hasNewPhaseAfterFailed(
    QuitPhaseDetail failedPhase,
    List<QuitPhaseDetail> allPhases,
  ) {
    if (!_isFailedStatus(failedPhase.status)) return false;

    final failedPhaseName = failedPhase.name ?? '';
    final failedPhaseId = failedPhase.id;
    if (failedPhaseName.isEmpty || failedPhaseId == null) return false;

    // Find if there's a phase with the same name but different status (CREATED or IN_PROGRESS)
    // and created after the failed phase
    for (final phase in allPhases) {
      if (phase.id == failedPhaseId) continue; // Skip the failed phase itself
      if (phase.name != failedPhaseName) continue; // Must be same phase name

      // Check if it's a new phase (CREATED or IN_PROGRESS) that was created after the failed phase
      final isNewPhase =
          phase.status == 'CREATED' || phase.status == 'IN_PROGRESS';
      if (isNewPhase) {
        // Check if startDate is after failed phase's endDate (or created after)
        try {
          if (failedPhase.endDate != null && phase.startDate != null) {
            final failedEndDate = DateTime.parse(failedPhase.endDate!);
            final newStartDate = DateTime.parse(phase.startDate!);
            if (newStartDate.isAfter(failedEndDate) ||
                newStartDate.isAtSameMomentAs(failedEndDate)) {
              return true;
            }
          }
          // If dates are not available, check by createdAt
          if (failedPhase.createdAt != null && phase.createdAt != null) {
            final failedCreatedAt = DateTime.parse(failedPhase.createdAt!);
            final newCreatedAt = DateTime.parse(phase.createdAt!);
            if (newCreatedAt.isAfter(failedCreatedAt)) {
              return true;
            }
          }
        } catch (e) {
          // If date parsing fails, assume it's a new phase if status matches
          if (isNewPhase) return true;
        }
      }
    }
    return false;
  }

  /// Detect new phases and show notification
  void _detectAndNotifyNewPhases(List<QuitPhaseDetail> currentPhases) {
    if (_previousPhases == null) {
      _previousPhases = List.from(currentPhases);
      return;
    }

    // Find new phases that weren't in previous list
    final previousPhaseIds = _previousPhases!.map((p) => p.id).toSet();
    final newPhases = currentPhases.where((phase) {
      final phaseId = phase.id;
      if (phaseId == null) return false;
      if (previousPhaseIds.contains(phaseId)) return false;
      if (_notifiedNewPhases.contains(phaseId)) return false;
      // Only notify for CREATED or IN_PROGRESS phases
      return phase.status == 'CREATED' || phase.status == 'IN_PROGRESS';
    }).toList();

    // Check for phases that were redo (same name as failed phase)
    for (final phase in currentPhases) {
      if (_isFailedStatus(phase.status)) {
        if (_hasNewPhaseAfterFailed(phase, currentPhases)) {
          // Find the new phase
          final newPhase = currentPhases.firstWhere(
            (p) =>
                p.name == phase.name &&
                p.id != phase.id &&
                (p.status == 'CREATED' || p.status == 'IN_PROGRESS'),
            orElse: () => phase,
          );
          if (newPhase.id != null &&
              newPhase.id != phase.id &&
              !_notifiedNewPhases.contains(newPhase.id)) {
            _notifiedNewPhases.add(newPhase.id!);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                _showSnack(
                  '✨ New phase "${newPhase.name ?? 'Phase'}" has been created! You can continue your journey.',
                );
              }
            });
          }
        }
      }
    }

    // Notify about completely new phases
    for (final newPhase in newPhases) {
      final phaseId = newPhase.id;
      if (phaseId != null && !_notifiedNewPhases.contains(phaseId)) {
        _notifiedNewPhases.add(phaseId);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showSnack(
              '✨ New phase "${newPhase.name ?? 'Phase'}" has been created!',
            );
          }
        });
      }
    }

    _previousPhases = List.from(currentPhases);
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

    // Detect new phases after redo and show notification
    state.when(
      data: (data) {
        if (data != null && data.phases != null) {
          _detectAndNotifyNewPhases(data.phases!);
        }
      },
      loading: () {},
      error: (_, __) {},
    );

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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(quitPlanViewModelApiProvider.notifier).loadQuitPlan();
            },
            tooltip: 'Refresh Quit Plan',
          ),
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
          // TODO: Temporarily allow viewing even when isActive is false
          if (data == null ||
              // data.active == false ||  // Temporarily disabled
              (data.phases?.isEmpty ?? true)) {
            return const Center(child: Text('No quit plan found'));
          }

          final phases = data.phases!;
          // Sort phases: redo phases appear right after their failed phase
          final sortedPhases = _sortPhases(phases);
          final isCompleted = _isQuitPlanCompleted(data, sortedPhases);
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(data),
                if (isCompleted) _buildCongratulationsBanner(data),
                _buildStats(sortedPhases),
                _buildPhasesList(sortedPhases, data),
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
        final shouldShowFailedActions =
            _isFailedStatus(phase.status) && !(phase.keepPhase ?? false);
        final shouldShowKeptBanner =
            _isFailedStatus(phase.status) && (phase.keepPhase ?? false);

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
              if (isExpanded && shouldShowFailedActions) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildFailedPhaseActionsInline(
                    plan,
                    phase,
                    phaseTheme,
                  ),
                ),
              ] else if (shouldShowKeptBanner) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildKeptPhaseBanner(phaseTheme),
                ),
              ],
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

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    // Try to get smokeAvgPerDay from formMetricDTO if available
                    // Otherwise calculate from fmCigarettesTotal / durationDay
                    _calculateSmokeAvgPerDay(
                      phase.fmCigarettesTotal ?? 0,
                      phase.durationDay ?? 0,
                    ),
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
              _buildMissionsList(days[selectedDayIndex], theme),
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

  bool _isPastOrToday(String? dateString) {
    if (dateString == null || dateString.isEmpty) return false;
    try {
      final date = DateTime.parse(dateString);
      final targetDate = DateTime(date.year, date.month, date.day);
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      return targetDate.isBefore(todayDate) ||
          targetDate.isAtSameMomentAs(todayDate);
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

  Widget _buildMissionsList(QuitDay day, PhaseTheme theme) {
    final missions = day.missions ?? [];
    if (missions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('No missions for this day')),
      );
    }

    final isSelectedDayToday = _isToday(day.date);
    final isDayAvailableForCompletion = _isPastOrToday(day.date);
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
                      onPressed: isDayAvailableForCompletion
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
                        backgroundColor: isDayAvailableForCompletion
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
                        isDayAvailableForCompletion
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
    int smokeAvgPerDay,
  ) {
    final rules = condition.rules ?? [];

    // Calculate baseline total: use fmCigarettesTotal if available, otherwise calculate from smokeAvgPerDay * durationDay
    double baselineTotal = fmCigarettesTotal;
    if (baselineTotal <= 0 && smokeAvgPerDay >= 0 && durationDay >= 0) {
      baselineTotal = (smokeAvgPerDay * durationDay).toDouble();
    }

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

  Widget _buildFailedPhaseActionsInline(
    QuitPhase plan,
    QuitPhaseDetail phase,
    PhaseTheme theme,
  ) {
    final phaseId = phase.id;
    final keepLoading = _isPhaseActionLoading(phaseId, _phaseActionKeepKey);
    final redoLoading = _isPhaseActionLoading(phaseId, _phaseActionRedoKey);
    final actionsDisabled = _hasPhaseActionInProgress || phaseId == null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
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
                  color: Colors.redAccent.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline, color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phase failed',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose how you want to continue your quit journey.',
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Action required',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            children: [
              _buildActionCard(
                title: 'Keep Phase',
                description: 'Preserve all missions and continue',
                icon: Icons.layers_outlined,
                color: const Color(0xFF10B981),
                onTap: actionsDisabled
                    ? null
                    : () => _handleKeepPhaseAction(plan, phase),
                isLoading: keepLoading,
                theme: theme,
              ),
              _buildActionCard(
                title: 'Redo Phase',
                description: 'Restart with a fresh anchor date',
                icon: Icons.restart_alt,
                color: const Color(0xFF0EA5E9),
                onTap: actionsDisabled
                    ? null
                    : () => _handleRedoPhaseAction(phase),
                isLoading: redoLoading,
                theme: theme,
              ),
              _buildActionCard(
                title: 'New Plan',
                description: 'Start a brand new quit journey',
                icon: Icons.auto_awesome,
                color: const Color(0xFF8B5CF6),
                onTap: _hasPhaseActionInProgress
                    ? null
                    : () => _showCreateNewPlanDialog(theme),
                isLoading: false,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isLoading,
    required PhaseTheme theme,
  }) {
    final effectiveBorderColor = isLoading
        ? Colors.grey.shade300
        : color.withOpacity(0.4);
    final titleColor = color;
    final descriptionColor = color.withOpacity(0.75);

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isLoading ? 0.6 : 1,
        child: Container(
          width: 260,
          constraints: const BoxConstraints(minHeight: 130),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: effectiveBorderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: 26,
                          height: 26,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        )
                      : Icon(icon, color: color, size: 26),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: descriptionColor,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeptPhaseBanner(PhaseTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.primaryColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.done_all, color: theme.primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Phase kept',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Continue with your saved progress. Actions are no longer needed.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
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

                await _withBlockingLoader(() async {
                  await ref
                      .read(quitPlanViewModelProvider.notifier)
                      .createNewPlan(request);
                }, message: 'Creating quit plan...');

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

  /// Check if quit plan is completed
  bool _isQuitPlanCompleted(QuitPhase plan, List<QuitPhaseDetail> phases) {
    // Check if plan status is COMPLETED
    if (plan.status != null && plan.status!.toUpperCase() == 'COMPLETED') {
      return true;
    }

    // Check if all phases are completed, especially the last Maintenance phase
    if (phases.isEmpty) return false;

    // Check if the last phase is Maintenance and completed
    final lastPhase = phases.last;
    final isLastPhaseMaintenance = (lastPhase.name ?? '')
        .toLowerCase()
        .contains('maintenance');
    final isLastPhaseCompleted =
        lastPhase.status != null &&
        lastPhase.status!.toUpperCase() == 'COMPLETED';

    if (isLastPhaseMaintenance && isLastPhaseCompleted) {
      return true;
    }

    // Also check if all phases are completed
    final allPhasesCompleted = phases.every(
      (phase) =>
          phase.status != null && phase.status!.toUpperCase() == 'COMPLETED',
    );

    return allPhasesCompleted;
  }

  /// Build congratulations banner when quit plan is completed
  Widget _buildCongratulationsBanner(QuitPhase plan) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00D09E), Color(0xFF00B894)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('🎉', style: TextStyle(fontSize: 32)),
              SizedBox(width: 8),
              Text('🎆', style: TextStyle(fontSize: 28)),
              SizedBox(width: 8),
              Text('✨', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Congratulations!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have successfully completed your quit plan!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.name ?? 'Quit Plan',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'You are now smoke-free! Keep up the amazing work! 💪',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  /// Calculate smokeAvgPerDay from fmCigarettesTotal and durationDay
  int _calculateSmokeAvgPerDay(double fmCigarettesTotal, int durationDay) {
    if (durationDay > 0 && fmCigarettesTotal > 0) {
      return (fmCigarettesTotal / durationDay).round();
    }
    return 0;
  }

  /// Sort phases so that redo phases appear right after their failed phase
  /// Primary sort: by startDate
  /// Secondary: if phase failed has a redo phase, place redo phase immediately after
  List<QuitPhaseDetail> _sortPhases(List<QuitPhaseDetail> phases) {
    if (phases.isEmpty) return phases;

    // Create a copy to avoid modifying original list
    final sorted = List<QuitPhaseDetail>.from(phases);

    // First, sort by startDate
    sorted.sort((a, b) {
      final aStart = a.startDate;
      final bStart = b.startDate;
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      try {
        final aDate = DateTime.parse(aStart);
        final bDate = DateTime.parse(bStart);
        return aDate.compareTo(bDate);
      } catch (e) {
        return 0;
      }
    });

    // Then, reorganize: if a failed phase has a redo phase, move redo phase right after it
    final result = <QuitPhaseDetail>[];
    final processedIds = <int>{};

    for (int i = 0; i < sorted.length; i++) {
      final phase = sorted[i];
      final phaseId = phase.id;
      if (phaseId == null || processedIds.contains(phaseId)) continue;

      // If this is a failed phase, check if there's a redo phase
      if (_isFailedStatus(phase.status)) {
        result.add(phase);
        processedIds.add(phaseId);

        // Find redo phase (same name, different id, CREATED or IN_PROGRESS)
        final phaseName = phase.name ?? '';
        if (phaseName.isNotEmpty) {
          // Search through all phases to find the redo phase
          for (final candidate in sorted) {
            final candidateId = candidate.id;
            if (candidateId == null || processedIds.contains(candidateId))
              continue;

            // Check if this is a redo phase of the failed phase
            if (candidate.name == phaseName &&
                candidateId != phaseId &&
                (candidate.status == 'CREATED' ||
                    candidate.status == 'IN_PROGRESS')) {
              // Check if it's created after the failed phase
              if (_hasNewPhaseAfterFailed(phase, sorted)) {
                result.add(candidate);
                processedIds.add(candidateId);
                break; // Only take the first matching redo phase
              }
            }
          }
        }
      } else {
        // Regular phase - check if it's not a redo of a failed phase we already processed
        final phaseName = phase.name ?? '';
        bool isRedoOfProcessedFailed = false;

        if (phaseName.isNotEmpty) {
          // Check if this phase is a redo of a failed phase we already added
          for (final processedPhase in result) {
            if (_isFailedStatus(processedPhase.status) &&
                processedPhase.name == phaseName &&
                processedPhase.id != phaseId) {
              // Check if this phase is the redo
              if ((phase.status == 'CREATED' ||
                      phase.status == 'IN_PROGRESS') &&
                  _hasNewPhaseAfterFailed(processedPhase, sorted)) {
                isRedoOfProcessedFailed = true;
                break;
              }
            }
          }
        }

        if (!isRedoOfProcessedFailed) {
          result.add(phase);
          processedIds.add(phaseId);
        }
      }
    }

    // Add any remaining phases that weren't processed
    for (final phase in sorted) {
      final phaseId = phase.id;
      if (phaseId != null && !processedIds.contains(phaseId)) {
        result.add(phase);
        processedIds.add(phaseId);
      }
    }

    return result;
  }

  Future<void> _showCreateFormMetricDialog() async {
    if (!mounted) return;

    // Use CreateFormMetricDialog (required, cannot be dismissed)
    final formMetricData = await Navigator.push<FormMetricDTO>(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateFormMetricDialog(),
        fullscreenDialog: true,
      ),
    );

    if (formMetricData != null && mounted) {
      try {
        // Create form metric using updateFormMetric API (which creates if doesn't exist)
        final request = UpdateFormMetricRequest(
          smokeAvgPerDay: formMetricData.smokeAvgPerDay,
          numberOfYearsOfSmoking: formMetricData.numberOfYearsOfSmoking,
          cigarettesPerPackage: formMetricData.cigarettesPerPackage,
          minutesAfterWakingToSmoke: formMetricData.minutesAfterWakingToSmoke,
          smokingInForbiddenPlaces: formMetricData.smokingInForbiddenPlaces,
          cigaretteHateToGiveUp: formMetricData.cigaretteHateToGiveUp,
          morningSmokingFrequency: formMetricData.morningSmokingFrequency,
          smokeWhenSick: formMetricData.smokeWhenSick,
          moneyPerPackage: formMetricData.moneyPerPackage,
          estimatedMoneySavedOnPlan: formMetricData.estimatedMoneySavedOnPlan,
          amountOfNicotinePerCigarettes:
              formMetricData.amountOfNicotinePerCigarettes,
          estimatedNicotineIntakePerDay:
              formMetricData.estimatedNicotineIntakePerDay,
          interests: formMetricData.interests,
          triggered: formMetricData.triggered,
        );

        final response = await _withBlockingLoader(() async {
          return await ref
              .read(formMetricViewModelProvider.notifier)
              .updateFormMetric(request: request);
        }, message: 'Saving form metric...');

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

class _BlockingLoader extends StatelessWidget {
  final String message;

  const _BlockingLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.75),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 42,
                height: 42,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/quit_plan_provider.dart';
import '../../../models/quit_phase.dart';
import '../../widgets/mission_complete_dialog.dart';
import '../diary/diary_screen.dart';

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

  final phaseColors = [
    const Color(0xFF00D09E),
    const Color(0xFF3B82F6),
    const Color(0xFFF59E0B),
    const Color(0xFF8B5CF6),
    const Color(0xFF10B981),
  ];

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

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Quit Plan'),
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
        elevation: 0,
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
          if (data == null || (data.phases?.isEmpty ?? true)) {
            return const Center(child: Text('No quit plan found'));
          }

          final phases = data.phases!;
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(data),
                _buildStats(phases),
                _buildPhasesList(phases),
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

  Widget _buildPhasesList(List<QuitPhaseDetail> phases) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: phases.length,
      itemBuilder: (context, index) {
        final phase = phases[index];
        final color = phaseColors[index % phaseColors.length];
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
            side: BorderSide(color: Colors.grey[200]!, width: 1),
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
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getPhaseIcon(phase.name ?? ''),
                              color: color,
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
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Progress bar giai đoạn
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: phaseProgress.clamp(0.0, 1.0),
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation(color),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '$phasePercent% completed',
                            style: TextStyle(fontSize: 10, color: color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) _buildPhaseDetails(phase, color),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhaseDetails(QuitPhaseDetail phase, Color color) {
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
                color: color.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: color, size: 16),
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
                        color: isSelected ? color : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
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
                              color: isSelected ? Colors.white70 : color,
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
              _buildMissionsList(days[selectedDayIndex].missions ?? [], color),
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

  Widget _buildMissionsList(List<QuitMissionItem> missions, Color color) {
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
        // Congratulations message for completed daily missions
        if (showCongratulations)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withOpacity(0.1),
                  Colors.green.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '🎉',
                      style: TextStyle(fontSize: 24),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '🎆',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '✨',
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'You have completed all missions for today!\nCome back tomorrow for new challenges.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        // Missions list
        ...missions.map((mission) {
        final missionId = mission.id ?? -1;
        final completed =
            mission.status == 'COMPLETED' ||
            locallyCompletedMissionIds.contains(missionId);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: completed ? Colors.green.withOpacity(0.05) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: completed ? Colors.green : Colors.grey[300]!,
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
                    color: completed ? Colors.green : color,
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
                            // Get current phase ID from the selected phase
                            final quitPhaseState = ref.read(quitPlanViewModelApiProvider);
                            quitPhaseState.when(
                              data: (quitPhase) {
                                if (quitPhase != null && quitPhase.phases != null && selectedPhaseIndex < quitPhase.phases!.length) {
                                  final currentPhase = quitPhase.phases![selectedPhaseIndex];
                                  _showMissionCompleteDialog(mission, currentPhase.id ?? 0);
                                }
                              },
                              loading: () {},
                              error: (error, stack) {},
                            );
                          }
                        : null, // Disable button for future days
                    style: TextButton.styleFrom(
                      backgroundColor: isSelectedDayToday ? color : Colors.grey,
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
                      isSelectedDayToday ? 'Complete Mission' : 'Not Available Yet',
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

  String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return '';
  try {
    final date = DateTime.parse(dateString);
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  } catch (e) {
    return dateString; // fallback nếu parse lỗi
  }
}


  IconData _getPhaseIcon(String phaseName) {
    switch (phaseName.toLowerCase()) {
      case 'preparation':
        return Icons.settings;
      case 'onset':
        return Icons.play_arrow;
      case 'peak craving':
        return Icons.whatshot;
      case 'subsiding':
        return Icons.trending_down;
      case 'maintenance':
        return Icons.health_and_safety;
      default:
        return Icons.flag;
    }
  }
}

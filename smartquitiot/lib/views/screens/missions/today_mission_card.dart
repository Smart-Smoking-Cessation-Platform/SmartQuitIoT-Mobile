import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewmodels/today_mission_view_model.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';
import '../../../providers/mission_refresh_provider.dart';
import '../quitplans/quit_plan_screen.dart';

class TodayMissionCard extends ConsumerStatefulWidget {
  const TodayMissionCard({super.key});

  @override
  ConsumerState<TodayMissionCard> createState() => _TodayMissionCardState();
}

class _TodayMissionCardState extends ConsumerState<TodayMissionCard> {
  bool _hasLoadedMissions = false;
  bool _lastQuitPlanState = false; // Track previous quit plan state

  @override
  void initState() {
    super.initState();
    // Don't load missions here - wait for quit plan to load first
    print('📋 [TodayMissionCard] Initialized, waiting for quit plan...');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(todayMissionViewModelProvider);
    final quitPlanState = ref.watch(quitPlanHomepageViewModelProvider);

    // Debug current states
    print(
      '🔍 [TodayMissionCard] States - hasQuitPlan: ${quitPlanState.hasQuitPlan}, isLoading: ${quitPlanState.isLoading}, hasLoadedMissions: $_hasLoadedMissions, lastQuitPlanState: $_lastQuitPlanState',
    );

    // Load missions AFTER quit plan is loaded and ready
    if (!_hasLoadedMissions &&
        quitPlanState.hasQuitPlan &&
        !quitPlanState.isLoading) {
      print('✅ [TodayMissionCard] Quit plan loaded, now loading missions...');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(todayMissionViewModelProvider.notifier).loadTodayMissions();
        _hasLoadedMissions = true;
        _lastQuitPlanState = true;
      });
    }

    // Detect when quit plan state changes from false to true (new quit plan created)
    if (!_lastQuitPlanState &&
        quitPlanState.hasQuitPlan &&
        !quitPlanState.isLoading) {
      print(
        '🆕 [TodayMissionCard] New quit plan detected! Retrying missions...',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(todayMissionViewModelProvider.notifier).refreshMissions();
        _hasLoadedMissions = true;
        _lastQuitPlanState = true;
      });
    }

    // Handle case when quit plan is lost (e.g., logout/login)
    if (_lastQuitPlanState &&
        !quitPlanState.hasQuitPlan &&
        !quitPlanState.isLoading) {
      print('⚠️ [TodayMissionCard] Quit plan lost, resetting mission state...');
      _hasLoadedMissions = false;
      _lastQuitPlanState = false;
    }

    // Update last quit plan state
    _lastQuitPlanState = quitPlanState.hasQuitPlan;

    // Listen for mission refresh trigger
    ref.listen(missionRefreshProvider, (previous, next) {
      if (previous != next) {
        print('🔄 [TodayMissionCard] Refresh triggered by provider');
        // Reset loading state to allow fresh load
        _hasLoadedMissions = false;
        // Refresh missions when trigger changes
        ref.read(todayMissionViewModelProvider.notifier).refreshMissions();
        _hasLoadedMissions = true;
      }
    });

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
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
                'Today Missions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
                    );
                  },
                  child: const Text(
                    'View More',
                    style: TextStyle(
                      color: Color(0xFF00D09E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildContent(state),
        ],
      ),
    );
  }

  Widget _buildContent(state) {
    final quitPlanState = ref.watch(quitPlanHomepageViewModelProvider);

    // Show loading only if we're actually loading missions
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
      );
    }

    // If no quit plan exists, show appropriate message
    if (!quitPlanState.hasQuitPlan && !quitPlanState.isLoading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Please complete your quit plan setup to see today\'s missions',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
            ),
          ],
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
        child: Column(
          children: [
            Row(
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(todayMissionViewModelProvider.notifier)
                      .refreshMissions();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ),
      );
    }

    if (state.allMissionsCompleted) {
      return _buildCongratulationsMessage();
    }

    if (!state.hasMissions) {
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
                'No missions available today',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: state.missions.map<Widget>((mission) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const QuitPlanScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.15),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.self_improvement,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mission.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 16,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCongratulationsMessage() {
    return Container(
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
            color: const Color(0xFF00D09E).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, color: Colors.white, size: 48),
          const SizedBox(height: 16),
          const Text(
            '🎉 Outstanding Achievement!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'You\'ve conquered all today\'s missions!\nYour dedication is truly inspiring.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '✨ Every step forward is a victory against smoking.\nCome back tomorrow for new challenges!',
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton(
          //     onPressed: () {
          //       ref.read(todayMissionViewModelProvider.notifier).refreshMissions();
          //     },
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.white,
          //       foregroundColor: const Color(0xFF00D09E),
          //       padding: const EdgeInsets.symmetric(vertical: 12),
          //       shape: RoundedRectangleBorder(
          //         borderRadius: BorderRadius.circular(8),
          //       ),
          //     ),
          //     child: const Text(
          //       'Check for New Missions',
          //       style: TextStyle(
          //         fontWeight: FontWeight.w600,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}

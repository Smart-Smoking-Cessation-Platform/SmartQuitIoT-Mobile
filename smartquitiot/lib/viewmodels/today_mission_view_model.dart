import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/today_mission_state.dart';
import '../repositories/today_mission_repository.dart';

class TodayMissionViewModel extends StateNotifier<TodayMissionState> {
  final TodayMissionRepository _todayMissionRepository;

  TodayMissionViewModel(this._todayMissionRepository) : super(const TodayMissionState());

  /// Load today's missions (only incompleted ones)
  Future<void> loadTodayMissions() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // First check if all missions are completed
      final allCompleted = await _todayMissionRepository.areAllMissionsCompleted();
      
      if (allCompleted) {
        // If all completed, set empty missions list and flag
        state = state.copyWith(
          missions: [],
          isLoading: false,
          error: null,
          allMissionsCompleted: true,
        );
        print('✅ [TodayMissionViewModel] All missions completed');
      } else {
        // Load incompleted missions
        final missions = await _todayMissionRepository.getTodayMissions();
        state = state.copyWith(
          missions: missions,
          isLoading: false,
          error: null,
          allMissionsCompleted: false,
        );
        print('✅ [TodayMissionViewModel] Loaded ${missions.length} incompleted missions');
      }
    } catch (e, st) {
      print('🔥 [TodayMissionViewModel] Load missions error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        allMissionsCompleted: false,
      );
    }
  }

  /// Refresh missions
  Future<void> refreshMissions() async {
    await loadTodayMissions();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod providers
final todayMissionRepositoryProvider = Provider<TodayMissionRepository>((ref) {
  return TodayMissionRepository();
});

final todayMissionViewModelProvider = StateNotifierProvider<TodayMissionViewModel, TodayMissionState>((ref) {
  final repository = ref.watch(todayMissionRepositoryProvider);
  return TodayMissionViewModel(repository);
});

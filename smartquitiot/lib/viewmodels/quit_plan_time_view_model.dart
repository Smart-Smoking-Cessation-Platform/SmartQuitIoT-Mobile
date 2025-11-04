import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/quit_plan_time_repository.dart';

class QuitPlanTimeState {
  final DateTime? startTime;
  final bool isLoading;
  final String? error;

  QuitPlanTimeState({
    this.startTime,
    this.isLoading = false,
    this.error,
  });

  QuitPlanTimeState copyWith({
    DateTime? startTime,
    bool? isLoading,
    String? error,
  }) {
    return QuitPlanTimeState(
      startTime: startTime ?? this.startTime,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class QuitPlanTimeViewModel extends StateNotifier<QuitPlanTimeState> {
  final QuitPlanTimeRepository _repository;

  QuitPlanTimeViewModel(this._repository) : super(QuitPlanTimeState());

  Future<void> loadStartTime() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final startTime = await _repository.getStartTime();
      state = state.copyWith(
        startTime: startTime,
        isLoading: false,
      );
      print('✅ [QuitPlanTimeViewModel] Start time loaded: $startTime');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      print('❌ [QuitPlanTimeViewModel] Error: $e');
    }
  }

  void refresh() {
    loadStartTime();
  }
}

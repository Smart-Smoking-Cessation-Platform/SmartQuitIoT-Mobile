import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/quit_plan_repository.dart';
import '../models/quit_phase.dart';

class QuitPhaseViewModel extends StateNotifier<AsyncValue<QuitPhase?>> {
  final QuitPlanRepository repository;

  QuitPhaseViewModel(this.repository) : super(const AsyncValue.loading());

  Future<void> loadQuitPlan() async {
    try {
      state = const AsyncValue.loading();
      final result = await repository.getQuitPlan();
      final phase = QuitPhase.fromJson(result);
      state = AsyncValue.data(phase);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

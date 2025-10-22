import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/state/quit_plan_homepage_state.dart';
import '../repositories/quit_plan_homepage_repository.dart';

class QuitPlanHomepageViewModel extends StateNotifier<QuitPlanHomepageState> {
  final QuitPlanHomepageRepository _quitPlanHomepageRepository;

  QuitPlanHomepageViewModel(this._quitPlanHomepageRepository) : super(const QuitPlanHomepageState());

  /// Load quit plan home page data
  Future<void> loadQuitPlanHomePage() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final quitPlan = await _quitPlanHomepageRepository.getQuitPlanHomePage();
      state = state.copyWith(
        quitPlan: quitPlan,
        isLoading: false,
        error: null,
      );
      print('✅ [QuitPlanHomepageViewModel] Loaded quit plan: ${quitPlan.name}');
    } catch (e, st) {
      print('🔥 [QuitPlanHomepageViewModel] Load quit plan error: $e\n$st');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh quit plan data
  Future<void> refreshQuitPlan() async {
    await loadQuitPlanHomePage();
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Riverpod providers
final quitPlanHomepageRepositoryProvider = Provider<QuitPlanHomepageRepository>((ref) {
  return QuitPlanHomepageRepository();
});

final quitPlanHomepageViewModelProvider = StateNotifierProvider<QuitPlanHomepageViewModel, QuitPlanHomepageState>((ref) {
  final repository = ref.watch(quitPlanHomepageRepositoryProvider);
  return QuitPlanHomepageViewModel(repository);
});

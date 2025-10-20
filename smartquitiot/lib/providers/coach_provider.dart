import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/coach_repository.dart';
import '../models/coach.dart';

// Repository provider
final coachRepositoryProvider = Provider<CoachRepository>((ref) {
  return CoachRepository();
});

// Coaches list provider
final coachesProvider = FutureProvider<List<Coach>>((ref) async {
  final repository = ref.read(coachRepositoryProvider);
  final response = await repository.getCoaches();

  if (response.success) {
    return response.data;
  } else {
    throw Exception(response.message);
  }
});

// Individual coach provider
final coachProvider = FutureProvider.family<Coach, int>((ref, coachId) async {
  final repository = ref.read(coachRepositoryProvider);
  return await repository.getCoachById(coachId);
});

// Coach list state provider for manual refresh
final coachListStateProvider =
    StateNotifierProvider<CoachListNotifier, AsyncValue<List<Coach>>>((ref) {
      return CoachListNotifier(ref.read(coachRepositoryProvider));
    });

class CoachListNotifier extends StateNotifier<AsyncValue<List<Coach>>> {
  final CoachRepository _repository;

  CoachListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCoaches();
  }

  Future<void> loadCoaches() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getCoaches();

      if (response.success) {
        state = AsyncValue.data(response.data);
      } else {
        state = AsyncValue.error(
          Exception(response.message),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadCoaches();
  }
}

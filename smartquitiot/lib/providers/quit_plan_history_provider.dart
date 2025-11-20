import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/quit_plan_history.dart';
import '../services/quit_plan_history_service.dart';
import '../services/token_storage_service.dart';
import '../repositories/quit_plan_history_repository.dart';
import '../viewmodels/quit_plan_history_view_model.dart';

// Dio Provider
final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// Service Provider
final quitPlanHistoryServiceProvider = Provider<QuitPlanHistoryService>((ref) {
  final dio = ref.watch(dioProvider);
  return QuitPlanHistoryService(dio: dio);
});

// Repository Provider
final quitPlanHistoryRepositoryProvider = Provider<QuitPlanHistoryRepository>((ref) {
  final service = ref.watch(quitPlanHistoryServiceProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return QuitPlanHistoryRepository(
    service: service,
    tokenStorage: tokenStorage,
  );
});

// ViewModel Provider
final quitPlanHistoryViewModelProvider =
    StateNotifierProvider<QuitPlanHistoryViewModel, AsyncValue<List<QuitPlanHistory>>>((ref) {
  final repository = ref.watch(quitPlanHistoryRepositoryProvider);
  final viewModel = QuitPlanHistoryViewModel(repository: repository);
  
  // Auto-load data when provider is first created
  Future.microtask(() => viewModel.loadAllQuitPlans());
  
  return viewModel;
});

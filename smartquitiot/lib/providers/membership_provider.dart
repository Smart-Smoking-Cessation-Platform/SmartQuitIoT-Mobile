import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/plan_option.dart';
import '../services/membership_service.dart';
import '../viewmodels/membership_view_model.dart';
import '../models/state/membership_state.dart';
import '../repositories/membership_repository.dart';

final membershipViewModelProvider =
StateNotifierProvider<MembershipViewModel, MembershipState>((ref) {
  final repository = MembershipRepository();
  final viewModel = MembershipViewModel(repository: repository);
  viewModel.fetchMembershipPackages();
  return viewModel;
});

final planOptionsProvider = FutureProvider.family<List<PlanOption>, int>((ref, packageId) {
  final repository = ref.watch(membershipRepositoryProvider);
  return repository.fetchPlansForPackage(packageId);
});

final membershipApiServiceProvider = Provider<MembershipApiService>((ref) {
  return MembershipApiService();
});

final membershipRepositoryProvider = Provider<MembershipRepository>((ref) {
  final apiService = ref.watch(membershipApiServiceProvider);
  return MembershipRepository(apiService: apiService);
});

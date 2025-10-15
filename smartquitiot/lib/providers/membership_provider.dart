import 'package:flutter_riverpod/flutter_riverpod.dart';
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

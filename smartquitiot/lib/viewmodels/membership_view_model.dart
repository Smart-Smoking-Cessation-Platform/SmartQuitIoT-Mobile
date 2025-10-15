import 'package:riverpod/riverpod.dart';

import '../models/state/membership_state.dart';
import '../repositories/membership_repository.dart';

class MembershipViewModel extends StateNotifier<MembershipState> {
  final MembershipRepository _repository;

  MembershipViewModel({MembershipRepository? repository})
      : _repository = repository ?? MembershipRepository(),
        super(const MembershipState());

  Future<void> fetchMembershipPackages() async {
    state = state.copyWith(state: ViewState.loading);
    try {
      final packages = await _repository.fetchMembershipPackages();
      state = state.copyWith(
        state: ViewState.success,
        packages: packages,
      );
    } catch (e) {
      state = state.copyWith(
        state: ViewState.error,
        errorMessage: e.toString(),
      );
    }
  }
}
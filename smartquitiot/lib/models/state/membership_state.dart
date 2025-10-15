import '../membership_package.dart';


enum ViewState { idle, loading, success, error }

class MembershipState {
  final ViewState state;
  final List<MembershipPackage> packages;
  final String errorMessage;

  const MembershipState({
    this.state = ViewState.idle,
    this.packages = const [],
    this.errorMessage = '',
  });

  MembershipState copyWith({
    ViewState? state,
    List<MembershipPackage>? packages,
    String? errorMessage,
  }) {
    return MembershipState(
      state: state ?? this.state,
      packages: packages ?? this.packages,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

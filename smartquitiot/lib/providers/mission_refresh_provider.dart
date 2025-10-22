import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to notify when missions need to be refreshed
class MissionRefreshNotifier extends StateNotifier<int> {
  MissionRefreshNotifier() : super(0);

  /// Trigger refresh for today missions
  void refreshTodayMissions() {
    state = state + 1;
    print('🔄 [MissionRefreshNotifier] Triggering today missions refresh: $state');
  }
}

final missionRefreshProvider = StateNotifierProvider<MissionRefreshNotifier, int>((ref) {
  return MissionRefreshNotifier();
});

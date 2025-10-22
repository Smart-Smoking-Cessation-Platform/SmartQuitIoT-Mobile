import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/models/home_metrics.dart';
import 'package:SmartQuitIoT/models/health_recovery.dart';
import 'package:SmartQuitIoT/repositories/metrics_repository.dart';
import 'package:SmartQuitIoT/services/metrics_service.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

// Service Provider
final metricsServiceProvider = Provider<MetricsService>((ref) {
  return MetricsService(ref.read(authRepositoryProvider));
});

// Repository Provider
final metricsRepositoryProvider = Provider<MetricsRepository>((ref) {
  return MetricsRepository(
    ref.read(authRepositoryProvider),
    ref.read(metricsServiceProvider),
  );
});

// Home Metrics Provider
final homeMetricsProvider = FutureProvider<HomeMetrics>((ref) async {
  final repository = ref.read(metricsRepositoryProvider);
  return await repository.getHomeMetrics();
});

// Health Recoveries Provider
final healthRecoveriesProvider = FutureProvider<HealthRecoveryResponse>((ref) async {
  final repository = ref.read(metricsRepositoryProvider);
  return await repository.getHealthRecoveries();
});

// Refresh Provider for metrics (similar to diary refresh)
final metricsRefreshProvider = StateNotifierProvider<MetricsRefreshNotifier, int>((ref) {
  return MetricsRefreshNotifier();
});

class MetricsRefreshNotifier extends StateNotifier<int> {
  MetricsRefreshNotifier() : super(0);

  void refreshMetrics() {
    state++;
  }
}

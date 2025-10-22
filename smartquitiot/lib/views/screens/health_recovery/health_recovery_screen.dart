import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/providers/metrics_provider.dart';
import 'package:SmartQuitIoT/models/health_recovery.dart';
import 'package:intl/intl.dart';

class HealthRecoveryScreen extends ConsumerWidget {
  const HealthRecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthRecoveriesAsync = ref.watch(healthRecoveriesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Health Recovery Progress',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: healthRecoveriesAsync.when(
        data: (healthRecoveryResponse) => _buildContent(context, healthRecoveryResponse),
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF00D09E)),
        ),
        error: (error, stack) => _buildErrorState(context, ref),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'No Health Recovery Data Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Start logging your diary entries to track your health improvements and recovery milestones!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(healthRecoveriesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealthRecoveryResponse response) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Progress Card
          _buildOverallProgressCard(response.metrics),
          const SizedBox(height: 20),

          // Health Recoveries List
          const Text(
            'Health Recovery Milestones',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),

          if (response.healthRecoveries.isEmpty)
            _buildEmptyRecoveries()
          else
            ...response.healthRecoveries.map((recovery) => 
              _buildRecoveryCard(recovery)
            ).toList(),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(DetailedMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.trending_up, color: Color(0xFF00D09E), size: 28),
            SizedBox(width: 12),
            Text(
              'Your Progress Overview',
              style: TextStyle(
                color: Color(0xFF2D3748),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            _buildColorfulProgressStat(
              'Streak Days',
              '${metrics.streaks}',
              Icons.local_fire_department,
              const Color(0xFFFF6B6B),
              const Color(0xFFEE5A6F),
            ),
            _buildColorfulProgressStat(
              'Avg Craving',
              '${metrics.avgCravingLevel.toStringAsFixed(1)}/10',
              Icons.psychology,
              const Color(0xFF4ECDC4),
              const Color(0xFF44A9A0),
            ),
            _buildColorfulProgressStat(
              'Avg Mood',
              '${metrics.avgMood.toStringAsFixed(1)}/10',
              Icons.sentiment_satisfied,
              const Color(0xFFFFA500),
              const Color(0xFFFF8C00),
            ),
            _buildColorfulProgressStat(
              'Confidence',
              '${metrics.avgConfidentLevel.toStringAsFixed(1)}/10',
              Icons.psychology_alt,
              const Color(0xFF9B59B6),
              const Color(0xFF8E44AD),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildColorfulProgressStat(
    String title,
    String value,
    IconData icon,
    Color startColor,
    Color endColor,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: 0.8 + (animValue * 0.2),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [startColor, endColor],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: startColor.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyRecoveries() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.health_and_safety_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No Recovery Data Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Keep logging your diary entries to unlock health recovery milestones!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecoveryCard(HealthRecovery recovery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getStatusColor(recovery.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getStatusIcon(recovery.status),
                  color: _getStatusColor(recovery.status),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatRecoveryName(recovery.name),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recovery.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (recovery.value != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(recovery.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${recovery.value?.toInt() ?? 0}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                'Recovery Time: ${recovery.formattedRecoveryTime}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                _getStatusText(recovery.status),
                style: TextStyle(
                  fontSize: 13,
                  color: _getStatusColor(recovery.status),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          if (recovery.value != null) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: recovery.value! / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(recovery.status),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatRecoveryName(String name) {
    return name.replaceAll('_', ' ').toLowerCase().split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Color _getStatusColor(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return const Color(0xFF4CAF50);
      case RecoveryStatus.inProgress:
        return const Color(0xFF2196F3);
      case RecoveryStatus.started:
        return const Color(0xFFFF9800);
      case RecoveryStatus.upcoming:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData _getStatusIcon(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return Icons.check_circle;
      case RecoveryStatus.inProgress:
        return Icons.hourglass_empty;
      case RecoveryStatus.started:
        return Icons.play_circle;
      case RecoveryStatus.upcoming:
        return Icons.schedule;
    }
  }

  String _getStatusText(RecoveryStatus status) {
    switch (status) {
      case RecoveryStatus.completed:
        return 'Completed';
      case RecoveryStatus.inProgress:
        return 'In Progress';
      case RecoveryStatus.started:
        return 'Started';
      case RecoveryStatus.upcoming:
        return 'Upcoming';
    }
  }
}

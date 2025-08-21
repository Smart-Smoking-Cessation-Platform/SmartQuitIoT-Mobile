import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/quit_smoking_controller.dart';
import '../widgets/cloud_background.dart';
import '../widgets/grass_landscape.dart';
import '../widgets/albert_character.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quitSmokingControllerProvider);

    return Scaffold(
      body: CloudBackground(
        child: Column(
          children: [
            // Top section with app bar
            _buildTopSection(context),

            // Main content area
            Expanded(child: _buildMainContent(context, state)),

            // Bottom section with character
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // App logo and name
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.green[600],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smoke_free,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Kwit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Start Journey button (when no journey is active)
            Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(quitSmokingControllerProvider);
                if (state.quitSmoking == null) {
                  return ElevatedButton(
                    onPressed: () {
                      ref
                          .read(quitSmokingControllerProvider.notifier)
                          .startQuitJourney();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Journey',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
            // Settings button
            IconButton(
              onPressed: () {
                // Show settings or profile
              },
              icon: const Icon(Icons.settings, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, QuitSmokingState state) {
    final quitSmoking = state.quitSmoking;

    if (quitSmoking == null) {
      return const Center(
        child: Text(
          'Start your quit smoking journey!',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    final daysSmokeFree = DateTime.now()
        .difference(quitSmoking.startDate)
        .inDays;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Progress card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$daysSmokeFree',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
                const Text(
                  'Days Smoke Free',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Progress bar
                LinearProgressIndicator(
                  value: (daysSmokeFree / 30).clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
                  minHeight: 8,
                ),
                const SizedBox(height: 8),
                Text(
                  '${((daysSmokeFree / 30) * 100).clamp(0, 100).toInt()}% to 30 days goal',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Quick actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Track Cravings',
                  Icons.track_changes,
                  Colors.blue[600]!,
                  () {
                    // Handle track cravings
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'View Progress',
                  Icons.trending_up,
                  Colors.green[600]!,
                  () {
                    // Handle view progress
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Get Support',
                  Icons.support_agent,
                  Colors.purple[600]!,
                  () {
                    // Handle get support
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionCard(
                  context,
                  'Rewards',
                  Icons.star,
                  Colors.orange[600]!,
                  () {
                    // Handle rewards
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return GrassLandscape(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Albert character
          SizedBox(
            height: 200,
            child: Center(child: AlbertCharacter(size: 100)),
          ),

          // Bottom padding
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

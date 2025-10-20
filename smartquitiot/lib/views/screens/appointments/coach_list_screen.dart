// lib/features/coaching/screens/coach_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'coach_detail_screen.dart';
import 'coach_list_items.dart';
import '../../../providers/coach_provider.dart';
import '../../../models/coach.dart' as api_models;

class CoachListScreen extends ConsumerWidget {
  const CoachListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachesAsync = ref.watch(coachesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFDFF7E2), // ✅ background xanh nhạt
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF00D09E),
        centerTitle: true,
        title: const Text(
          'Choose a Coach',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.invalidate(coachesProvider);
            },
          ),
        ],
      ),
      body: coachesAsync.when(
        data: (coaches) {
          if (coaches.isEmpty) {
            return _buildEmptyState();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(coachesProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: coaches.length,
              itemBuilder: (context, index) {
                final coach = coaches[index];
                return CoachListItem(
                  coach: _convertApiCoachToLocalCoach(coach),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoachDetailScreen(
                          coach: _convertApiCoachToLocalCoach(coach),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
          ),
        ),
        error: (error, stack) => _buildErrorState(error.toString(), ref),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search, size: 80, color: Color(0xFF00D09E)),
            const SizedBox(height: 16),
            const Text(
              'No Coaches Available',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are currently no coaches available for booking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFE53E3E)),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(coachesProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Convert API coach model to local coach model for UI compatibility
  Coach _convertApiCoachToLocalCoach(api_models.Coach apiCoach) {
    return Coach(
      id: apiCoach.id.toString(),
      name: apiCoach.fullName,
      specialty:
          'Health Coach', // Default specialty since API doesn't provide this
      rating: apiCoach.ratingAvg,
      reviews: 0, // Default since API doesn't provide review count
      experience: 'Professional Coach', // Default experience
      imageUrl: apiCoach.avatarUrl,
      bio:
          'Professional coach with expertise in helping people achieve their health goals.',
    );
  }
}

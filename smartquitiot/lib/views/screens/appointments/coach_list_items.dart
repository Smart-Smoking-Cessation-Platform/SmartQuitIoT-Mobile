import 'package:SmartQuitIoT/views/screens/appointments/rating_display.dart';
import 'package:flutter/material.dart';

class Coach {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final String experience;
  final String imageUrl;
  final String bio;

  Coach({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.imageUrl,
    required this.bio,
  });
}

// lib/features/coaching/models/time_slot.dart
class TimeSlot {
  final String time;
  final bool available;

  TimeSlot({
    required this.time,
    required this.available,
  });
}

class CoachListItem extends StatelessWidget {
  final Coach coach;
  final VoidCallback onTap;

  const CoachListItem({
    super.key,
    required this.coach,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                _buildInfo(),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.grey,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = coach.name.isNotEmpty
        ? coach.name.split(' ').map((n) => n[0]).take(2).join().toUpperCase()
        : '?';
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF00D09E).withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: coach.imageUrl.isNotEmpty && 
               !coach.imageUrl.contains('example.com') &&
               (coach.imageUrl.startsWith('http://') || coach.imageUrl.startsWith('https://'))
            ? Image.network(
                coach.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00D09E),
                        ),
                      ),
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D09E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                      ),
                    ),
                  );
                },
              )
            : Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00D09E),
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            coach.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            coach.specialty,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          RatingDisplay(
            rating: coach.rating,
            reviews: coach.reviews,
          ),
          const SizedBox(height: 4),
          Text(
            coach.experience,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6366F1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
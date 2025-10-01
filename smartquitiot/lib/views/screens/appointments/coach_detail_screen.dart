// lib/features/coaching/screens/coach_detail_screen.dart
import 'package:SmartQuitIoT/views/screens/appointments/coach_list_items.dart';
import 'package:SmartQuitIoT/views/screens/appointments/info_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/time_slot_grid.dart';
import 'package:flutter/material.dart';

import 'coach_rating_screen.dart';
import 'custom_button.dart';
import 'info_row.dart';

class CoachDetailScreen extends StatefulWidget {
  final Coach coach;

  const CoachDetailScreen({Key? key, required this.coach}) : super(key: key);

  @override
  State<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends State<CoachDetailScreen> {
  String? selectedSlot;
  String selectedDate = 'Monday, Oct 02, 2025';

  final List<TimeSlot> timeSlots = [
    TimeSlot(time: '09:00 AM', available: true),
    TimeSlot(time: '10:00 AM', available: true),
    TimeSlot(time: '11:00 AM', available: false),
    TimeSlot(time: '01:00 PM', available: true),
    TimeSlot(time: '02:00 PM', available: true),
    TimeSlot(time: '03:00 PM', available: true),
    TimeSlot(time: '04:00 PM', available: false),
    TimeSlot(time: '05:00 PM', available: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCards(),
                  const SizedBox(height: 16),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildTimeSlotsSection(),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirm Booking',
                    onPressed: selectedSlot == null ? null : _handleBooking,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF00D09E),
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.coach.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF00D09E), Color(0xFF00B88D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Avatar + Verified Coach
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      image: DecorationImage(
                        image: NetworkImage(widget.coach.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.verified, color: Color(0xFF00D09E), size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Verified Coach',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.people_outline,
            value: '${widget.coach.reviews}+',
            label: 'Patients',
            color: const Color(0xFF00D09E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.star_rounded,
            value: '${widget.coach.rating}',
            label: 'Rating',
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.workspace_premium_rounded,
            value: widget.coach.experience.split(' ')[0],
            label: 'Years Exp.',
            color: Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return InfoCard(
      title: 'About Coach',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00D09E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.work_outline,
                  color: Color(0xFF00D09E),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.coach.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF00D09E),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoRow(
            icon: Icons.psychology_outlined,
            text: 'Specialized in behavioral therapy',
            iconColor: const Color(0xFF00D09E),
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.school_outlined,
            text: widget.coach.experience,
            iconColor: const Color(0xFF00D09E),
          ),
          const SizedBox(height: 12),
          InfoRow(
            icon: Icons.language_rounded,
            text: 'English, Vietnamese',
            iconColor: const Color(0xFF00D09E),
          ),
          const Divider(height: 32),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: Color(0xFF00D09E),
              ),
              const SizedBox(width: 8),
              const Text(
                'Biography',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.coach.bio,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          _buildAchievementChips(),
        ],
      ),
    );
  }

  Widget _buildAchievementChips() {
    final achievements = [
      '🏆 Top Rated',
      '✨ 100% Success Rate',
      '❤️ Patient Favorite',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: achievements.map((achievement) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Text(
            achievement,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSlotsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFF00D09E),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              'Select Time Slot',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF00D09E), width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.event_available_rounded,
                color: Color(0xFF00D09E),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                selectedDate,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.grey[600],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildLegendItem(Colors.white, 'Available', Colors.grey[300]!),
            const SizedBox(width: 16),
            _buildLegendItem(const Color(0xFF00D09E), 'Selected', const Color(0xFF00D09E)),
            const SizedBox(width: 16),
            _buildLegendItem(Colors.grey[200]!, 'Booked', Colors.grey[300]!),
          ],
        ),
        const SizedBox(height: 16),
        TimeSlotGrid(
          timeSlots: timeSlots,
          selectedSlot: selectedSlot,
          onSlotSelected: (slot) {
            setState(() {
              selectedSlot = slot;
            });
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color bgColor, String label, Color borderColor) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _handleBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF00D09E),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your consultation with ${widget.coach.name} has been scheduled for $selectedSlot on $selectedDate.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'We\'ll send you a reminder 15 minutes before',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // đóng dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CoachRatingScreen(coach: widget.coach,),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D09E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
// lib/views/screens/appointments/coach_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:SmartQuitIoT/views/screens/appointments/coach_list_items.dart';
import 'package:SmartQuitIoT/views/screens/appointments/info_card.dart';
import 'package:SmartQuitIoT/views/screens/appointments/time_slot_grid.dart';

import '../../../../models/slot_available.dart';
import '../../../providers/coach_detail_provider.dart';
import 'coach_rating_screen.dart';
import 'custom_button.dart';
import 'info_row.dart';

class CoachDetailScreen extends ConsumerStatefulWidget {
  final Coach coach;

  const CoachDetailScreen({super.key, required this.coach});

  @override
  ConsumerState<CoachDetailScreen> createState() => _CoachDetailScreenState();
}

class _CoachDetailScreenState extends ConsumerState<CoachDetailScreen> {
  String? selectedSlot;
  DateTime selectedDateTime = DateTime.now();
  String selectedDate = DateFormat('EEEE, MMM dd, yyyy').format(DateTime.now());

  List<SlotAvailable> availableSlots = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoachDetail();
    });
  }

  Future<void> _loadCoachDetail({String? dateIso}) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final viewModel = ref.read(coachDetailViewModelProvider.notifier);
      final formattedDate =
          dateIso ?? DateFormat('yyyy-MM-dd').format(DateTime.now());

      final coachId = int.tryParse(widget.coach.id);
      if (coachId == null) {
        throw Exception('Coach id không phải số: ${widget.coach.id}');
      }

      await viewModel.loadCoachDetail(coachId, formattedDate);

      final state = ref.read(coachDetailViewModelProvider);
      final slots = state.slots ?? [];

      setState(() {
        availableSlots = slots;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openDatePickerBottomSheet(BuildContext context) async {
    DateTime tempSelected = selectedDateTime;
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day);
    final lastDate = firstDate.add(const Duration(days: 60));

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: MediaQuery.of(ctx).viewInsets +
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                CalendarDatePicker(
                  initialDate: selectedDateTime.isBefore(firstDate)
                      ? firstDate
                      : selectedDateTime,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  onDateChanged: (d) {
                    tempSelected = d;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedDateTime = tempSelected;
                            selectedDate = DateFormat('EEEE, MMM dd, yyyy')
                                .format(selectedDateTime);
                          });
                          final iso = DateFormat('yyyy-MM-dd')
                              .format(selectedDateTime);
                          Navigator.of(ctx).pop();
                          _loadCoachDetail(dateIso: iso);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00D09E),
                        ),
                        child: const Text(
                          'Confirm',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        title: Text(widget.coach.name),
        centerTitle: true,
      ),
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
                  _buildTimeSlotsSection(context),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Confirm Booking',
                    onPressed: selectedSlot == null ? null : _handleBooking,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDatePickerBottomSheet(context),
        backgroundColor: const Color(0xFF00D09E),
        child: const Icon(Icons.date_range),
      ),
    );
  }

  // ==== helpers ====

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
        title: Text(widget.coach.name,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        centerTitle: true,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00D09E), Color(0xFF00B88D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.coach.imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(Icons.people_outline,
              '${widget.coach.reviews}+', 'Patients', const Color(0xFF00D09E)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(Icons.star_rounded, '${widget.coach.rating}',
              'Rating', Colors.amber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(Icons.workspace_premium_rounded,
              widget.coach.experience.split(' ')[0], 'Years Exp.', Colors.purple),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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
          InfoRow(
            icon: Icons.work_outline,
            text: widget.coach.specialty,
            iconColor: const Color(0xFF00D09E),
          ),
          const SizedBox(height: 16),
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
          Text(widget.coach.bio,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTimeSlotsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: Color(0xFF00D09E), size: 24),
            SizedBox(width: 8),
            Text('Select Time Slot',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openDatePickerBottomSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF00D09E),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available_rounded,
                    color: Color(0xFF00D09E), size: 20),
                const SizedBox(width: 8),
                Text(selectedDate,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87)),
                const Spacer(),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage != null)
          Center(
              child: Text(errorMessage!,
                  style: const TextStyle(color: Colors.red)))
        else if (availableSlots.isEmpty)
            const Center(child: Text('No available slots for this day'))
          else
            TimeSlotGrid(
              timeSlots: availableSlots
                  .map((slot) =>
                  TimeSlot(time: slot.startTime, available: true))
                  .toList(),
              selectedSlot: selectedSlot,
              onSlotSelected: (slot) => setState(() => selectedSlot = slot),
            ),
      ],
    );
  }

  void _handleBooking() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF00D09E), size: 48),
            const SizedBox(height: 16),
            const Text('Booking Confirmed!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87)),
            const SizedBox(height: 12),
            Text(
              'Your consultation with ${widget.coach.name} has been scheduled for $selectedSlot on $selectedDate.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CoachRatingScreen(coach: widget.coach),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
              ),
              child: const Text('Done',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

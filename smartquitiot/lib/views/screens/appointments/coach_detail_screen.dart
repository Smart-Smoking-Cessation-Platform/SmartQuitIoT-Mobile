// lib/views/screens/appointments/coach_detail_screen.dart
import 'package:flutter/foundation.dart';
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
import '../../../models/request/appointment_request.dart';
import '../../../services/appointment_service.dart';
import '../../../services/token_storage_service.dart';

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
      debugPrint('[DEBUG] initState: loading coach detail for today');
      _loadCoachDetail();
    });
  }

  Future<void> _loadCoachDetail({String? dateIso}) async {
    debugPrint('[DEBUG] _loadCoachDetail called with dateIso=$dateIso');
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final viewModel = ref.read(coachDetailViewModelProvider.notifier);
      final formattedDate =
          dateIso ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
      debugPrint('[DEBUG] formattedDate used = $formattedDate');

      final coachId = int.tryParse(widget.coach.id);
      if (coachId == null) {
        throw Exception('Coach id không phải số: ${widget.coach.id}');
      }

      await viewModel.loadCoachDetail(coachId, formattedDate);

      final state = ref.read(coachDetailViewModelProvider);
      final slots = state.slots ?? [];

      debugPrint('[DEBUG] _loadCoachDetail: received slots count=${slots.length}');

      setState(() {
        availableSlots = slots;
        isLoading = false;
      });
    } catch (e, st) {
      debugPrint('[ERROR] _loadCoachDetail exception: $e\n$st');
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _openDatePickerBottomSheet(BuildContext context) async {
    debugPrint('[DEBUG] _openDatePickerBottomSheet called');
    try {
      DateTime today = DateTime.now();
      final firstDate = DateTime(today.year, today.month, today.day);
      final lastDate = firstDate.add(const Duration(days: 60));

      DateTime tempSelected = selectedDateTime.isBefore(firstDate) ? firstDate : selectedDateTime;

      // show the real stateful modal with CalendarDatePicker
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx2, setModalState) {
              return SafeArea(
                child: Padding(
                  padding: MediaQuery.of(ctx2).viewInsets +
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      CalendarDatePicker(
                        initialDate: tempSelected,
                        firstDate: firstDate,
                        lastDate: lastDate,
                        onDateChanged: (d) {
                          setModalState(() => tempSelected = d);
                          debugPrint('[DEBUG] bottom sheet tempSelected updated = $d');
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx2).pop(),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                // Validate date not in past (server sẽ trả 400 nếu trước ngày hôm nay)
                                final chosen = DateTime(tempSelected.year, tempSelected.month, tempSelected.day);
                                final nowDate = DateTime.now();
                                final todayOnly = DateTime(nowDate.year, nowDate.month, nowDate.day);
                                if (chosen.isBefore(todayOnly)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Vui lòng chọn ngày từ hôm nay trở đi.')),
                                  );
                                  return;
                                }

                                setState(() {
                                  selectedDateTime = tempSelected;
                                  selectedDate = DateFormat('EEEE, MMM dd, yyyy').format(selectedDateTime);
                                  // reset selected slot when change date
                                  selectedSlot = null;
                                });

                                final iso = DateFormat('yyyy-MM-dd').format(selectedDateTime);
                                debugPrint('[DEBUG] Confirm pressed: selectedDateTime=$selectedDateTime iso=$iso');

                                Navigator.of(ctx2).pop();
                                _loadCoachDetail(dateIso: iso);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09E),
                              ),
                              child: const Text('Confirm', style: TextStyle(color: Colors.white)),
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
        },
      );
    } catch (e, st) {
      debugPrint('[ERROR] Exception in _openDatePickerBottomSheet: $e\n$st');
      // fallback robust: use native date picker
      final today = DateTime.now();
      final firstDate = DateTime(today.year, today.month, today.day);
      final lastDate = firstDate.add(const Duration(days: 60));
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDateTime.isBefore(firstDate) ? firstDate : selectedDateTime,
        firstDate: firstDate,
        lastDate: lastDate,
      );
      if (picked != null) {
        setState(() {
          selectedDateTime = picked;
          selectedDate = DateFormat('EEEE, MMM dd, yyyy').format(selectedDateTime);
          selectedSlot = null;
        });
        final iso = DateFormat('yyyy-MM-dd').format(selectedDateTime);
        debugPrint('[DEBUG] fallback (catch) picked date iso=$iso');
        _loadCoachDetail(dateIso: iso);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // make heroTag unique per coach to avoid "multiple heroes" error
    final fabHeroTag = 'coach_date_fab_${widget.coach.id}';

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
        heroTag: fabHeroTag, // unique hero tag per coach
        onPressed: () {
          debugPrint('[DEBUG] FAB pressed to open date picker');
          _openDatePickerBottomSheet(context);
        },
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
          onTap: () {
            debugPrint('[DEBUG] InkWell tapped to open date picker');
            _openDatePickerBottomSheet(context);
          },
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
                  .map((slot) => TimeSlot(
                time: slot.startTime ?? '',
                available: true,
              ))
                  .toList(),
              selectedSlot: selectedSlot,
              onSlotSelected: (slot) => setState(() => selectedSlot = slot),
            ),
      ],
    );
  }

  void _handleBooking() async {
    if (selectedSlot == null) return;

    // find the slot object by startTime in availableSlots
    final matches = availableSlots.where((s) => s.startTime == selectedSlot).toList();
    final SlotAvailable? chosenSlot = matches.isNotEmpty ? matches.first : null;

    if (chosenSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy slot đã chọn. Vui lòng thử lại.')),
      );
      return;
    }

    final slotId = chosenSlot.slotId;
    final coachId = int.tryParse(widget.coach.id);
    if (coachId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coach ID không hợp lệ')),
      );
      return;
    }

    final isoDate = DateFormat('yyyy-MM-dd').format(selectedDateTime);

    final req = AppointmentRequest(coachId: coachId, slotId: slotId, date: isoDate);

    final tokenService = TokenStorageService();
    final token = await tokenService.getAccessToken();
    if (token == null || token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bạn chưa đăng nhập. Vui lòng đăng nhập để đặt lịch.')),
      );
      return;
    }

    // show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = AppointmentService();
      // NOTE: AppointmentService expects an encodable body; pass a Map via toJson()
      final resp = await service.bookAppointment(req.toJson(), token);

      Navigator.of(context).pop(); // remove loading

      final data = resp['data'] as Map<String, dynamic>?;

      setState(() {
        availableSlots.removeWhere((s) => s.slotId == slotId);
        selectedSlot = null;
      });

      // show success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF00D09E), size: 48),
              const SizedBox(height: 16),
              const Text('Booking Confirmed!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 12),
              Text(
                data != null
                    ? 'Your consultation with ${data['coachName'] ?? widget.coach.name} has been scheduled for ${data['startTime'] ?? selectedSlot} on ${data['date'] ?? isoDate}.'
                    : 'Booking success for $isoDate.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CoachRatingScreen(coach: widget.coach)),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D09E)),
                child: const Text('Done', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } catch (e, st) {
      // remove loading safely (if still shown)
      try {
        Navigator.of(context).pop();
      } catch (_) {}
      debugPrint('[ERROR] booking failed: $e\n$st');

      final errMsg = e is Exception ? e.toString().replaceAll('Exception: ', '') : 'Đặt lịch thất bại';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errMsg)),
      );
    }
  }
}

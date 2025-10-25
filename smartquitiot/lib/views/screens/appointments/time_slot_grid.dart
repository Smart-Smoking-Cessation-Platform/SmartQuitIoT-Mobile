import 'package:SmartQuitIoT/views/screens/appointments/time_slot_item.dart';
import 'package:flutter/material.dart';

import 'coach_list_items.dart';

class TimeSlotGrid extends StatelessWidget {
  final List<TimeSlot> timeSlots;
  final String? selectedSlot;
  final Function(String) onSlotSelected;

  const TimeSlotGrid({
    super.key,
    required this.timeSlots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  @override
  Widget build(BuildContext context) {
    // debug: show count
    debugPrint(
      '[DEBUG] TimeSlotGrid.build: count=${timeSlots.length}, selected=$selectedSlot',
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final slot = timeSlots[index];
        // defensive: ensure time is non-null
        final slotTime = slot.time ?? '';
        return TimeSlotItem(
          slot: TimeSlot(time: slotTime, available: slot.available),
          isSelected: selectedSlot == slotTime && slotTime.isNotEmpty,
          onTap: slot.available
              ? () {
                  debugPrint('[DEBUG] TimeSlotGrid tapped: $slotTime');
                  onSlotSelected(slotTime);
                }
              : null,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'coach_list_items.dart';

class TimeSlotItem extends StatelessWidget {
  final TimeSlot slot;
  final bool isSelected;
  final VoidCallback? onTap;

  const TimeSlotItem({
    Key? key,
    required this.slot,
    required this.isSelected,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getBorderColor(),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            slot.time,
            style: TextStyle(
              color: _getTextColor(),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ Màu nền
  Color _getBackgroundColor() {
    if (!slot.available) return Colors.grey[200]!;       // slot không khả dụng
    if (isSelected) return const Color(0xFF00D09E);      // slot được chọn → xanh
    return Colors.white;                                 // slot khả dụng chưa chọn
  }

  // ✅ Màu viền
  Color _getBorderColor() {
    if (!slot.available) return Colors.grey[300]!;
    if (isSelected) return const Color(0xFF00D09E);
    return Colors.grey[300]!;
  }

  // ✅ Màu chữ
  Color _getTextColor() {
    if (!slot.available) return Colors.grey[400]!; // disable
    if (isSelected) return Colors.white;           // khi chọn → trắng
    return Colors.black87;                         // mặc định
  }
}

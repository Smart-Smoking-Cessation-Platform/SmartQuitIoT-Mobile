import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../viewmodels/quit_plan_homepage_view_model.dart';

class SmokeFreeTimerCard extends ConsumerStatefulWidget {
  const SmokeFreeTimerCard({super.key});

  @override
  ConsumerState<SmokeFreeTimerCard> createState() => _SmokeFreeTimerCardState();
}

class _SmokeFreeTimerCardState extends ConsumerState<SmokeFreeTimerCard> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Update timer every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quitPlanState = ref.watch(quitPlanHomepageViewModelProvider);
    final quitPlan = quitPlanState.quitPlan;

    // If no quit plan, show empty state
    if (quitPlan == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              'No Quit Plan Yet',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your quit plan to start tracking',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      );
    }

    // Parse dates
    DateTime? startDate;
    DateTime? endDate;
    try {
      startDate = DateTime.parse(quitPlan.startDateOfQuitPlan);
      endDate = DateTime.parse(quitPlan.endDate);
    } catch (e) {
      print('❌ Error parsing dates: $e');
    }

    if (startDate == null || endDate == null) {
      return const SizedBox.shrink();
    }

    // Calculate time difference
    final isBeforeStart = _now.isBefore(startDate);

    late Duration difference;
    late String title;
    late Color bgColor;

    if (isBeforeStart) {
      // Chưa tới quit plan - COUNTDOWN đến start date
      difference = startDate.difference(_now);
      title = 'Countdown to Quit Plan';
      bgColor = Color(0xFF00D09E); // Màu xanh lá
    } else {
      // Đã bắt đầu quit plan - Hiển thị TIME SMOKE FREE
      difference = _now.difference(startDate);
      title = 'Time Smoke Free';
      bgColor = Color(0xFF00D09E); // Màu xanh dương
    }

    // Calculate days, hours, minutes, seconds
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Debug logging
    print('⏰ [SmokeFreeTimer] Current: $_now');
    print('📅 [SmokeFreeTimer] Start: $startDate');
    print('🔍 [SmokeFreeTimer] Before start? $isBeforeStart');
    print(
      '⏱️ [SmokeFreeTimer] Time: ${days}d ${hours}h ${minutes}m ${seconds}s',
    );
    print('📊 [SmokeFreeTimer] Title: $title');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tiêu đề động
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          // Icon + Timer (2x2 Grid)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isBeforeStart ? Icons.timer : Icons.smoke_free,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              // Time Grid (2x2)
              Expanded(
                child: Column(
                  children: [
                    // Row 1: Days & Hours
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TimeColumn(value: days.toString(), label: 'days'.tr()),
                        _TimeColumn(
                          value: hours.toString(),
                          label: 'hours'.tr(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Row 2: Minutes & Seconds
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _TimeColumn(
                          value: minutes.toString(),
                          label: 'minutes'.tr(),
                        ),
                        _TimeColumn(
                          value: seconds.toString(),
                          label: 'seconds'.tr(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  final String value;
  final String label;

  const _TimeColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

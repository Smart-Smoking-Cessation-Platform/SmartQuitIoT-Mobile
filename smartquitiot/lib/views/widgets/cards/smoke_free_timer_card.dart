import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../providers/quit_plan_time_provider.dart';

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
    // Load start time from API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quitPlanTimeViewModelProvider.notifier).loadStartTime();
    });

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
    final quitPlanTimeState = ref.watch(quitPlanTimeViewModelProvider);

    // Show loading spinner while loading
    if (quitPlanTimeState.isLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFF00D09E), const Color(0xFF00BF8F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D09E).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            strokeWidth: 3,
          ),
        ),
      );
    }

    // Show error state if error
    if (quitPlanTimeState.error != null) {
      return GestureDetector(
        onTap: () {
          ref.read(quitPlanTimeViewModelProvider.notifier).refresh();
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 32),
              const SizedBox(height: 8),
              Text(
                'Error Loading Timer',
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap to retry',
                style: TextStyle(color: Colors.red[600], fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    // If no start time after loading, show empty state
    if (quitPlanTimeState.startTime == null) {
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

    final startDate = quitPlanTimeState.startTime!;

    // Calculate time difference
    final isBeforeStart = _now.isBefore(startDate);

    late Duration difference;
    late String title;

    if (isBeforeStart) {
      // Chưa tới quit plan - COUNTDOWN đến start date
      difference = startDate.difference(_now);
      title = 'Countdown to Quit Plan';
    } else {
      // Đã bắt đầu quit plan - Hiển thị TIME SMOKE FREE
      difference = _now.difference(startDate);
      title = 'Time Smoke Free';
    }

    // Calculate days, hours, minutes, seconds
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;
    final seconds = difference.inSeconds % 60;

    // Debug logging
    // print('⏰ [SmokeFreeTimer] Current: $_now');
    // print('📅 [SmokeFreeTimer] Start: $startDate');
    // print('🔍 [SmokeFreeTimer] Before start? $isBeforeStart');
    // print(
    //   '⏱️ [SmokeFreeTimer] Time: ${days}d ${hours}h ${minutes}m ${seconds}s',
    // );
    // print('📊 [SmokeFreeTimer] Title: $title');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF00D09E), const Color(0xFF00BF8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern với opacity thấp
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              isBeforeStart ? Icons.timer : Icons.smoke_free_rounded,
              size: 140,
              color: Colors.white.withOpacity(0.08),
            ),
          ),

          // Main content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isBeforeStart
                            ? Icons.timer_outlined
                            : Icons.smoke_free_rounded,
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isBeforeStart
                                ? 'Your journey begins soon'
                                : 'You\'re doing amazing!',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Time Grid (2x2) - Đẹp hơn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _TimeBox(
                      value: days.toString().padLeft(2, '0'),
                      label: 'days'.tr(),
                    ),
                    _TimeBox(
                      value: hours.toString().padLeft(2, '0'),
                      label: 'hours'.tr(),
                    ),
                    _TimeBox(
                      value: minutes.toString().padLeft(2, '0'),
                      label: 'mins'.tr(),
                    ),
                    _TimeBox(
                      value: seconds.toString().padLeft(2, '0'),
                      label: 'secs'.tr(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeBox extends StatelessWidget {
  final String value;
  final String label;

  const _TimeBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

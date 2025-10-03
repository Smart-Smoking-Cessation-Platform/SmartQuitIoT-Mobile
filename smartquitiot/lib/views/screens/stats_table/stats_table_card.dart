import 'package:SmartQuitIoT/views/screens/health_metrics/health_improvement_screen.dart';
import 'package:SmartQuitIoT/views/screens/health_metrics/health_metrics_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:easy_localization/easy_localization.dart'; // thêm vào
import 'animated_streak.dart';
import 'stat_item.dart';

class StatsTableCard extends StatefulWidget {
  const StatsTableCard({super.key});

  @override
  State<StatsTableCard> createState() => _StatsTableCardState();
}

class _StatsTableCardState extends State<StatsTableCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'dashboard.title'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HealthMetricsScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 30),
                      ),
                      child: Text(
                        'dashboard.view_more'.tr(),
                        style: const TextStyle(
                          color: Color(0xFF00D09E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Animated Streak highlight
              const SizedBox(height: 8),
              const Center(child: AnimatedStreak()),
              const SizedBox(height: 16),

              // Table style Grid với Lottie icons
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.75,
                children: [
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/calendar.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.quit_day'.tr(),
                    value: 'dashboard.quit_day_value'.tr(),
                  ),
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/money.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.money_saved'.tr(),
                    value: 'dashboard.money_saved_value'.tr(),
                  ),
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/money-2.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.annual_saved'.tr(),
                    value: 'dashboard.annual_saved_value'.tr(),
                  ),
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/heart.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.heart_rate'.tr(),
                    value: 'dashboard.heart_rate_value'.tr(),
                  ),
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/walking-steps.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.steps'.tr(),
                    value: 'dashboard.steps_value'.tr(),
                  ),
                  StatItem(
                    icon: Lottie.asset(
                      'lib/assets/animations/weather-night.json',
                      width: 45,
                      height: 45,
                    ),
                    title: 'dashboard.sleep'.tr(),
                    value: 'dashboard.sleep_value'.tr(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Button Connect IoT Device
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // TODO: kết nối IoT device
                  },
                  child: Text(
                    'dashboard.connect_iot'.tr(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

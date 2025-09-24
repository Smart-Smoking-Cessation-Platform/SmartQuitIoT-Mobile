import 'package:SmartQuitIoT/views/screens/payment/premium_membership_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'diary_history_screen.dart';
import 'package:SmartQuitIoT/views/widgets/cards/progress_card.dart';
import 'package:SmartQuitIoT/views/widgets/buttons/action_button.dart';
import 'package:SmartQuitIoT/views/widgets/sections/today_stats_section.dart';
import 'package:SmartQuitIoT/views/widgets/sections/weekly_trend_section.dart';
import 'package:SmartQuitIoT/views/widgets/sections/quick_insights_section.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: const Text(
          'Diary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiaryHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProgressCard(
              title: 'My Plan Progress',
              subtitle: 'Day 24 of quit plan',
              progress: 0.8,
              progressText: '80%',
              icon: Lottie.asset(
                'assets/animation.json',   // file json Lottie của bạn
                width: 32,
                height: 32,
              ),
            ),
            const SizedBox(height: 24),
            ActionButton(
              text: 'Entry new diary',
              icon: Icons.add_circle_outline,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumMembershipScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TodayStatsSection(
              stats: [
                {
                  'title': 'Smoked',
                  'value': '0',
                  'subtitle': 'cigarettes',
                  'icon': Icons.smoke_free,
                  'color': const Color(0xFF4CAF50),
                },
                {
                  'title': 'Cravings',
                  'value': '3',
                  'subtitle': 'episodes',
                  'icon': Icons.psychology,
                  'color': const Color(0xFFE91E63),
                },
                {
                  'title': 'Mood',
                  'value': '7.5',
                  'subtitle': 'out of 10',
                  'icon': Icons.sentiment_satisfied,
                  'color': const Color(0xFF2196F3),
                },
                {
                  'title': 'Confidence',
                  'value': '8.0',
                  'subtitle': 'level',
                  'icon': Icons.psychology_alt,
                  'color': const Color(0xFFFF9800),
                },
              ],
            ),
            const SizedBox(height: 24),
            WeeklyTrendSection(
              status: 'Improving',
              dayProgress: [
                {'day': 'Mon', 'progress': 0.3},
                {'day': 'Tue', 'progress': 0.6},
                {'day': 'Wed', 'progress': 0.8},
                {'day': 'Thu', 'progress': 0.9},
                {'day': 'Fri', 'progress': 0.95},
                {'day': 'Sat', 'progress': 1.0},
                {'day': 'Sun', 'progress': 1.0},
              ],
            ),
            const SizedBox(height: 24),
            QuickInsightsSection(
              insights: [
                'Your cravings decreased by 40% this week',
                'Best mood recorded: Yesterday evening',
                'Confidence level trending upward',
              ],
            ),
          ],
        ),
      ),
    );
  }
}

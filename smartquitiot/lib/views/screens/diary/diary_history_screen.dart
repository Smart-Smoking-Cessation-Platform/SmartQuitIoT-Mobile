import 'package:flutter/material.dart';
import 'diary_filer_section_screen.dart';
import 'diary_stats_overview.dart';
import 'diary_history_list.dart';
import 'diary_analytics_bottom_sheet.dart';

class DiaryHistoryScreen extends StatefulWidget {
  const DiaryHistoryScreen({super.key});

  @override
  State<DiaryHistoryScreen> createState() => _DiaryHistoryScreenState();
}

class _DiaryHistoryScreenState extends State<DiaryHistoryScreen> {
  String selectedFilter = 'All';

  void _openAnalyticsBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const DiaryAnalyticsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: _openAnalyticsBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          DiaryFilterSection(
            selectedFilter: selectedFilter,
            onFilterSelected: (filter) {
              setState(() => selectedFilter = filter);
            },
          ),
          const DiaryStatsOverview(),
          Expanded(
            child: DiaryHistoryList(filter: selectedFilter),
          ),
        ],
      ),
    );
  }
}

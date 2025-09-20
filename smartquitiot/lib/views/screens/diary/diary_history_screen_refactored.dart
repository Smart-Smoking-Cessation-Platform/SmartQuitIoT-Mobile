import 'package:flutter/material.dart';
import '../widgets/diary_entry_card.dart';

class DiaryHistoryScreen extends StatefulWidget {
  const DiaryHistoryScreen({super.key});

  @override
  State<DiaryHistoryScreen> createState() => _DiaryHistoryScreenState();
}

class _DiaryHistoryScreenState extends State<DiaryHistoryScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> diaryEntries = [
    {
      'date': '27/08/2025',
      'hasSmoked': false,
      'cigarettes': 0,
      'cravings': 5.0,
      'mood': 8.0,
      'confidence': 7.5,
      'anxiety': 3.0,
      'notes':
          'Feeling much better today. Had some cravings in the morning but managed to overcome them.',
      'streak': 5,
    },
    {
      'date': '26/08/2025',
      'hasSmoked': true,
      'cigarettes': 2,
      'cravings': 8.0,
      'mood': 4.0,
      'confidence': 3.0,
      'anxiety': 7.0,
      'notes': 'Stressful day at work. Couldn\'t resist during lunch break.',
      'streak': 0,
    },
    {
      'date': '25/08/2025',
      'hasSmoked': false,
      'cigarettes': 0,
      'cravings': 6.0,
      'mood': 7.0,
      'confidence': 6.0,
      'anxiety': 4.0,
      'notes': 'Good day overall. Used breathing exercises when cravings hit.',
      'streak': 4,
    },
    {
      'date': '24/08/2025',
      'hasSmoked': false,
      'cigarettes': 0,
      'cravings': 4.0,
      'mood': 8.5,
      'confidence': 8.0,
      'anxiety': 2.0,
      'notes': 'Excellent day! Feeling confident and strong.',
      'streak': 3,
    },
    {
      'date': '23/08/2025',
      'hasSmoked': false,
      'cigarettes': 0,
      'cravings': 7.0,
      'mood': 6.0,
      'confidence': 5.5,
      'anxiety': 5.0,
      'notes': 'Moderate cravings but stayed strong. Weekend was challenging.',
      'streak': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredEntries = _getFilteredEntries();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Diary History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showAnalytics,
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          const SizedBox(height: 12),
          _buildStatsOverview(),
          const SizedBox(height: 12),
          Expanded(child: _buildHistoryList(filteredEntries)),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Text(
              'Filter: ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    _buildFilterChip('Smoke-Free'),
                    _buildFilterChip('Relapsed'),
                    _buildFilterChip('This Week'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = selectedFilter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedFilter = filter;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF00D09E)
                : const Color(0xFF00D09E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.3)),
          ),
          child: Text(
            filter,
            style: TextStyle(
              color: isSelected ? Colors.white : const Color(0xFF00D09E),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    final smokeFreeCount = diaryEntries
        .where((e) => !(e['hasSmoked'] as bool))
        .length;
    final totalCravings = diaryEntries.fold<double>(
      0.0,
      (sum, e) => sum + ((e['cravings'] as num).toDouble()),
    );
    final avgMood = diaryEntries.isNotEmpty
        ? diaryEntries.fold<double>(
                0.0,
                (s, e) => s + ((e['mood'] as num).toDouble()),
              ) /
              diaryEntries.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00D09E).withOpacity(0.1),
            const Color(0xFF00D09E).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00D09E).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'Smoke-Free Days',
              smokeFreeCount.toString(),
              Icons.check_circle,
              const Color(0xFF4CAF50),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: _buildStatItem(
              'Avg Mood',
              avgMood.toStringAsFixed(1),
              Icons.sentiment_satisfied,
              const Color(0xFF2196F3),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Expanded(
            child: _buildStatItem(
              'Total Entries',
              diaryEntries.length.toString(),
              Icons.book,
              const Color(0xFFFF9800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildHistoryList(List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No entries yet',
          style: TextStyle(color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DiaryEntryCard(
            entry: entry,
            onTap: () {
              // Handle tap if needed
            },
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredEntries() {
    switch (selectedFilter) {
      case 'Smoke-Free':
        return diaryEntries.where((e) => !(e['hasSmoked'] as bool)).toList();
      case 'Relapsed':
        return diaryEntries.where((e) => e['hasSmoked'] as bool).toList();
      case 'This Week':
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        return diaryEntries.where((e) {
          final entryDate = _parseDate(e['date'] as String);
          return entryDate.isAfter(weekAgo);
        }).toList();
      default:
        return diaryEntries;
    }
  }

  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  void _showAnalytics() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalyticsBottomSheet(),
    );
  }

  Widget _buildAnalyticsBottomSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildAnalyticsCard(
                    'Success Rate',
                    '${((diaryEntries.where((e) => !(e['hasSmoked'] as bool)).length / diaryEntries.length) * 100).toStringAsFixed(1)}%',
                    Icons.trending_up,
                    const Color(0xFF4CAF50),
                  ),
                  _buildAnalyticsCard(
                    'Average Cravings',
                    '${(diaryEntries.fold<double>(0.0, (sum, e) => sum + (e['cravings'] as num).toDouble()) / diaryEntries.length).toStringAsFixed(1)}',
                    Icons.psychology,
                    const Color(0xFFE91E63),
                  ),
                  _buildAnalyticsCard(
                    'Mood Trend',
                    'Improving',
                    Icons.sentiment_satisfied,
                    const Color(0xFF2196F3),
                  ),
                  _buildAnalyticsCard(
                    'Confidence Level',
                    '${(diaryEntries.fold<double>(0.0, (sum, e) => sum + (e['confidence'] as num).toDouble()) / diaryEntries.length).toStringAsFixed(1)}/10',
                    Icons.psychology_alt,
                    const Color(0xFFFF9800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

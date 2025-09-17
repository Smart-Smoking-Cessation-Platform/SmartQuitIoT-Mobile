import 'package:flutter/material.dart';

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
          Expanded(
            child: _buildHistoryList(filteredEntries),
          ),
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
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
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
    final smokeFreeCount = diaryEntries.where((e) => !(e['hasSmoked'] as bool)).length;
    final totalCravings = diaryEntries.fold<double>(
      0.0,
          (sum, e) => sum + ((e['cravings'] as num).toDouble()),
    );
    final avgMood = diaryEntries.isNotEmpty
        ? diaryEntries.fold<double>(0.0, (s, e) => s + ((e['mood'] as num).toDouble())) /
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
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildStatItem(
              'Avg Mood',
              avgMood.toStringAsFixed(1),
              Icons.sentiment_satisfied,
              const Color(0xFF2196F3),
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
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

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
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
          child: _buildHistoryCard(entry),
        );
      },
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> entry) {
    final hasSmoked = (entry['hasSmoked'] as bool);
    final statusColor = hasSmoked ? const Color(0xFFE91E63) : const Color(0xFF4CAF50);
    final notes = (entry['notes'] as String?) ?? '';

    return Container(
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
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    hasSmoked ? Icons.smoking_rooms : Icons.check_circle,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry['date'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hasSmoked
                            ? 'Had ${entry['cigarettes'].toString()} cigarettes'
                            : 'Smoke-Free Day',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!hasSmoked)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${entry['streak'].toString()} days',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Metrics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBar(
                        'Cravings',
                        (entry['cravings'] as num).toDouble(),
                        Icons.psychology,
                        const Color(0xFFE91E63),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricBar(
                        'Anxiety',
                        (entry['anxiety'] as num).toDouble(),
                        Icons.sentiment_dissatisfied,
                        const Color(0xFFFF9800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricBar(
                        'Mood',
                        (entry['mood'] as num).toDouble(),
                        Icons.sentiment_satisfied,
                        const Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricBar(
                        'Confidence',
                        (entry['confidence'] as num).toDouble(),
                        Icons.psychology_alt,
                        const Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notes,
                              color: Colors.grey[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Notes',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notes,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricBar(String title, double value, IconData icon, Color color) {
    final normalized = (value.clamp(0.0, 10.0)) / 10.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: normalized,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
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
          final dateStr = (e['date'] as String);
          final parsed = _parseDate(dateStr);
          return parsed.isAfter(weekAgo) || parsed.isAtSameMomentAs(weekAgo);
        }).toList();
      default:
        return diaryEntries;
    }
  }

  DateTime _parseDate(String dateString) {
    // Expecting 'dd/MM/yyyy'. If fails, return epoch fallback.
    try {
      final parts = dateString.split('/');
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
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAnalyticsBottomSheet(),
    );
  }

  Widget _buildAnalyticsBottomSheet() {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text(
                    'View Analytics',
                    style: TextStyle(
                      fontSize: 20,
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
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildAnalyticsCard(
                      'Weekly Progress',
                      'Track your smoking patterns over time',
                      Icons.trending_up,
                      const Color(0xFF4CAF50),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      'Mood Patterns',
                      'Understand your mood changes',
                      Icons.psychology,
                      const Color(0xFF2196F3),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      'Craving Analysis',
                      'Identify triggers and patterns',
                      Icons.analytics,
                      const Color(0xFFE91E63),
                    ),
                    const SizedBox(height: 16),
                    _buildAnalyticsCard(
                      'Success Metrics',
                      'View your achievements and milestones',
                      Icons.emoji_events,
                      const Color(0xFFFF9800),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, String description, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: color,
            size: 16,
          ),
        ],
      ),
    );
  }
}

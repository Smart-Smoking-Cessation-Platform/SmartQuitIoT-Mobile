import 'package:SmartQuitIoT/views/screens/diary/create_diary_screen.dart';
import 'package:flutter/material.dart';
import 'diary_history_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:SmartQuitIoT/providers/diary_record_provider.dart';
import 'package:SmartQuitIoT/models/diary_charts.dart';
import 'package:intl/intl.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    print('📊 [DiaryScreen] Initialized');
    WidgetsBinding.instance.addObserver(this);

    // Force refresh khi vào screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔄 [DiaryScreen] First load - refreshing charts...');
      ref.invalidate(diaryChartsProvider);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Refresh khi app quay lại foreground
    if (state == AppLifecycleState.resumed) {
      print('🔄 [DiaryScreen] App resumed - refreshing charts...');
      if (mounted) {
        ref.invalidate(diaryChartsProvider);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to refresh trigger - auto-refresh when new diary created
    ref.listen<int>(diaryChartsRefreshProvider, (previous, next) {
      if (previous != null && previous != next) {
        print(
          '🔄 [DiaryScreen] Refresh triggered! Previous: $previous, Next: $next',
        );

        // Show subtle refresh notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.refresh, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Refreshing charts...'),
              ],
            ),
            backgroundColor: const Color(0xFF00D09E),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Invalidate charts provider to force refresh
        ref.invalidate(diaryChartsProvider);
      }
    });

    final chartsAsync = ref.watch(diaryChartsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FFFE),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        title: const Text(
          'Diary Analytics',
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
              print('🔄 [DiaryScreen] Manual refresh triggered');
              ref.invalidate(diaryChartsProvider);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.refresh, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text('Refreshing charts...'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF00D09E),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Charts',
          ),
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
            tooltip: 'View History',
          ),
        ],
      ),
      body: chartsAsync.when(
        data: (charts) => RefreshIndicator(
          onRefresh: () async {
            print('🔄 [DiaryScreen] Pull to refresh triggered');
            ref.invalidate(diaryChartsProvider);
            // Wait a bit for the refresh to complete
            await Future.delayed(const Duration(milliseconds: 500));
          },
          color: const Color(0xFF00D09E),
          child: _buildChartsContent(charts),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load charts',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(diaryChartsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsContent(DiaryCharts charts) {
    // Check if all charts are empty
    if (charts.moodLevel.isEmpty &&
        charts.confidenceLevel.isEmpty &&
        charts.cravingLevel.isEmpty &&
        charts.anxietyLevel.isEmpty &&
        charts.cigarettesSmoked.isEmpty &&
        charts.reductionPercentage.isEmpty &&
        charts.estimatedNicotineIntake.isEmpty) {
      // Wrap empty state với ListView để pull-to-refresh work
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [_buildEmptyState()],
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Entry Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDiaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Entry new diary'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Charts Section
          if (charts.moodLevel.isNotEmpty)
            _buildChartCard(
              'Mood Level',
              charts.moodLevel
                  .map((e) => ChartDataPoint(e.date, e.moodLevel.toDouble()))
                  .toList(),
              const Color(0xFF2196F3),
              Icons.sentiment_satisfied,
            ),
          if (charts.confidenceLevel.isNotEmpty)
            _buildChartCard(
              'Confidence Level',
              charts.confidenceLevel
                  .map(
                    (e) => ChartDataPoint(e.date, e.confidenceLevel.toDouble()),
                  )
                  .toList(),
              const Color(0xFFFF9800),
              Icons.psychology_alt,
            ),
          if (charts.cravingLevel.isNotEmpty)
            _buildChartCard(
              'Craving Level',
              charts.cravingLevel
                  .map((e) => ChartDataPoint(e.date, e.cravingLevel.toDouble()))
                  .toList(),
              const Color(0xFFE91E63),
              Icons.psychology,
            ),
          if (charts.anxietyLevel.isNotEmpty)
            _buildChartCard(
              'Anxiety Level',
              charts.anxietyLevel
                  .map((e) => ChartDataPoint(e.date, e.anxietyLevel.toDouble()))
                  .toList(),
              const Color(0xFF9C27B0),
              Icons.mood_bad,
            ),
          if (charts.cigarettesSmoked.isNotEmpty)
            _buildChartCard(
              'Cigarettes Smoked',
              charts.cigarettesSmoked
                  .map((e) => ChartDataPoint(e.date, e.cigarettesSmoked.toDouble()))
                  .toList(),
              const Color(0xFFF44336),
              Icons.smoking_rooms,
            ),
          if (charts.reductionPercentage.isNotEmpty)
            _buildChartCard(
              'Reduction Percentage',
              charts.reductionPercentage
                  .map((e) => ChartDataPoint(e.date, e.reductionPercentage))
                  .toList(),
              const Color(0xFF4CAF50),
              Icons.trending_down,
            ),
          if (charts.estimatedNicotineIntake.isNotEmpty)
            _buildChartCard(
              'Estimated Nicotine Intake',
              charts.estimatedNicotineIntake
                  .map((e) => ChartDataPoint(e.date, e.estimatedNicotineIntake))
                  .toList(),
              const Color(0xFF795548),
              Icons.water_drop,
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.insert_chart_outlined,
              size: 120,
              color: Color(0xFF00D09E),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Data Available',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Start tracking your progress by creating diary entries',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateDiaryScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Create First Entry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00D09E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
      String title,
      List<ChartDataPoint> data,
      Color color,
      IconData icon,
      ) {
    // 1. Kiểm tra dữ liệu rỗng
    if (data.isEmpty) return const SizedBox();

    // 2. Tìm Min/Max thực tế của dữ liệu
    double minVal = data.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    double maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // 3. Cờ kiểm tra xem có số âm không
    bool hasNegative = minVal < 0;

    // Khai báo biến
    double minY;
    double maxY;
    double interval;

    // =========================================================================
    // CASE 1: LOGIC CŨ (Giữ nguyên cho các chart dương như Mood, Cigarettes...)
    // =========================================================================
    if (!hasNegative) {
      minY = 0; // Logic cũ luôn set min là 0

      // --- [Đoạn này copy từ code gốc của bạn] ---
      if (maxVal <= 10) {
        maxY = 10;
        interval = 2;
      } else if (maxVal <= 100) {
        maxY = 100;
        interval = 20;
      } else {
        maxY = (maxVal * 1.2).ceilToDouble();
        maxY = ((maxY / 10).ceil() * 10).toDouble();

        if (maxY < 50) {
          interval = 10;
        } else if (maxY < 100) {
          interval = 20;
        } else {
          interval = maxY / 5;
          interval = ((interval / 10).ceil() * 10).toDouble();
        }
      }
    }
    // =========================================================================
    // CASE 2: LOGIC MỚI (Chỉ chạy khi dữ liệu bị ÂM, ví dụ Reduction Rate -300)
    // =========================================================================
    else {
      // Tính khoảng cách giữa Max và Min
      double range = maxVal - minVal;

      // Thêm padding 10% trên dưới để đường line không chạm mép
      double padding = range * 0.1;

      maxY = maxVal + padding;
      minY = minVal - padding;

      // Làm tròn số Min/Max về hàng chục cho đẹp (Ví dụ -312 -> -320)
      maxY = ((maxY / 10).ceil() * 10).toDouble();
      minY = ((minY / 10).floor() * 10).toDouble();

      // Tính interval chia làm 5 phần
      interval = (maxY - minY) / 5;

      // Làm tròn interval
      interval = ((interval / 10).ceil() * 10).toDouble();
      if (interval == 0) interval = 10;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) {
                    // Logic UI: Nếu đang ở chế độ số âm, vẽ đường 0 đậm hơn chút cho dễ nhìn
                    if (hasNegative && (value >= -1 && value <= 1)) {
                      return FlLine(
                          color: Colors.grey[400]!,
                          strokeWidth: 1.5,
                          dashArray: [4, 4] // Nét đứt
                      );
                    }
                    return FlLine(color: Colors.grey[200]!, strokeWidth: 1);
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      // Nếu có số âm (ví dụ -300) thì cần lề rộng hơn (45) so với bình thường (40)
                      reservedSize: hasNegative ? 48 : 40,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        // Ẩn số nếu nó trùng với mép trên hoặc dưới cùng để đỡ bị cắt
                        if (value == maxY || value == minY) return const SizedBox();

                        return Text(
                          value % interval == 0
                              ? (value.toInt() == value
                              ? value.toInt().toString()
                              : value.toStringAsFixed(1))
                              : '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.right,
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value != value.toInt()) {
                          return const Text('');
                        }
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          final date = DateTime.parse(data[value.toInt()].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                    left: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                minX: -0.3,
                maxX: (data.length - 1).toDouble() + 0.3,

                // QUAN TRỌNG: Dùng biến minY đã tính toán thay vì fix cứng số 0
                minY: minY,
                maxY: maxY,

                lineBarsData: [
                  LineChartBarData(
                    spots: data.asMap().entries.map((e) {
                      return FlSpot(e.key.toDouble(), e.value.value);
                    }).toList(),
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          // Nếu giá trị âm, hiển thị màu đỏ cho user chú ý (hoặc giữ nguyên màu color nếu muốn)
                          color: (hasNegative && spot.y < 0) ? Colors.redAccent : color,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withOpacity(0.1),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = DateTime.parse(data[spot.x.toInt()].date);
                        final value = spot.y % 1 == 0
                            ? spot.y.toInt().toString()
                            : spot.y.toStringAsFixed(1);
                        return LineTooltipItem(
                          '${DateFormat('MMM dd').format(date)}\n$value',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataPoint {
  final String date;
  final double value;

  ChartDataPoint(this.date, this.value);
}

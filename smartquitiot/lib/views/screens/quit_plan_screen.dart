import 'package:flutter/material.dart';

class QuitPlanScreen extends StatefulWidget {
  const QuitPlanScreen({super.key});

  @override
  State<QuitPlanScreen> createState() => _QuitPlanScreenState();
}

class _QuitPlanScreenState extends State<QuitPlanScreen> {
  int selectedIndex = 0;

  final stages = [
    'Preparation',
    'On Set',
    'Peak Craving',
    'Subsiding',
    'Maintenance'
  ];

  final stageDates = [
    '15/09/2025 - 17/09/2025',
    '18/09/2025 - 20/09/2025',
    '21/09/2025 - 23/09/2025',
    '24/09/2025 - 27/09/2025',
    '28/09/2025 - 30/09/2025',
  ];

  final stageProgress = [0.2, 0.4, 0.6, 0.8, 1.0];

  final stageTarget = [0.5, 0.6, 0.7, 0.8, 1.0];

  final colors = [
    const Color(0xFF00D09E),
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    final currentColor = colors[selectedIndex];
    final currentProgress = stageProgress[selectedIndex];
    final currentPercent = (currentProgress * 100).toStringAsFixed(0);
    final targetProgress = stageTarget[selectedIndex];
    final targetPercent = (targetProgress * 100).toStringAsFixed(0);

    return Scaffold(
      backgroundColor: const Color(0xFFDFF7E2),
      appBar: AppBar(
        title: const Text('Quit Plan'),
        centerTitle: true,
        backgroundColor: const Color(0xFF00D09E),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Thanh giai đoạn
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: List.generate(stages.length, (index) {
                final isSelected = selectedIndex == index;
                final color = colors[index];
                return Expanded(
                  child: InkWell(
                    onTap: () => setState(() => selectedIndex = index),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.15)
                            : Colors.transparent,
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? color : Colors.grey.shade300,
                            width: 3,
                          ),
                        ),
                      ),
                      child: Text(
                        stages[index],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? color : Colors.black87,
                          fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Hiện ngày
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.date_range, size: 20, color: currentColor),
                const SizedBox(width: 8),
                Text(
                  stageDates[selectedIndex],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: currentColor,
                  ),
                ),
              ],
            ),
          ),

          // Pass Condition + Stage Status + Progress Bar + Current/Target + Craving/No Smoking
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dòng Pass Condition + Stage Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Pass Condition',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      
                    ),
                    Builder(builder: (context) {
                      String statusText;
                      Color textColor;
                      Color bgColor;

                      if (selectedIndex == 0) {
                        statusText = "In Progress";
                        textColor = Colors.white;
                        bgColor = Colors.green.withOpacity(0.85);
                      } else if (selectedIndex < 0) { // không dùng, nhưng giữ ví dụ Completed
                        statusText = "Completed";
                        textColor = Colors.white;
                        bgColor = Colors.grey.shade600.withOpacity(0.85);
                      } else {
                        statusText = "Upcoming";
                        textColor = Colors.orange.shade800;
                        bgColor = Colors.orange.shade100.withOpacity(0.5);
                      }

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 22), // khoảng cách xuống thanh
                LayoutBuilder(
                  builder: (context, constraints) {
                    final fullWidth = constraints.maxWidth;
                    final currentWidth = fullWidth * currentProgress;
                    final targetX = fullWidth * targetProgress;

                    return SizedBox(
                      height: 50,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // nền progress
                          Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: currentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // tiến độ
                          Container(
                            height: 18,
                            width: currentWidth,
                            decoration: BoxDecoration(
                              color: currentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // số % current trên thanh, màu giai đoạn
                          Positioned(
                            left: (currentWidth - 20).clamp(0, fullWidth - 40),
                            top: -20,
                            child: Text(
                              '$currentPercent%',
                              style: TextStyle(
                                  color: currentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                          // marker target
                          Positioned(
                            left: targetX - 1,
                            top: 0,
                            child: Container(
                              width: 2,
                              height: 24,
                              color: Colors.red,
                            ),
                          ),
                          // số % target trên marker, dính sát vạch đỏ
                          Positioned(
                            left: (targetX - 16).clamp(0, fullWidth - 40),
                            top: -20,
                            child: Text(
                              '$targetPercent%',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Current & Target Text dưới progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: $currentPercent%',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold, color: currentColor),
                    ),
                    Text(
                      'Target: $targetPercent%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Hiển thị 2 dòng Craving & No Smoking chỉ khi không phải giai đoạn Preparation
                if (selectedIndex > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Craving level:',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '4 / 6', // current / target, có thể đổi thành biến
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: currentColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'No Smoking day:',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '5 / 2', // current / target
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: currentColor),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),



          // Nội dung
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateGridCard(),
                  const SizedBox(height: 16),
                  _buildMissionCard(),
                  const SizedBox(height: 16),
                  _buildProgressCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================== DATE GRID CARD ==================
  Widget _buildDateGridCard() {
    final items = List.generate(8, (i) => 'Ngày ${i + 1}');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lịch trình',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(items[index],
                    style: const TextStyle(fontSize: 12)),
              );
            },
          ),
        ],
      ),
    );
  }

  /// ================== MISSION CARD ==================
  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text('Nhiệm vụ hôm nay (giữ nguyên nội dung)'),
    );
  }

  /// ================== PROGRESS CARD ==================
  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Tiến trình', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LinearProgressIndicator(value: 0.5),
          SizedBox(height: 8),
          Text('50% hoàn thành'),
        ],
      ),
    );
  }
}

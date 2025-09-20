import 'package:flutter/material.dart';

import 'package:SmartQuitIoT/views/screens/diary/diary_screen.dart';

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
    'Maintenance',
  ];

  final stageDates = [
    '15/09/2025 - 17/09/2025',
    '18/09/2025 - 20/09/2025',
    '21/09/2025 - 23/09/2025',
    '24/09/2025 - 27/09/2025',
    '28/09/2025 - 30/09/2025',
  ];

  List<Map<String, dynamic>> missions = [
    {'title': 'Không hút thuốc buổi sáng', 'completed': false},
    {'title': 'Không hút thuốc khi căng thẳng', 'completed': false},
    {'title': 'Đi bộ 15 phút', 'completed': true},
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
          // Stage bar
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
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          // Stage dates
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

          // Progress + Status
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pass Condition + Status
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
                    Builder(
                      builder: (context) {
                        String statusText;
                        Color textColor;
                        Color bgColor;

                        if (selectedIndex == 0) {
                          statusText = "In Progress";
                          textColor = Colors.white;
                          bgColor = Colors.green.withOpacity(0.85);
                        } else if (selectedIndex < 0) {
                          statusText = "Completed";
                          textColor = Colors.white;
                          bgColor = Colors.grey.shade600.withOpacity(0.85);
                        } else {
                          statusText = "Upcoming";
                          textColor = Colors.orange.shade800;
                          bgColor = Colors.orange.shade100.withOpacity(0.5);
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
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
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),
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
                          // Background progress
                          Container(
                            height: 18,
                            decoration: BoxDecoration(
                              color: currentColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // Current progress
                          Container(
                            height: 18,
                            width: currentWidth,
                            decoration: BoxDecoration(
                              color: currentColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          // Current percent
                          Positioned(
                            left: (currentWidth - 20).clamp(0, fullWidth - 40),
                            top: -20,
                            child: Text(
                              '$currentPercent%',
                              style: TextStyle(
                                color: currentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          // Target marker
                          Positioned(
                            left: targetX - 1,
                            top: 0,
                            child: Container(
                              width: 2,
                              height: 24,
                              color: Colors.red,
                            ),
                          ),
                          // Target percent
                          Positioned(
                            left: (targetX - 16).clamp(0, fullWidth - 40),
                            top: -20,
                            child: Text(
                              '$targetPercent%',
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current: $currentPercent%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: currentColor,
                      ),
                    ),
                    Text(
                      'Target: $targetPercent%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (selectedIndex > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Craving level:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '4 / 6',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: currentColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'No Smoking day:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '5 / 2',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: currentColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateGridCard(),
                  const SizedBox(height: 16),
                  _buildMissionGridCard(),
                  const SizedBox(height: 16),

                  // Nút Go to Diary
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Go to Diary pressed!')),
                        );
                        // TODO: Thêm navigation tới DiaryScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DiaryScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00D09E),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        'Go to Diary',
                        style: TextStyle(
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
        ],
      ),
    );
  }

  Widget _buildMissionGridCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Missions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: missions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            mainAxisExtent: 70,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final mission = missions[index];
            final completed = mission['completed'] as bool;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Image.asset(
                    'lib/assets/gold-cup.png',
                    width: 28,
                    height: 28,
                    color: completed ? null : Colors.grey.shade400,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      mission['title'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: completed
                            ? Colors.amber.shade700
                            : Colors.black87,
                      ),
                    ),
                  ),
                  if (completed)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.yellow.shade400,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Completed',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDateGridCard() {
    final days = List.generate(8, (i) => i + 1);
    final dates = [
      '15/09',
      '16/09',
      '17/09',
      '18/09',
      '19/09',
      '20/09',
      '21/09',
      '22/09',
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final isCurrent = index == selectedIndex;
          final isCompleted = index < selectedIndex;

          final bgColor = isCurrent
              ? Colors.green.shade400
              : isCompleted
              ? Colors.grey.shade300
              : Colors.white;
          final textColor = isCurrent || isCompleted
              ? Colors.white
              : Colors.black87;

          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Day ${days[index]}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dates[index],
                  style: TextStyle(fontSize: 12, color: textColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

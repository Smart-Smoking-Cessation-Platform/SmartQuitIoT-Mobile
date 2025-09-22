import 'package:flutter/material.dart';

class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final double? progress;
  final String? completedDate;
  final Color categoryColor;
  final VoidCallback? onTap;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    this.progress,
    this.completedDate,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isCompleted
              ? Border.all(color: const Color(0xFF00D09E), width: 2)
              : Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF00D09E)
                    : categoryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isCompleted
                    ? [
                        BoxShadow(
                          color: const Color(0xFF00D09E).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                icon,
                color: isCompleted ? Colors.white : categoryColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                          ? const Color(0xFF00D09E)
                          : const Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  if (!isCompleted && progress != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: progress!,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                categoryColor,
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${(progress! * 100).toInt()}%',
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (isCompleted) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF00D09E),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Completed on $completedDate',
                          style: const TextStyle(
                            color: Color(0xFF00D09E),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isCompleted)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D09E).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.star, color: Colors.white, size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

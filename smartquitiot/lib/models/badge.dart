// models/badge.dart
import 'package:flutter/material.dart';

class Badge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedDate;
  final String detailDescription;
  final List<String> benefits;

  // 👇 thêm dòng này
  final String imagePath;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isUnlocked,
    this.unlockedDate,
    required this.detailDescription,
    required this.benefits,
    required this.imagePath, // 👈 thêm vào constructor
  });
}

class BadgeData {
  static List<Badge> getBadges() {
    return [
      Badge(
        id: '1',
        title: '24 Giờ Đầu Tiên',
        description: 'Không hút thuốc trong 24 giờ',
        icon: Icons.access_time,
        color: Colors.blue,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(Duration(days: 10)),
        detailDescription:
            'Chúc mừng! Bạn đã vượt qua 24 giờ đầu tiên không hút thuốc. Đây là bước đầu tiên quan trọng nhất trong hành trình cai thuốc của bạn.',
        benefits: [
          'Nồng độ CO trong máu giảm xuống mức bình thường',
          'Tim và phổi bắt đầu phục hồi',
          'Giảm nguy cơ đau tim',
          'Cải thiện lưu thông máu',
        ],
        imagePath: 'lib/assets/Achievement.png', // 👈 ảnh mẫu
      ),
      Badge(
        id: '2',
        title: 'Tuần Đầu Tiên',
        description: 'Hoàn thành 1 tuần không thuốc lá',
        icon: Icons.calendar_view_week,
        color: Colors.orange,
        isUnlocked: true,
        unlockedDate: DateTime.now().subtract(Duration(days: 5)),
        detailDescription:
            'Tuyệt vời! Một tuần đã trôi qua và bạn vẫn kiên trì. Cơ thể bạn đang bắt đầu làm sạch nicotine.',
        benefits: [
          'Vị giác và khứu giác bắt đầu cải thiện',
          'Hơi thở thơm hơn',
          'Răng trắng hơn',
          'Tiết kiệm được một số tiền đáng kể',
        ],
        imagePath: 'lib/assets/Achievement.png', // 👈 ảnh mẫu
      ),
      Badge(
        id: '3',
        title: 'Tháng Đầu Tiên',
        description: '30 ngày mạnh mẽ',
        icon: Icons.calendar_month,
        color: Colors.purple,
        isUnlocked: false,
        detailDescription:
            'Một tháng không hút thuốc là một thành tựu lớn! Cơ thể bạn đã thay đổi đáng kể.',
        benefits: [
          'Chức năng phổi cải thiện 30%',
          'Giảm ho và khò khè',
          'Tăng năng lượng đáng kể',
          'Cải thiện tuần hoàn máu',
        ],
        imagePath: 'lib/assets/Achievement.png', // 👈 ảnh mẫu
      ),
      // ... các badge tiếp theo cũng thêm imagePath tương tự
    ];
  }
}

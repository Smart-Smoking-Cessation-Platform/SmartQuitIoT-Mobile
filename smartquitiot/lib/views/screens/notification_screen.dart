import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  void _navigateToDetail(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(
          title: title,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // đổi màu nền body
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
        // đổi header
        backgroundColor: const Color(0xFF00D09E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Earlier section
              Padding(
                padding: const EdgeInsets.only(top: 10.0), // 👈 đẩy xuống 8px
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Earlier',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '251 Total',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Notification items
              _buildNotificationItem(
                context: context,
                icon: Icons.chat_bubble,
                iconColor: Colors.blue,
                title: 'Unread AI Chatbot Message',
                subtitle: 'Doc A just sent you 3 messages!',
              ),
              _buildNotificationItem(
                context: context,
                icon: Icons.check_circle,
                iconColor: Colors.purple,
                title: 'Activity Completed',
                subtitle: 'You have finished logging.',
              ),
              _buildNotificationItem(
                context: context,
                icon: Icons.favorite,
                iconColor: Colors.teal,
                title: 'Monthly Health Insight',
                subtitle: 'Your monthly health insight is ready.',
                hasDownload: true,
              ),
              _buildNotificationItem(
                context: context,
                icon: Icons.directions_walk,
                iconColor: Colors.blue,
                title: 'Take More Steps!',
                subtitle: 'Take 3150 more steps today.',
              ),
              _buildNotificationItem(
                context: context,
                icon: Icons.bedtime,
                iconColor: Colors.grey,
                title: 'Sleep More!',
                subtitle: 'Take at least 8hr sleep.',
                hasProgress: true,
                progress: '14%',
              ),

              const SizedBox(height: 32),

              // Last Week section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Last Week',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '11 Total',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Last week notification
              _buildLastWeekNotification(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    bool hasDownload = false,
    bool hasProgress = false,
    String? progress,
  }) {
    return GestureDetector(
      onTap: () => _navigateToDetail(context, title, subtitle, icon, iconColor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  if (hasDownload) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: const [
                        Icon(Icons.download, size: 16, color: Colors.teal),
                        SizedBox(width: 4),
                        Text(
                          'DOWNLOAD PDF',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (hasProgress && progress != null)
              Text(
                progress,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastWeekNotification(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToDetail(
        context,
        'Daily Vitamin Completed',
        'You have taken 500mg of vitamins.',
        Icons.favorite,
        Colors.red,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You have fulfilled daily vitamin dose.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You have taken 500mg of vitamins.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVitaminPill('Vitamin A', Colors.orange),
                      const SizedBox(width: 8),
                      _buildVitaminPill('Ibuprofen', Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        '2+',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitaminPill(String name, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Notification Detail placeholder
class NotificationDetailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  const NotificationDetailScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF00D09E),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Notification Detail',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }
}

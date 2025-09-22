import 'package:flutter/material.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_item.dart';
import 'package:SmartQuitIoT/views/screens/notifications/notification_detail_screen.dart';
import 'package:SmartQuitIoT/views/widgets/headers/section_header.dart';
import 'package:SmartQuitIoT/views/widgets/cards/last_week_notification_card.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
      backgroundColor: const Color(0xFFF1FFF3),
      appBar: AppBar(
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
              const SectionHeader(title: 'Earlier', subtitle: '251 Total'),
              const SizedBox(height: 16),

              NotificationItem(
                icon: Icons.chat_bubble,
                iconColor: Colors.blue,
                title: 'Unread AI Chatbot Message',
                subtitle: 'Doc A just sent you 3 messages!',
                onTap: () => _navigateToDetail(
                  context,
                  'Unread AI Chatbot Message',
                  'Doc A just sent you 3 messages!',
                  Icons.chat_bubble,
                  Colors.blue,
                ),
              ),
              NotificationItem(
                icon: Icons.check_circle,
                iconColor: Colors.purple,
                title: 'Activity Completed',
                subtitle: 'You have finished logging.',
                onTap: () => _navigateToDetail(
                  context,
                  'Activity Completed',
                  'You have finished logging.',
                  Icons.check_circle,
                  Colors.purple,
                ),
              ),
              NotificationItem(
                icon: Icons.favorite,
                iconColor: Colors.teal,
                title: 'Monthly Health Insight',
                subtitle: 'Your monthly health insight is ready.',
                hasDownload: true,
                onTap: () => _navigateToDetail(
                  context,
                  'Monthly Health Insight',
                  'Your monthly health insight is ready.',
                  Icons.favorite,
                  Colors.teal,
                ),
              ),
              NotificationItem(
                icon: Icons.directions_walk,
                iconColor: Colors.blue,
                title: 'Take More Steps!',
                subtitle: 'Take 3150 more steps today.',
                onTap: () => _navigateToDetail(
                  context,
                  'Take More Steps!',
                  'Take 3150 more steps today.',
                  Icons.directions_walk,
                  Colors.blue,
                ),
              ),
              NotificationItem(
                icon: Icons.bedtime,
                iconColor: Colors.grey,
                title: 'Sleep More!',
                subtitle: 'Take at least 8hr sleep.',
                hasProgress: true,
                progress: '14%',
                onTap: () => _navigateToDetail(
                  context,
                  'Sleep More!',
                  'Take at least 8hr sleep.',
                  Icons.bedtime,
                  Colors.grey,
                ),
              ),

              const SizedBox(height: 32),
              const SectionHeader(title: 'Last Week', subtitle: '11 Total'),
              const SizedBox(height: 16),

              LastWeekNotificationCard(
                title: 'You have fulfilled daily vitamin dose.',
                subtitle: 'You have taken 500mg of vitamins.',
                icon: Icons.favorite,
                iconColor: Colors.red,
                vitaminPills: [
                  {'name': 'Vitamin A', 'color': Colors.orange},
                  {'name': 'Ibuprofen', 'color': Colors.blue},
                ],
                onTap: () => _navigateToDetail(
                  context,
                  'Daily Vitamin Completed',
                  'You have taken 500mg of vitamins.',
                  Icons.favorite,
                  Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

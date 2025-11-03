// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:SmartQuitIoT/views/screens/notifications/notification_item.dart';
// import 'package:SmartQuitIoT/views/screens/notifications/notification_detail_screen.dart';
// import 'package:SmartQuitIoT/providers/websocket_provider.dart';
// import 'package:SmartQuitIoT/models/achievement_notification.dart';
// import 'package:intl/intl.dart';

// class NotificationsScreen extends ConsumerStatefulWidget {
//   const NotificationsScreen({super.key});

//   @override
//   ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {

//   void _navigateToDetail(AchievementNotification notification) {
//     // Mark as read when opening
//     ref.read(achievementNotificationsProvider.notifier).markAsRead(notification.id);
    
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => NotificationDetailScreen(
//           title: notification.title,
//           subtitle: notification.content,
//           icon: _getNotificationIcon(notification.type),
//           iconColor: _getNotificationColor(notification.type),
//         ),
//       ),
//     );
//   }

//   IconData _getNotificationIcon(String type) {
//     switch (type.toUpperCase()) {
//       case 'ACHIEVEMENT':
//         return Icons.emoji_events;
//       case 'MISSION':
//         return Icons.check_circle;
//       case 'HEALTH':
//         return Icons.favorite;
//       case 'SOCIAL':
//         return Icons.people;
//       case 'REMINDER':
//         return Icons.notifications_active;
//       default:
//         return Icons.notifications;
//     }
//   }

//   Color _getNotificationColor(String type) {
//     switch (type.toUpperCase()) {
//       case 'ACHIEVEMENT':
//         return Colors.amber;
//       case 'MISSION':
//         return Colors.green;
//       case 'HEALTH':
//         return Colors.red;
//       case 'SOCIAL':
//         return Colors.blue;
//       case 'REMINDER':
//         return Colors.purple;
//       default:
//         return const Color(0xFF00D09E);
//     }
//   }

//   String _formatNotificationTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);

//     if (difference.inMinutes < 1) {
//       return 'Just now';
//     } else if (difference.inMinutes < 60) {
//       return '${difference.inMinutes}m ago';
//     } else if (difference.inHours < 24) {
//       return '${difference.inHours}h ago';
//     } else if (difference.inDays < 7) {
//       return '${difference.inDays}d ago';
//     } else {
//       return DateFormat('MMM d, y').format(dateTime);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final notifications = ref.watch(achievementNotificationsProvider);
    
//     // Separate notifications by date
//     final today = DateTime.now();
//     final todayNotifications = notifications.where((n) => 
//       n.createdAt.year == today.year &&
//       n.createdAt.month == today.month &&
//       n.createdAt.day == today.day
//     ).toList();
    
//     final olderNotifications = notifications.where((n) => 
//       !(n.createdAt.year == today.year &&
//         n.createdAt.month == today.month &&
//         n.createdAt.day == today.day)
//     ).toList();
    
//     return Scaffold(
//       backgroundColor: const Color(0xFFF1FFF3),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF00D09E),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Notifications',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 18,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//         actions: [
//           if (notifications.isNotEmpty)
//             PopupMenuButton<String>(
//               icon: const Icon(Icons.more_vert, color: Colors.white),
//               onSelected: (value) {
//                 if (value == 'clear_all') {
//                   _showClearAllDialog();
//                 }
//               },
//               itemBuilder: (context) => [
//                 const PopupMenuItem(
//                   value: 'clear_all',
//                   child: Row(
//                     children: [
//                       Icon(Icons.delete_outline, color: Colors.red),
//                       SizedBox(width: 8),
//                       Text('Clear All'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//       body: notifications.isEmpty
//           ? _buildEmptyState()
//           : RefreshIndicator(
//               onRefresh: () async {
//                 await ref.read(achievementNotificationsProvider.notifier).refresh();
//               },
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (todayNotifications.isNotEmpty) ...[
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Today',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             Text(
//                               '${todayNotifications.length} notification${todayNotifications.length != 1 ? "s" : ""}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...todayNotifications.map((notification) => 
//                         _buildNotificationItem(notification)
//                       ),
//                     ],
//                     if (olderNotifications.isNotEmpty) ...[
//                       const SizedBox(height: 32),
//                       Container(
//                         padding: const EdgeInsets.symmetric(vertical: 8),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Earlier',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[800],
//                               ),
//                             ),
//                             Text(
//                               '${olderNotifications.length} notification${olderNotifications.length != 1 ? "s" : ""}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ...olderNotifications.map((notification) => 
//                         _buildNotificationItem(notification)
//                       ),
//                     ],
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }

//   Widget _buildNotificationItem(AchievementNotification notification) {
//     return NotificationItem(
//       icon: _getNotificationIcon(notification.type),
//       iconColor: _getNotificationColor(notification.type),
//       title: notification.title,
//       subtitle: '${notification.content} • ${_formatNotificationTime(notification.createdAt)}',
//       isUnread: !notification.isRead,
//       onTap: () => _navigateToDetail(notification),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(40.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.notifications_none,
//               size: 80,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'No Notifications Yet',
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey[800],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'You\'ll receive notifications about achievements,\nmissions, and health updates here.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showClearAllDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Clear All Notifications'),
//         content: const Text(
//           'Are you sure you want to clear all notifications? This action cannot be undone.',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               ref.read(achievementNotificationsProvider.notifier).clearAll();
//               Navigator.pop(context);
//             },
//             style: TextButton.styleFrom(
//               foregroundColor: Colors.red,
//             ),
//             child: const Text('Clear All'),
//           ),
//         ],
//       ),
//     );
//   }
// }

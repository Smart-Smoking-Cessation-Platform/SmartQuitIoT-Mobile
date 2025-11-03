import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/services/websocket_service.dart';
import 'package:SmartQuitIoT/services/local_notification_service.dart';
import 'package:SmartQuitIoT/services/notification_storage_service.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';

// WebSocket Service Provider
final websocketServiceProvider = Provider<WebSocketService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return WebSocketService(authRepository);
});

// Local Notification Service Provider
final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  return LocalNotificationService();
});

// Notification Storage Service Provider
// final notificationStorageServiceProvider = Provider<NotificationStorageService>(
//   (ref) {
//     return NotificationStorageService();
//   },
// );

// Achievement Notifications State Provider
// final achievementNotificationsProvider =
//     StateNotifierProvider<
//       AchievementNotificationsNotifier,
//       List<AchievementNotification>
//     >((ref) {
//       final storageService = ref.watch(notificationStorageServiceProvider);
//       return AchievementNotificationsNotifier(storageService);
//     });

class AchievementNotificationsNotifier
    extends StateNotifier<List<AchievementNotification>> {
  // final NotificationStorageService _storageService;

//   AchievementNotificationsNotifier(this._storageService) : super([]) {
//     // Load cached notifications on init
//     _loadCachedNotifications();
//   }

//   /// Load notifications from storage on init
//   Future<void> _loadCachedNotifications() async {
//     final cachedNotifications = await _storageService.loadNotifications();
//     state = cachedNotifications;
//   }

//   /// Add new notification and save to storage
//   Future<void> addNotification(AchievementNotification notification) async {
//     // Add to state
//     state = [notification, ...state];

//     // Save to storage
//     await _storageService.saveNotifications(state);
//   }

//   /// Mark notification as read and save to storage
//   Future<void> markAsRead(int notificationId) async {
//     // Update state
//     state = state.map((notif) {
//       if (notif.id == notificationId) {
//         return notif.copyWith(isRead: true);
//       }
//       return notif;
//     }).toList();

//     // Save to storage
//     await _storageService.saveNotifications(state);
//   }

//   /// Clear all notifications and storage
//   Future<void> clearAll() async {
//     state = [];
//     await _storageService.clearAll();
//   }

//   /// Refresh notifications from storage
//   Future<void> refresh() async {
//     await _loadCachedNotifications();
//   }

//   int get unreadCount => state.where((n) => !n.isRead).length;
// }

// WebSocket Manager Provider - Handles connection lifecycle
final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  final websocketService = ref.watch(websocketServiceProvider);
  final localNotificationService = ref.watch(localNotificationServiceProvider);
  final notificationsNotifier = ref.watch(
    achievementNotificationsProvider.notifier,
  );

  return WebSocketManager(
    websocketService,
    localNotificationService,
    notificationsNotifier,
  );
});

class WebSocketManager {
  final WebSocketService _websocketService;
  final LocalNotificationService _localNotificationService;
  final AchievementNotificationsNotifier _notificationsNotifier;
  StreamSubscription<AchievementNotification>? _subscription;

  WebSocketManager(
    this._websocketService,
    this._localNotificationService,
    this._notificationsNotifier,
  );

  Future<void> initialize(int userId) async {
    await _localNotificationService.initialize();
    await _localNotificationService.requestPermissions();

    // Listen to notification stream
    _subscription = _websocketService.notificationStream.listen((notification) {
      // Add to state
      _notificationsNotifier.addNotification(notification);

      // Show local notification
      _localNotificationService.showAchievementNotification(notification);
    });

    // Connect WebSocket
    await _websocketService.connect(userId);
  }

  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _websocketService.disconnect();
  }

  void dispose() {
    _subscription?.cancel();
    _websocketService.dispose();
  }
}

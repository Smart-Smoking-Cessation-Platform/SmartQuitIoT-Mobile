import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/services/websocket_service.dart';
import 'package:SmartQuitIoT/services/local_notification_service.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';
import 'package:SmartQuitIoT/providers/achievement_refresh_provider.dart';
import 'package:SmartQuitIoT/providers/notification_refresh_provider.dart';
import 'package:SmartQuitIoT/providers/mission_refresh_provider.dart';
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

// Achievement Notifications State Provider (deprecated - use notification_provider instead)
// This is kept for backward compatibility with WebSocket
final achievementNotificationsProvider =
    StateNotifierProvider<
      AchievementNotificationsNotifier,
      List<AchievementNotification>
    >((ref) {
      return AchievementNotificationsNotifier();
    });

class AchievementNotificationsNotifier
    extends StateNotifier<List<AchievementNotification>> {
  AchievementNotificationsNotifier() : super([]);

  void addNotification(AchievementNotification notification) {
    state = [notification, ...state];
  }

  void markAsRead(int notificationId) {
    state = state.map((notif) {
      if (notif.id == notificationId) {
        return notif.copyWith(isRead: true);
      }
      return notif;
    }).toList();
  }

  void clearAll() {
    state = [];
  }

  int get unreadCount => state.where((n) => !n.isRead).length;
}

// WebSocket Manager Provider - Handles connection lifecycle
final websocketManagerProvider = Provider<WebSocketManager>((ref) {
  final websocketService = ref.watch(websocketServiceProvider);
  final localNotificationService = ref.watch(localNotificationServiceProvider);
  final notificationsNotifier = ref.watch(
    achievementNotificationsProvider.notifier,
  );
  final achievementRefreshNotifier = ref.watch(
    achievementRefreshProvider.notifier,
  );
  final notificationRefreshNotifier = ref.watch(
    notificationRefreshProvider.notifier,
  );
  final missionRefreshNotifier = ref.watch(missionRefreshProvider.notifier);

  return WebSocketManager(
    websocketService,
    localNotificationService,
    notificationsNotifier,
    achievementRefreshNotifier,
    notificationRefreshNotifier,
    missionRefreshNotifier,
  );
});

class WebSocketManager {
  final WebSocketService _websocketService;
  final LocalNotificationService _localNotificationService;
  final AchievementNotificationsNotifier _notificationsNotifier;
  final AchievementRefreshNotifier _achievementRefreshNotifier;
  final NotificationRefreshNotifier _notificationRefreshNotifier;
  final MissionRefreshNotifier _missionRefreshNotifier;
  StreamSubscription<AchievementNotification>? _subscription;

  WebSocketManager(
    this._websocketService,
    this._localNotificationService,
    this._notificationsNotifier,
    this._achievementRefreshNotifier,
    this._notificationRefreshNotifier,
    this._missionRefreshNotifier,
  );

  Future<void> initialize(int userId) async {
    await _localNotificationService.initialize();
    await _localNotificationService.requestPermissions();

    // Listen to notification stream
    _subscription = _websocketService.notificationStream.listen((notification) {
      // Add to state (legacy support)
      _notificationsNotifier.addNotification(notification);

      // Show local notification
      _localNotificationService.showAchievementNotification(notification);

      // Trigger notification refresh (NEW: API-based notifications)
      print(
        '🔔 [WebSocketManager] Notification received via WebSocket, triggering API refresh...',
      );
      _notificationRefreshNotifier.refreshNotifications();

      // Trigger specific refreshes based on notification type
      switch (notification.type.toUpperCase()) {
        case 'ACHIEVEMENT':
          print(
            '🏆 [WebSocketManager] ACHIEVEMENT notification → Refreshing achievements',
          );
          _achievementRefreshNotifier.refreshOnAchievementUnlocked();
          break;

        case 'MISSION':
          print(
            '✅ [WebSocketManager] MISSION notification → Refreshing missions & achievements',
          );
          _achievementRefreshNotifier.refreshOnAchievementUnlocked();
          _missionRefreshNotifier.refreshTodayMissions();
          _achievementRefreshNotifier.refreshOnProgressUpdate();
          break;

        case 'PHASE':
          print(
            '📅 [WebSocketManager] PHASE notification → Refreshing quit plan & missions',
          );
          _achievementRefreshNotifier.refreshOnAchievementUnlocked();
          _missionRefreshNotifier.refreshQuitPlan();
          break;

        case 'QUIT_PLAN':
          print(
            '🗓️ [WebSocketManager] QUIT_PLAN notification → Refreshing quit plan',
          );
          _achievementRefreshNotifier.refreshOnAchievementUnlocked();
          _missionRefreshNotifier.refreshQuitPlan();
          break;

        case 'SYSTEM':
          print(
            '🔔 [WebSocketManager] SYSTEM notification → No specific refresh needed',
          );
          _achievementRefreshNotifier.refreshOnAchievementUnlocked();
          break;

        default:
          print(
            '⚠️ [WebSocketManager] Unknown notification type: ${notification.type}',
          );
      }
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

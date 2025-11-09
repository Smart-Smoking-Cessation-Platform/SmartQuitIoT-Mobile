import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:SmartQuitIoT/services/notification_service.dart';
import 'package:SmartQuitIoT/repositories/notification_repository.dart';
import 'package:SmartQuitIoT/models/achievement_notification.dart';
import 'package:SmartQuitIoT/providers/user_provider.dart';
import 'package:SmartQuitIoT/providers/auth_provider.dart';

// Notification Service Provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationService(dio: dio);
});

// Notification Repository Provider
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final service = ref.watch(notificationServiceProvider);
  return NotificationRepository(service);
});

// Notification State
class NotificationState {
  final List<AchievementNotification> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState({
    this.notifications = const [],
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<AchievementNotification>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

// Notification ViewModel
class NotificationViewModel extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final Ref _ref;

  NotificationViewModel(this._repository, this._ref) : super(NotificationState());

  /// Get all notifications from all types
  Future<void> getAllNotifications({bool? isRead, int page = 0, int size = 10}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      print('🔔 [NotificationViewModel] Loading all notifications...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final notifications = await _repository.getAllNotificationsAllTypes(
        accessToken: token,
        isRead: isRead,
        page: page,
        size: size,
      );

      // Calculate unread count
      final unreadCount = notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        unreadCount: unreadCount,
      );

      print('✅ [NotificationViewModel] Loaded ${notifications.length} notifications');
      print('📊 [NotificationViewModel] Unread count: $unreadCount');
    } catch (e) {
      print('❌ [NotificationViewModel] Error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get unread count only
  Future<void> getUnreadCount() async {
    try {
      print('🔔 [NotificationViewModel] Getting unread count...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final count = await _repository.getUnreadCount(accessToken: token);

      state = state.copyWith(unreadCount: count);
      print('📊 [NotificationViewModel] Unread count: $count');
    } catch (e) {
      print('❌ [NotificationViewModel] Error getting unread count: $e');
      // Don't update state with error, just log it
    }
  }

  /// Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      print('🔔 [NotificationViewModel] Marking all as read...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.markAllAsRead(accessToken: token);

      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          return n.copyWith(isRead: true);
        }).toList();

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );

        print('✅ [NotificationViewModel] All marked as read');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error marking all as read: $e');
      return false;
    }
  }

  /// Mark single notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      print('🔔 [NotificationViewModel] Marking notification $notificationId as read...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.markAsRead(
        accessToken: token,
        notificationId: notificationId,
      );

      if (success) {
        // Update local state
        final updatedNotifications = state.notifications.map((n) {
          if (n.id == notificationId) {
            return n.copyWith(isRead: true);
          }
          return n;
        }).toList();

        // Recalculate unread count
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );

        print('✅ [NotificationViewModel] Notification $notificationId marked as read');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error marking notification as read: $e');
      return false;
    }
  }

  /// Delete notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      print('🔔 [NotificationViewModel] Deleting notification $notificationId...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.deleteNotification(
        accessToken: token,
        notificationId: notificationId,
      );

      if (success) {
        // Remove from local state
        final updatedNotifications = state.notifications
            .where((n) => n.id != notificationId)
            .toList();

        // Recalculate unread count
        final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );

        print('✅ [NotificationViewModel] Notification $notificationId deleted');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications
  Future<bool> deleteAllNotifications() async {
    try {
      print('🔔 [NotificationViewModel] Deleting all notifications...');

      final token = await _ref.read(authRepositoryProvider).getAccessToken();
      if (token == null) {
        throw Exception('No access token found');
      }

      final success = await _repository.deleteAllNotifications(accessToken: token);

      if (success) {
        state = state.copyWith(
          notifications: [],
          unreadCount: 0,
        );

        print('✅ [NotificationViewModel] All notifications deleted');
      }

      return success;
    } catch (e) {
      print('❌ [NotificationViewModel] Error deleting all notifications: $e');
      return false;
    }
  }

  /// Refresh notifications
  Future<void> refresh() async {
    print('🔄 [NotificationViewModel] Refreshing notifications...');
    await getAllNotifications();
  }
}

// Notification ViewModel Provider
final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationViewModel(repository, ref);
});

// Convenience providers for specific use cases

/// All notifications provider
final allNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  return ref.watch(notificationViewModelProvider).notifications;
});

/// Unread notifications provider
final unreadNotificationsProvider = Provider<List<AchievementNotification>>((ref) {
  final notifications = ref.watch(notificationViewModelProvider).notifications;
  return notifications.where((n) => !n.isRead).toList();
});

/// Unread count provider
final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationViewModelProvider).unreadCount;
});

/// Loading state provider
final notificationLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notificationViewModelProvider).isLoading;
});

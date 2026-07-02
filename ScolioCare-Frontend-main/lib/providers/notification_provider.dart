import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/models/notification/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final String? Function() _getUserId;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  NotificationProvider(this._notificationService,
      {String? Function()? getUserId})
      : _getUserId = getUserId ?? (() => 'mock-user-123');

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    final userId = _getUserId();
    if (userId == null) {
      _error = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _notifications = await _notificationService.getNotifications(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      _unreadCount = await _notificationService.getUnreadCount(userId);
      notifyListeners();
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      await _notificationService.markAsRead(userId, [notificationId]);

      // Update local state
      final index = _notifications.indexWhere(
        (n) => n.notificationId == notificationId,
      );
      if (index != -1 && !_notifications[index].isRead) {
        _notifications[index] = AppNotification(
          notificationId: _notifications[index].notificationId,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          channel: _notifications[index].channel,
          priority: _notifications[index].priority,
          status: _notifications[index].status,
          scheduledFor: _notifications[index].scheduledFor,
          sentAt: _notifications[index].sentAt ?? DateTime.now(),
          isRead: true,
          metadata: _notifications[index].metadata,
        );
        _unreadCount = (_unreadCount - 1).clamp(0, 9999);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      // Get all unread notification IDs
      final unreadIds = _notifications
          .where((n) => !n.isRead)
          .map((n) => n.notificationId)
          .toList();

      if (unreadIds.isEmpty) return;

      await _notificationService.markAsRead(userId, unreadIds);

      // Update local state
      _notifications = _notifications.map((n) {
        return AppNotification(
          notificationId: n.notificationId,
          userId: n.userId,
          type: n.type,
          title: n.title,
          message: n.message,
          channel: n.channel,
          priority: n.priority,
          status: n.status,
          scheduledFor: n.scheduledFor,
          sentAt: n.sentAt ?? DateTime.now(),
          isRead: true,
          metadata: n.metadata,
        );
      }).toList();

      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to mark all as read: $e';
      notifyListeners();
    }
  }

  Future<void> cancelNotification(String notificationId) async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      await _notificationService.cancelNotifications(userId, [notificationId]);

      // Remove from local state
      final wasUnread = _notifications
              .firstWhere((n) => n.notificationId == notificationId)
              .isRead ==
          false;

      _notifications.removeWhere((n) => n.notificationId == notificationId);

      if (wasUnread) {
        _unreadCount = (_unreadCount - 1).clamp(0, 9999);
      }

      notifyListeners();
    } catch (e) {
      _error = 'Failed to cancel notification: $e';
      notifyListeners();
    }
  }

  Future<void> registerDeviceToken(String deviceToken, String platform) async {
    final userId = _getUserId();
    if (userId == null) return;

    try {
      await _notificationService.registerDeviceToken(
        userId: userId,
        deviceToken: deviceToken,
        platform: platform,
      );
    } catch (e) {
      // Silently fail for device token registration
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

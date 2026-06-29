import 'package:flutter/material.dart';
import '../core/services/notification_service.dart';
import '../core/models/notification/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;

  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  NotificationProvider(this._notificationService);

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _notifications = await _notificationService.getNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _notificationService.getUnreadCount();
      notifyListeners();
    } catch (e) {
      // Silently fail for unread count
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

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
    try {
      // Mark all unread notifications
      for (final notification in _notifications.where((n) => !n.isRead)) {
        await _notificationService.markAsRead(notification.notificationId);
      }

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
    try {
      await _notificationService.cancelNotification(notificationId);

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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

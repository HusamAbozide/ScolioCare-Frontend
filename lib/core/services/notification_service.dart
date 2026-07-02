import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/notification/notification.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<List<AppNotification>> getNotifications(
    String userId, {
    int page = 0,
    int size = 20,
    String? type,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockNotifications();
    }

    final response = await _apiClient.get(
      ApiConfig.notificationsByUserId(userId),
      queryParameters: {
        'page': page,
        'size': size,
        if (type != null) 'type': type,
      },
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> markAsRead(String userId, List<String> notificationIds) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '${ApiConfig.notificationRead}?userId=$userId',
      data: {'notificationIds': notificationIds},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to mark as read');
    }
  }

  Future<int> getUnreadCount(String userId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return 3; // Mock unread count
    }

    final response = await _apiClient.get(
      '${ApiConfig.notificationUnreadCount}?userId=$userId',
    );

    if (response.success && response.data != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return (data['count'] ?? data['unreadCount'] ?? 0) as int;
      }
      return data as int;
    }

    return 0;
  }

  Future<void> cancelNotifications(
      String userId, List<String> notificationIds) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '${ApiConfig.notificationCancel}?userId=$userId',
      data: {'notificationIds': notificationIds},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to cancel notifications');
    }
  }

  Future<void> registerDeviceToken({
    required String userId,
    required String deviceToken,
    required String platform,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '${ApiConfig.notificationDeviceToken}?userId=$userId',
      data: {
        'deviceToken': deviceToken,
        'platform': platform,
      },
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to register device token');
    }
  }

  // Mock data generator
  List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        notificationId: 'notif-1',
        userId: 'mock-user-123',
        type: 'REPORT_READY',
        title: 'Your Analysis Report is Ready',
        message:
            'Your latest spine analysis report has been generated and is ready to view.',
        channel: 'PUSH',
        priority: 'HIGH',
        status: 'SENT',
        sentAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
        metadata: {'analysisId': 'mock-analysis-1'},
      ),
      AppNotification(
        notificationId: 'notif-2',
        userId: 'mock-user-123',
        type: 'EXERCISE_REMINDER',
        title: 'Time for Today\'s Exercises',
        message: 'Don\'t forget to complete your daily exercise routine!',
        channel: 'PUSH',
        priority: 'NORMAL',
        status: 'SENT',
        sentAt: now.subtract(const Duration(days: 1)),
        isRead: false,
      ),
      AppNotification(
        notificationId: 'notif-3',
        userId: 'mock-user-123',
        type: 'STREAK',
        title: '🔥 7-Day Streak Achievement!',
        message:
            'Congratulations! You\'ve maintained your exercise streak for 7 days.',
        channel: 'PUSH',
        priority: 'NORMAL',
        status: 'SENT',
        sentAt: now.subtract(const Duration(days: 2)),
        isRead: true,
      ),
      AppNotification(
        notificationId: 'notif-4',
        userId: 'mock-user-123',
        type: 'SCAN_REMINDER',
        title: 'Monthly Scan Due',
        message:
            'It\'s time for your monthly posture scan. Take a few minutes to track your progress.',
        channel: 'PUSH',
        priority: 'NORMAL',
        status: 'SENT',
        sentAt: now.subtract(const Duration(days: 5)),
        isRead: true,
      ),
    ];
  }
}

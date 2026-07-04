import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import '../../widgets/firebase_options.dart';
import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/notification/notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Handling a background message: ${message.messageId}');
}

class NotificationService {
  final ApiClient _apiClient;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
  );
  bool _initialized = false;

  NotificationService(this._apiClient);

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> initialize({String? userId}) async {
    if (_initialized) {
      if (userId != null) {
        await syncDeviceToken(userId);
      }
      return;
    }

    // 1. Request notification permissions
    debugPrint('Requesting notification permission...');
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint(
        'Notifications are denied. Enable them from Android app settings to receive push notifications.',
      );
    }

    // 2. Initialize Local Notifications Plugin
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification clicked: ${response.payload}');
      },
    );

    // 3. Create the channel on Android
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 4. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      if (message.notification != null) {
        _showForegroundNotification(message);
      }
    });

    FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
      if (userId != null) {
        await registerDeviceToken(
          userId: userId,
          deviceToken: token,
          platform: defaultTargetPlatform == TargetPlatform.iOS
              ? 'ios'
              : 'android',
        );
      }
    });

    _initialized = true;
    if (userId != null) {
      await syncDeviceToken(userId);
    }
  }

  Future<void> syncDeviceToken(String userId) async {
    try {
      final token = await _messaging.getToken();
      debugPrint('FCM Token: $token');
      if (token != null) {
        await registerDeviceToken(
          userId: userId,
          deviceToken: token,
          platform:
              defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        );
        debugPrint('FCM token registered with backend for userId=$userId');
      } else {
        debugPrint('Firebase returned a null FCM token.');
      }
    } catch (e) {
      debugPrint('Error getting or registering FCM token: $e');
    }
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }


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
    debugPrint('Backend accepted FCM device token.');
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

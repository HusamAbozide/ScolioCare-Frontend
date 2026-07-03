class AppNotification {
  final String notificationId;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String channel;
  final String priority;
  final String status;
  final DateTime? scheduledFor;
  final DateTime? sentAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  AppNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    required this.channel,
    required this.priority,
    required this.status,
    this.scheduledFor,
    this.sentAt,
    required this.isRead,
    this.metadata,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final type = json['type'] ?? json['category'];
    final message = json['message'] ?? json['body'];
    final sentAt = json['sentAt'] ?? json['createdAt'];
    final readAt = json['readAt'];
    return AppNotification(
      notificationId: json['notificationId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: type?.toString() ?? 'GENERAL',
      title: json['title'] as String? ?? 'Notification',
      message: message?.toString() ?? '',
      channel: json['channel']?.toString() ?? 'PUSH',
      priority: json['priority']?.toString() ?? 'NORMAL',
      status: json['status']?.toString() ?? 'SENT',
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      sentAt: sentAt != null
          ? DateTime.tryParse(sentAt.toString())
          : null,
      isRead: json['isRead'] as bool? ?? readAt != null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'notificationId': notificationId,
        'userId': userId,
        'type': type,
        'title': title,
        'message': message,
        'channel': channel,
        'priority': priority,
        'status': status,
        'scheduledFor': scheduledFor?.toIso8601String(),
        'sentAt': sentAt?.toIso8601String(),
        'isRead': isRead,
        'metadata': metadata,
      };
}

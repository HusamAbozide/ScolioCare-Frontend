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
    return AppNotification(
      notificationId: json['notificationId'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      channel: json['channel'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      scheduledFor: json['scheduledFor'] != null
          ? DateTime.parse(json['scheduledFor'] as String)
          : null,
      sentAt: json['sentAt'] != null
          ? DateTime.parse(json['sentAt'] as String)
          : null,
      isRead: json['isRead'] as bool? ?? false,
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

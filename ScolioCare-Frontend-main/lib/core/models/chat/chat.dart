class ChatSession {
  final String sessionId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  ChatSession({
    required this.sessionId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'] as String,
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'userId': userId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'isActive': isActive,
      };
}

class ChatMessage {
  final String messageId;
  final String sessionId;
  final String role; // USER or ASSISTANT
  final String content;
  final DateTime createdAt;
  final int? tokensUsed;
  final Map<String, dynamic>? metadata;

  ChatMessage({
    required this.messageId,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.tokensUsed,
    this.metadata,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      messageId: json['messageId'] as String,
      sessionId: json['sessionId'] as String,
      role: json['role'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      tokensUsed: json['tokensUsed'] as int?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'sessionId': sessionId,
        'role': role,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'tokensUsed': tokensUsed,
        'metadata': metadata,
      };
}

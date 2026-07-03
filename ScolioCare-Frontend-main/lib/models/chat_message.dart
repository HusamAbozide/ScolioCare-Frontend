enum MessageRole { bot, user }

class ChatMessage {
  final MessageRole role;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

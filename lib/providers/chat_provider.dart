import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      role: MessageRole.bot,
      message:
          "Hello! I'm your ScolioCare assistant. How can I help you today?",
    ),
  ];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  static const List<String> suggestedQuestions = [
    "What causes scoliosis?",
    "How often should I exercise?",
    "Can scoliosis be cured?",
    "What is a Cobb angle?",
  ];

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(role: MessageRole.user, message: text));
    notifyListeners();

    // Simulate bot response — replace with real API call later
    Future.delayed(const Duration(seconds: 1), () {
      String response;
      final lower = text.toLowerCase();
      if (lower.contains('exercise') && lower.contains('thoracic')) {
        response = "For thoracic scoliosis, I recommend focusing on:\n\n"
            "• Cat-Cow stretches for spinal mobility\n"
            "• Side planks to strengthen core muscles\n"
            "• Thoracic extension exercises\n"
            "• Breathing exercises to improve rib cage flexibility\n\n"
            "Would you like me to show you how to perform any of these?";
      } else if (lower.contains('cause')) {
        response = "Scoliosis can be caused by several factors:\n\n"
            "• Idiopathic (most common, ~80% of cases)\n"
            "• Congenital (present at birth)\n"
            "• Neuromuscular (nerve or muscle conditions)\n"
            "• Degenerative (age-related)\n\n"
            "Would you like to learn more about any specific type?";
      } else {
        response =
            "Thank you for your question! I'm processing your request and "
            "will provide helpful information shortly.";
      }

      _messages.add(ChatMessage(role: MessageRole.bot, message: response));
      notifyListeners();
    });
  }
}

import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../core/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService;

  String? _currentSessionId;
  bool _isLoading = false;
  String? _error;

  final List<ChatMessage> _messages = [
    ChatMessage(
      role: MessageRole.bot,
      message:
          "Hello! I'm your ScolioCare assistant. How can I help you today?",
    ),
  ];

  ChatProvider(this._chatService);

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  static const List<String> suggestedQuestions = [
    "What causes scoliosis?",
    "How often should I exercise?",
    "Can scoliosis be cured?",
    "What is a Cobb angle?",
  ];

  Future<void> startSession() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final session = await _chatService.startSession();
      _currentSessionId = session.sessionId;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message immediately
    _messages.add(ChatMessage(role: MessageRole.user, message: text));
    notifyListeners();

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Start session if not already started
      if (_currentSessionId == null) {
        await startSession();
      }

      // Send message to backend
      final backendMessage = await _chatService.sendMessage(
        _currentSessionId!,
        text,
      );

      // Add bot response
      _messages.add(ChatMessage(
        role: MessageRole.bot,
        message: backendMessage.content,
      ));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: $e';
      _isLoading = false;

      // Add error message as bot response
      _messages.add(ChatMessage(
        role: MessageRole.bot,
        message: _chatErrorMessage(e),
      ));
      notifyListeners();
    }
  }

  Future<void> endSession() async {
    if (_currentSessionId == null) return;

    try {
      await _chatService.endSession(_currentSessionId!);
      _currentSessionId = null;
    } catch (e) {
      // Silently fail - session will expire on backend
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _chatErrorMessage(Object error) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    if (message.isEmpty) {
      return "I'm sorry, I encountered an error processing your message. Please try again.";
    }
    return message;
  }

  @override
  void dispose() {
    endSession(); // End session when provider is disposed
    super.dispose();
  }
}

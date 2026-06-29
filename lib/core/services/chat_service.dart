import '../api/api_client.dart';
import '../api/api_config.dart';
import '../models/chat/chat.dart';

class ChatService {
  final ApiClient _apiClient;

  ChatService(this._apiClient);

  Future<ChatSession> startSession() async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final now = DateTime.now();
      return ChatSession(
        sessionId: 'mock-session-${now.millisecondsSinceEpoch}',
        userId: 'mock-user-123',
        createdAt: now,
        updatedAt: now,
        isActive: true,
      );
    }

    final response = await _apiClient.post<ChatSession>(
      '/chat/session/start',
      data: {},
      fromJsonT: (json) => ChatSession.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to start session');
  }

  Future<ChatMessage> sendMessage(String sessionId, String text) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate AI processing

      // Generate contextual mock response
      String mockResponse = _generateMockResponse(text);

      return ChatMessage(
        messageId: 'mock-msg-${DateTime.now().millisecondsSinceEpoch}',
        sessionId: sessionId,
        role: 'ASSISTANT',
        content: mockResponse,
        createdAt: DateTime.now(),
        tokensUsed: 150,
      );
    }

    final response = await _apiClient.post<ChatMessage>(
      '/chat/session/$sessionId/message',
      data: {'text': text},
      fromJsonT: (json) => ChatMessage.fromJson(json as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Failed to send message');
  }

  Future<List<ChatMessage>> getMessages(
    String sessionId, {
    int page = 0,
    int size = 50,
  }) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      return []; // Return empty for now, messages will be built up from sendMessage
    }

    final response = await _apiClient.get(
      '/chat/session/$sessionId/messages',
      queryParameters: {'page': page, 'size': size},
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      return list
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  Future<void> endSession(String sessionId) async {
    // Mock mode
    if (ApiConfig.useMockMode) {
      await Future.delayed(const Duration(milliseconds: 200));
      return;
    }

    final response = await _apiClient.post(
      '/chat/session/$sessionId/end',
      data: {},
    );

    if (!response.success) {
      throw Exception(response.message ?? 'Failed to end session');
    }
  }

  // Mock AI response generator
  String _generateMockResponse(String userMessage) {
    final lower = userMessage.toLowerCase();

    if (lower.contains('result') || lower.contains('analysis')) {
      return 'Your latest analysis shows a mild thoracic curve with a confidence score of 89%. This indicates a slight curvature in your upper spine. The AI model has detected this pattern based on the image you provided. It\'s important to continue with your prescribed exercises and monitor your progress regularly.';
    }

    if (lower.contains('exercise') || lower.contains('workout')) {
      return 'Your current exercise plan focuses on strengthening your core muscles and improving spinal flexibility. The exercises are designed specifically for your condition. Make sure to maintain proper form during each exercise, and don\'t hesitate to adjust the difficulty if needed. Consistency is key - try to complete your daily routine!';
    }

    if (lower.contains('pain')) {
      return 'I see you\'re experiencing some discomfort. It\'s normal to feel mild muscle soreness when starting a new exercise routine. However, if you experience sharp or persistent pain, it\'s important to consult with your healthcare provider. In the meantime, you can try gentle stretching and ensure you\'re not overexerting yourself during exercises.';
    }

    if (lower.contains('improve') || lower.contains('progress')) {
      return 'Based on your recent data, you\'re making good progress! Your exercise adherence is at 78.5%, and you\'ve maintained a 7-day streak. Your scoliometer readings show a slight improvement over the past month. Keep up the great work! Consistency with your exercises will continue to yield positive results.';
    }

    if (lower.contains('scoliosis') || lower.contains('what is')) {
      return 'Scoliosis is a condition where the spine curves sideways, forming an "S" or "C" shape. It can develop during growth spurts before puberty. While some cases are mild and require only monitoring, others may need bracing or surgery. Regular exercise and posture awareness can help manage symptoms and improve quality of life.';
    }

    if (lower.contains('help') || lower.contains('how')) {
      return 'I\'m here to help you understand your results, guide you through exercises, and provide motivation! You can ask me about:\n• Your AI analysis results\n• Exercise instructions\n• Progress tracking\n• General scoliosis information\n• Tips for better posture\n\nFeel free to ask me anything!';
    }

    // Default response
    return 'Thank you for your message! I\'m ScolioCare\'s AI assistant, here to help you with your spine health journey. I can explain your analysis results, provide exercise guidance, and answer questions about scoliosis management. What would you like to know more about?';
  }
}

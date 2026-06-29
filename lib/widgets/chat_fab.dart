import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Floating Action Button for quick access to chatbot
class ChatFab extends StatelessWidget {
  const ChatFab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () {
        Navigator.pushNamed(context, '/chatbot');
      },
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
      child: const Icon(
        Icons.chat_bubble,
        color: Colors.white,
      ),
    );
  }
}

/// Extended version with label
class ChatFabExtended extends StatelessWidget {
  const ChatFabExtended({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.pushNamed(context, '/chatbot');
      },
      backgroundColor: theme.colorScheme.primary,
      elevation: 4,
      icon: const Icon(Icons.chat_bubble, color: Colors.white),
      label: const Text(
        'Chat',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

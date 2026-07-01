import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Floating Action Button for quick access to chatbot with subtle pulse animation
class ChatFab extends StatefulWidget {
  const ChatFab({super.key});

  @override
  State<ChatFab> createState() => _ChatFabState();
}

class _ChatFabState extends State<ChatFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary
                    .withOpacity(0.3 * _pulseAnimation.value),
                blurRadius: 16 * _pulseAnimation.value,
                spreadRadius: 4 * (_pulseAnimation.value - 1),
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/chatbot');
            },
            backgroundColor: theme.colorScheme.primary,
            elevation: 6,
            highlightElevation: 8,
            heroTag: 'chatbot',
            child: const FaIcon(
              FontAwesomeIcons.robot,
              color: Colors.white,
              size: 22,
            ),
          ),
        );
      },
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
      elevation: 6,
      highlightElevation: 8,
      icon: const FaIcon(
        FontAwesomeIcons.commentDots,
        color: Colors.white,
        size: 20,
      ),
      label: const Text(
        'Chat',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart'
    as chat_feature;
import 'package:provider/provider.dart';
import 'package:frontend/features/chat/presentation/controllers/chat_provider.dart';

/// Legacy chat screen that wraps the new feature-based chat
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatProvider(),
      child: const chat_feature.ChatScreen(),
    );
  }
}

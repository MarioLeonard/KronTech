import 'package:flutter/material.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart'
    as chat_feature;
import 'package:frontend/providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';
import 'package:frontend/features/chat/presentation/controllers/chat_provider.dart';

/// Legacy chat screen that wraps the new feature-based chat
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<app_auth.AuthProvider>().user;
    if (authUser == null) {
      return const Center(child: Text('Sign in to use chat'));
    }

    return ChangeNotifierProvider(
      create: (_) =>
          ChatProvider(currentUserId: authUser.id, idToken: authUser.idToken),
      child: const chat_feature.ChatScreen(),
    );
  }
}

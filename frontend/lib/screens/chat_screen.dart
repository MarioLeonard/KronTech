import 'package:flutter/material.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/chat/presentation/screens/chat_screen.dart'
    as chat_feature;
import 'package:frontend/providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';
import 'package:frontend/features/chat/presentation/controllers/chat_provider.dart';

/// Legacy chat screen that wraps the new feature-based chat
class ChatScreen extends StatelessWidget {
  const ChatScreen({this.initialConversationId, super.key});

  final String? initialConversationId;

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<app_auth.AuthProvider>().user;
    if (authUser == null) {
      return PremiumBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Text(
              'Sign in to use chat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return ChangeNotifierProvider(
      key: ValueKey(initialConversationId),
      create: (_) => ChatProvider(
        currentUserId: authUser.id,
        idToken: authUser.idToken,
        initialConversationId: initialConversationId,
      ),
      child: const chat_feature.ChatScreen(),
    );
  }
}

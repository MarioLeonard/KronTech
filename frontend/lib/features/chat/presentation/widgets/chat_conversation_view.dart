import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../../domain/chat_conversation.dart';
import 'chat_message_bubble.dart';

part 'chat_conversation_view_state.dart';

class ChatConversationView extends StatefulWidget {
  final ChatConversation? conversation;
  final VoidCallback? onParticipantTap;
  final VoidCallback? onBack;

  const ChatConversationView({
    required this.conversation,
    this.onParticipantTap,
    this.onBack,
    super.key,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

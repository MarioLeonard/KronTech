import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../../domain/chat_conversation.dart';
import 'chat_message_bubble.dart';

/// Main chat view showing messages and input field
class ChatConversationView extends StatefulWidget {
  final ChatConversation? conversation;
  final VoidCallback? onParticipantTap;

  const ChatConversationView({
    required this.conversation,
    this.onParticipantTap,
    super.key,
  });

  @override
  State<ChatConversationView> createState() => _ChatConversationViewState();
}

class _ChatConversationViewState extends State<ChatConversationView> {
  late ScrollController _scrollController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void didUpdateWidget(ChatConversationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation?.id != widget.conversation?.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    context.read<ChatProvider>().sendMessage(_messageController.text);
    _messageController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.conversation == null) {
      return Center(
        child: Text(
          'Select a conversation to start chatting',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return Column(
      children: [
        /// Chat header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: widget.onParticipantTap,
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.secondary,
                  child: Icon(
                    Icons.person_rounded,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: widget.onParticipantTap,
                      child: Text(
                        widget.conversation!.participant.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.conversation!.participant.isOnline
                          ? 'Online'
                          : 'Offline',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: widget.conversation!.participant.isOnline
                            ? Colors.green
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.call_rounded),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.videocam_rounded),
                onPressed: () {},
              ),
            ],
          ),
        ),

        /// Messages list
        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              final messages = widget.conversation!.messages;

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatMessageBubble(
                    message: messages[index],
                    onAvatarTap: !messages[index].isCurrentUser
                        ? widget.onParticipantTap
                        : null,
                  );
                },
              );
            },
          ),
        ),

        /// Input field
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    prefixIcon: Icon(
                      Icons.add_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  minLines: 1,
                  maxLines: 3,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              FloatingActionButton(
                mini: true,
                onPressed: _sendMessage,
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

part of 'chat_conversation_view.dart';

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
    final chatProvider = context.watch<ChatProvider>();
    final currentUserAvatarUrl = context
        .watch<AuthProvider>()
        .user
        ?.effectivePhotoUrl;
    final conversation =
        chatProvider.selectedConversation?.id == widget.conversation?.id
        ? chatProvider.selectedConversation
        : widget.conversation;

    if (conversation == null) {
      return Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Select a conversation to start chatting',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (widget.onBack != null) ...[
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                ],
                AppAvatar(
                  imageUrl: conversation.participant.avatarUrl,
                  radius: 24,
                  onTap: widget.onParticipantTap,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversation.participant.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        conversation.participant.presenceLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: conversation.participant.isOnline
                              ? Colors.green
                              : Colors.white.withValues(alpha: 0.5),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              final activeConversation =
                  chatProvider.selectedConversation?.id == conversation.id
                  ? chatProvider.selectedConversation!
                  : conversation;
              final messages = activeConversation.messages;

              if (chatProvider.isLoadingMessages) {
                return const Center(child: CircularProgressIndicator());
              }

              final error = chatProvider.errorMessage;
              if (error != null && messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      error,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                );
              }

              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    'No messages yet. Start the conversation!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });
                  return ChatMessageBubble(
                    message: messages[index],
                    senderAvatarUrl: messages[index].isCurrentUser
                        ? currentUserAvatarUrl
                        : activeConversation.participant.avatarUrl,
                    onAvatarTap: !messages[index].isCurrentUser
                        ? widget.onParticipantTap
                        : null,
                  );
                },
              );
            },
          ),
        ),

        DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !chatProvider.isSending,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.42),
                        fontWeight: FontWeight.w600,
                      ),
                      prefixIcon: Icon(
                        Icons.add_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.72,
                          ),
                          width: 1.4,
                        ),
                      ),
                    ),
                    minLines: 1,
                    maxLines: 3,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  onPressed: chatProvider.isSending ? null : _sendMessage,
                  child: chatProvider.isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

part of 'chat_screen.dart';

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
    });
  }

  Future<void> _showParticipantProfile(ChatUser participant) {
    return showUserProfileSheet(
      context,
      name: participant.name,
      avatarUrl: participant.avatarUrl,
      status: participant.presenceLabel,
      userId: participant.id,
    );
  }

  void _showConversationDetail(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final conversation = chatProvider.selectedConversation;

    if (conversation == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PremiumBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: GlassContainer(
                  color: Colors.white,
                  opacity: 0.055,
                  blur: 18,
                  borderRadius: 26,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: ChatConversationView(
                      conversation: conversation,
                      onBack: () => Navigator.pop(context),
                      onParticipantTap: () {
                        Navigator.pop(context);
                        _showParticipantProfile(conversation.participant);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 900;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (isLargeScreen) {
          return PremiumBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _MessagesHeader(
                            unreadCount: chatProvider.totalUnreadCount,
                          ),
                          const SizedBox(height: 24),
                          Expanded(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 336,
                                  child: GlassContainer(
                                    color: const Color(0xFF0E5A90),
                                    opacity: 0.16,
                                    blur: 18,
                                    borderRadius: 26,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                    child: ChatSidebar(
                                      selectedConversationId:
                                          chatProvider.selectedConversation?.id,
                                      onConversationSelected: (conversationId) {
                                        chatProvider.selectConversation(
                                          conversationId,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: GlassContainer(
                                    color: Colors.white,
                                    opacity: 0.055,
                                    blur: 18,
                                    borderRadius: 26,
                                    border: Border.all(
                                      color: Colors.white.withValues(
                                        alpha: 0.14,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(26),
                                      child: ChatConversationView(
                                        conversation:
                                            chatProvider.selectedConversation,
                                        onParticipantTap: () {
                                          if (chatProvider
                                                  .selectedConversation !=
                                              null) {
                                            _showParticipantProfile(
                                              chatProvider
                                                  .selectedConversation!
                                                  .participant,
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return PremiumBackground(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _MessagesHeader(
                        unreadCount: chatProvider.totalUnreadCount,
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GlassContainer(
                          color: const Color(0xFF0E5A90),
                          opacity: 0.16,
                          blur: 18,
                          borderRadius: 26,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                          child: ChatSidebar(
                            selectedConversationId:
                                chatProvider.selectedConversation?.id,
                            onConversationSelected: (conversationId) {
                              chatProvider.selectConversation(conversationId);
                              _showConversationDetail(context);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

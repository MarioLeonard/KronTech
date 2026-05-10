import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../../domain/chat_conversation.dart';

/// Sidebar widget showing list of conversations
class ChatSidebar extends StatelessWidget {
  final Function(String) onConversationSelected;
  final String? selectedConversationId;

  const ChatSidebar({
    required this.onConversationSelected,
    this.selectedConversationId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        return Column(
          children: [
            /// Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(
                    'Messages',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (chatProvider.totalUnreadCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${chatProvider.totalUnreadCount}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            /// Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (value) => chatProvider.updateSearchQuery(value),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon: chatProvider.filteredConversations.isNotEmpty
                      ? GestureDetector(
                          onTap: () => chatProvider.clearSearch(),
                          child: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.primary,
                          ),
                        )
                      : null,
                  hintText: 'Search conversations',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Conversations list
            Expanded(
              child: chatProvider.isLoadingConversations
                  ? const Center(child: CircularProgressIndicator())
                  : chatProvider.errorMessage != null &&
                        chatProvider.filteredConversations.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          chatProvider.errorMessage!,
                          style: theme.textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : chatProvider.filteredConversations.isEmpty
                  ? Center(
                      child: Text(
                        'No conversations',
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      itemCount: chatProvider.filteredConversations.length,
                      itemBuilder: (context, index) {
                        final conversation =
                            chatProvider.filteredConversations[index];
                        return _ConversationTile(
                          conversation: conversation,
                          isSelected: selectedConversationId == conversation.id,
                          onTap: () => onConversationSelected(conversation.id),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Individual conversation tile in the sidebar
class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              /// Avatar
              Stack(
                children: [
                  AppAvatar(
                    imageUrl: conversation.participant.avatarUrl,
                    radius: 24,
                  ),

                  /// Online indicator
                  if (conversation.participant.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              /// Message content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.participant.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conversation.lastMessage?.formattedTime ?? '',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.messagePreview,
                            style: theme.textTheme.bodySmall,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/user_profile_sheet.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../../domain/chat_conversation.dart';

part 'conversation_tile.dart';

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
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
              child: Row(
                children: [
                  Text(
                    'Conversations',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: TextField(
                onChanged: (value) => chatProvider.updateSearchQuery(value),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.58),
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
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontWeight: FontWeight.w600,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.72),
                      width: 1.4,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

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
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : chatProvider.filteredConversations.isEmpty
                  ? Center(
                      child: Text(
                        'No conversations',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 16),
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

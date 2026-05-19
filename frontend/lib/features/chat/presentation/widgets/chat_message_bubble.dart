import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import '../../domain/chat_message.dart';

/// Reusable widget for displaying a single chat message
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final String? senderAvatarUrl;
  final VoidCallback? onAvatarTap;

  const ChatMessageBubble({
    required this.message,
    this.senderAvatarUrl,
    this.onAvatarTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCurrentUser = message.isCurrentUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            AppAvatar(
              imageUrl: senderAvatarUrl,
              radius: 18,
              onTap: onAvatarTap,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? colorScheme.primary
                        : Colors.white.withValues(alpha: 0.08),
                    border: Border.all(
                      color: isCurrentUser
                          ? colorScheme.primary.withValues(alpha: 0.34)
                          : Colors.white.withValues(alpha: 0.1),
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isCurrentUser ? 18 : 5),
                      bottomRight: Radius.circular(isCurrentUser ? 5 : 18),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    message.content,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(
                        alpha: isCurrentUser ? 1 : 0.88,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.formattedTime,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.44),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            AppAvatar(imageUrl: senderAvatarUrl, radius: 18),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chat', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: theme.colorScheme.secondary,
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Conversations',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start a new chat or continue a conversation.',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      labelText: 'Search chats',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ChatPreviewTile(
                    title: 'Support',
                    message: 'How can we help with your trip?',
                    time: 'Now',
                    color: theme.colorScheme.tertiary,
                  ),
                  const Divider(height: 1),
                  _ChatPreviewTile(
                    title: 'Travel assistant',
                    message: 'Your saved routes are ready.',
                    time: '09:24',
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatPreviewTile extends StatelessWidget {
  const _ChatPreviewTile({
    required this.title,
    required this.message,
    required this.time,
    required this.color,
  });

  final String title;
  final String message;
  final String time;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: color,
        child: const Icon(Icons.person_outline_rounded, color: Colors.white),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(message),
      trailing: Text(time, style: theme.textTheme.bodySmall),
    );
  }
}

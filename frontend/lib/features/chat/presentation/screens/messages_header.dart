part of 'chat_screen.dart';

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader({required this.unreadCount});

  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MESSAGES',
                style: theme.textTheme.labelLarge?.copyWith(
                  letterSpacing: 4,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Keep every trip conversation close.',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Text(
                  'Chat with friends, coordinate plans, and pick up every conversation right where it left off.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.68),
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 4,
                width: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        if (unreadCount > 0)
          DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.tertiary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              child: Text(
                '$unreadCount unread',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

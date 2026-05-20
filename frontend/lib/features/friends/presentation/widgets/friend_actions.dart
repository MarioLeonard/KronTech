part of '../screens/friends_screen.dart';

class _FriendActions extends StatelessWidget {
  const _FriendActions({required this.friend, this.onOpenChat});

  final FriendUser friend;
  final VoidCallback? onOpenChat;

  Future<void> _removeFriend(BuildContext context) async {
    final provider = context.read<FriendsProvider>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF063970),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Remove friend?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          content: Text(
            'You will remove ${friend.name} from your friends list.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Remove',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final removed = await provider.removeFriend(friend);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(
          removed
              ? '${friend.name} was removed from friends.'
              : provider.errorMessage ?? 'We could not remove this friend.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(friend.id);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ChatActionButton(onPressed: isLoading ? null : onOpenChat),
        const SizedBox(width: 6),
        PopupMenuButton<_FriendMenuAction>(
          tooltip: 'More',
          enabled: !isLoading,
          color: const Color(0xFF063970),
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          ),
          icon: Icon(
            Icons.more_horiz_rounded,
            color: Colors.white.withValues(alpha: 0.74),
          ),
          onSelected: (action) {
            if (action == _FriendMenuAction.remove) {
              _removeFriend(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _FriendMenuAction.remove,
              child: Row(
                children: [
                  Icon(
                    Icons.person_remove_alt_1_rounded,
                    color: theme.colorScheme.error,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Remove friend',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _FriendMenuAction { remove }

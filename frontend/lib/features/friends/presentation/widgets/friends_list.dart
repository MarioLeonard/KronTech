part of '../screens/friends_screen.dart';

class _FriendsTab extends StatelessWidget {
  const _FriendsTab({
    required this.scrollController,
    this.onOpenChat,
    super.key,
  });

  final ScrollController scrollController;
  final ValueChanged<String>? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();

    if (provider.isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.errorMessage != null && provider.friends.isEmpty) {
      return _StateCard(
        icon: Icons.error_outline_rounded,
        title: 'We could not load friends',
        message: provider.errorMessage!,
        actionLabel: 'Try again',
        onAction: () => provider.loadFriends(refresh: true),
      );
    }

    if (provider.friends.isEmpty) {
      return const _StateCard(
        icon: Icons.group_outlined,
        title: 'You do not have friends yet',
        message: 'Search for people in the app and send the first request.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadFriends(refresh: true),
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 2, 0, 24),
        itemCount: provider.friends.length + (provider.isLoadingMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= provider.friends.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final friend = provider.friends[index];
          return _PersonTile(
            user: friend,
            trailing: _FriendActions(
              friend: friend,
              onOpenChat: friend.conversationId == null || onOpenChat == null
                  ? null
                  : () => onOpenChat!(friend.conversationId!),
            ),
          );
        },
      ),
    );
  }
}

part of '../screens/friends_screen.dart';

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request});

  final FriendRequest request;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(request.id);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            _PersonTile(user: request.sender, framed: false),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => provider.declineRequest(request),
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Decline'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => provider.acceptRequest(request),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

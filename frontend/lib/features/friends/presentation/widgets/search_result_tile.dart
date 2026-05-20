part of '../screens/friends_screen.dart';

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({required this.result});

  final FriendSearchResult result;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FriendsProvider>();
    final isLoading = provider.isActionLoading(result.user.id);
    final canInvite =
        result.relationshipStatus == FriendRelationshipStatus.available;

    return _PersonTile(
      user: result.user,
      trailing: canInvite
          ? FilledButton(
              onPressed: isLoading ? null : () => provider.sendRequest(result),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.tertiary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Send',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
            )
          : _StatusPill(
              icon: Icons.info_rounded,
              label: result.relationshipStatus.label,
              color: Theme.of(context).colorScheme.primary,
            ),
    );
  }
}

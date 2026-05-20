part of '../screens/trip_details_screen.dart';

class _TripFriendsSection extends StatelessWidget {
  const _TripFriendsSection({
    required this.trip,
    required this.onAddFriend,
    required this.onRemoveFriend,
  });

  final SavedTrip trip;
  final Future<bool> Function(FriendUser friend) onAddFriend;
  final Future<void> Function(FriendUser friend) onRemoveFriend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = context.watch<AuthProvider>().user;
    final isOwner = authUser?.id == trip.ownerUid || trip.ownerUid == null;
    final isBusy = context.watch<SavedTripsProvider>().sharingTripId == trip.id;

    return _DetailPanel(
      icon: Icons.group_rounded,
      title: 'Friends',
      subtitle: 'People who can see this trip in their Trips page',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (trip.friends.isEmpty)
            const _EmptySection(message: 'No friends have been added yet.')
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final friend in trip.friends)
                  _TripFriendTile(
                    friend: friend,
                    isBusy: isBusy,
                    canRemove: isOwner,
                    onRemove: () => onRemoveFriend(friend),
                  ),
              ],
            ),
          if (isOwner) ...[
            const SizedBox(height: 18),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => _showAddTripFriendSheet(
                        context: context,
                        trip: trip,
                        onAddFriend: onAddFriend,
                      ),
                icon: isBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.person_add_alt_1_rounded),
                label: Text(isBusy ? 'Updating...' : 'Add friends'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.tertiary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

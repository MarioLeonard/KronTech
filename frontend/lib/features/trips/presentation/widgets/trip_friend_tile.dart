part of '../screens/trip_details_screen.dart';

class _TripFriendTile extends StatelessWidget {
  const _TripFriendTile({
    required this.friend,
    required this.isBusy,
    required this.canRemove,
    required this.onRemove,
  });

  final FriendUser friend;
  final bool isBusy;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final maxWidth = screenWidth < 560 ? screenWidth - 64 : 360.0;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(260.0, 360.0)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppAvatar(imageUrl: friend.avatarUrl, radius: 22),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (friend.email?.isNotEmpty == true) ...[
                      const SizedBox(height: 3),
                      Text(
                        friend.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.56),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (canRemove) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: isBusy ? null : onRemove,
                  tooltip: 'Remove from trip',
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.white.withValues(alpha: 0.72),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showAddTripFriendSheet({
  required BuildContext context,
  required SavedTrip trip,
  required Future<bool> Function(FriendUser friend) onAddFriend,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: false,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.34),
    builder: (_) => _AddTripFriendSheet(trip: trip, onAddFriend: onAddFriend),
  );
}

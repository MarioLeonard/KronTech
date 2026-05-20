part of '../screens/trip_details_screen.dart';

class _FriendPickerRow extends StatelessWidget {
  const _FriendPickerRow({
    required this.friend,
    required this.isAdding,
    required this.onTap,
  });

  final FriendUser friend;
  final bool isAdding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              AppAvatar(imageUrl: friend.avatarUrl, radius: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  friend.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isAdding)
                const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.add_circle_outline_rounded,
                  color: theme.colorScheme.tertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

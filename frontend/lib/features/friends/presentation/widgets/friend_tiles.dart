part of '../screens/friends_screen.dart';

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.user, this.trailing, this.framed = true});

  final FriendUser user;
  final Widget? trailing;
  final bool framed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final textMaxWidth = screenWidth < 560 ? screenWidth - 190 : 280.0;
    void openProfile() {
      showUserProfileSheet(
        context,
        name: user.name,
        avatarUrl: user.avatarUrl,
        email: user.email,
        userId: user.id,
      );
    }

    final tile = Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: 'View profile',
            child: Semantics(
              button: true,
              label: 'View ${user.name} profile',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: openProfile,
                  child: AppAvatar(
                    imageUrl: user.avatarUrl,
                    radius: 23,
                    onTap: openProfile,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: textMaxWidth.clamp(140.0, 320.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (user.email != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    user.email!,
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
          if (trailing != null) ...[const SizedBox(width: 12), trailing!],
        ],
      ),
    );

    if (!framed) {
      return tile;
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: tile,
      ),
    );
  }
}

part of '../main_shell.dart';

class _ChatMessageToast extends StatelessWidget {
  const _ChatMessageToast({
    required this.senderName,
    required this.message,
    required this.avatarUrl,
    required this.onTap,
    required this.onDismiss,
  });

  final String senderName;
  final String message;
  final String? avatarUrl;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final isCompact = width < 560;

    return Positioned(
      right: isCompact ? 14 : 24,
      bottom: isCompact ? 96 : 24,
      child: SafeArea(
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, progress, child) {
              return Opacity(
                opacity: progress,
                child: Transform.translate(
                  offset: Offset(22 * (1 - progress), 10 * (1 - progress)),
                  child: Transform.scale(
                    alignment: Alignment.bottomRight,
                    scale: 0.96 + (0.04 * progress),
                    child: child,
                  ),
                ),
              );
            },
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isCompact ? width - 28 : 380,
                minWidth: isCompact ? width - 28 : 340,
              ),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFF071827).withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.32),
                        blurRadius: 28,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        AppAvatar(imageUrl: avatarUrl, radius: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: RichText(
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.76),
                                fontWeight: FontWeight.w700,
                                height: 1.32,
                              ),
                              children: [
                                TextSpan(
                                  text: '$senderName: ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                TextSpan(text: message),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          tooltip: 'Dismiss',
                          onPressed: onDismiss,
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.white.withValues(alpha: 0.62),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

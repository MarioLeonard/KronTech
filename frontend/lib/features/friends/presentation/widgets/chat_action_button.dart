part of '../screens/friends_screen.dart';

class _ChatActionButton extends StatelessWidget {
  const _ChatActionButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: 'Chat',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 160),
          opacity: onPressed == null ? 0.42 : 1,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.28),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Icon(
                Icons.chat_bubble_rounded,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

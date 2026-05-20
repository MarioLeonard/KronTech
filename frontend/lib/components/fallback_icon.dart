part of 'app_avatar.dart';

class _FallbackIcon extends StatelessWidget {
  const _FallbackIcon({required this.icon, required this.radius});

  final IconData icon;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Icon(icon, color: theme.colorScheme.primary, size: radius);
  }
}

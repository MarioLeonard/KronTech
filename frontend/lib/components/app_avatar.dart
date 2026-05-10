import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.imageUrl,
    this.radius = 20,
    this.icon = Icons.person_rounded,
    super.key,
  });

  final String? imageUrl;
  final double radius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl?.trim();

    return SizedBox.square(
      dimension: radius * 2,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
          child: url == null || url.isEmpty
              ? _FallbackIcon(icon: icon, radius: radius)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    return _FallbackIcon(icon: icon, radius: radius);
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return _FallbackIcon(icon: icon, radius: radius);
                  },
                ),
        ),
      ),
    );
  }
}

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

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_avatar_html_stub.dart'
    if (dart.library.html) 'app_avatar_html_web.dart'
    as avatar_html;

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    required this.imageUrl,
    this.imageBytes,
    this.radius = 20,
    this.icon = Icons.person_rounded,
    this.onTap,
    super.key,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final double radius;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = imageUrl?.trim();

    final avatar = SizedBox.square(
      dimension: radius * 2,
      child: ClipOval(
        child: DecoratedBox(
          decoration: BoxDecoration(color: theme.colorScheme.secondary),
          child: imageBytes != null
              ? Image.memory(imageBytes!, fit: BoxFit.cover)
              : url == null || url.isEmpty
              ? _FallbackIcon(icon: icon, radius: radius)
              : kIsWeb
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    _FallbackIcon(icon: icon, radius: radius),
                    avatar_html.buildHtmlAvatarImage(url, onTap),
                  ],
                )
              : CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (_, _) {
                    return _FallbackIcon(icon: icon, radius: radius);
                  },
                  errorWidget: (_, _, _) {
                    debugPrint('[AppAvatar] Cached image failed for $url');
                    return _FallbackIcon(icon: icon, radius: radius);
                  },
                ),
        ),
      ),
    );

    if (kIsWeb && url != null && url.isNotEmpty) {
      return avatar;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: avatar,
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

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

int _avatarViewCounter = 0;

Widget buildHtmlAvatarImage(String url, VoidCallback? onTap) {
  final viewType = 'app-avatar-${url.hashCode}-${_avatarViewCounter++}';

  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final image = html.ImageElement()
      ..src = url
      ..alt = 'Profile photo'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover'
      ..style.borderRadius = '50%'
      ..style.display = 'block'
      ..style.pointerEvents = 'none';

    image.onError.listen((_) {
      image.style.display = 'none';
    });

    final element = html.DivElement()
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.borderRadius = '50%'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = 'transparent'
      ..style.cursor = onTap == null ? 'default' : 'pointer'
      ..children.add(image);

    if (onTap != null) {
      element.onClick.listen((event) {
        event.preventDefault();
        event.stopPropagation();
        onTap();
      });
    }

    return element;
  });

  return HtmlElementView(viewType: viewType);
}

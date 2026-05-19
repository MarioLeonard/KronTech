// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';

final Set<String> _registeredAvatarViews = <String>{};

Widget buildHtmlAvatarImage(String url) {
  final viewType = 'app-avatar-${url.hashCode}';

  if (_registeredAvatarViews.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final image = html.ImageElement()
        ..src = url
        ..alt = 'Profile photo'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover'
        ..style.borderRadius = '50%'
        ..style.display = 'block';

      image.onError.listen((_) {
        image.style.display = 'none';
      });

      return html.DivElement()
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.borderRadius = '50%'
        ..style.overflow = 'hidden'
        ..style.backgroundColor = 'transparent'
        ..children.add(image);
    });
  }

  return HtmlElementView(viewType: viewType);
}

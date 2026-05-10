// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

class BrowserChatNotifications {
  Future<void> requestPermission() async {
    if (!html.Notification.supported) {
      return;
    }
    if (html.Notification.permission == 'default') {
      await html.Notification.requestPermission();
    }
  }

  void show({
    required String title,
    required String body,
    required void Function() onClick,
  }) {
    if (!html.Notification.supported ||
        html.Notification.permission != 'granted') {
      return;
    }

    final notification = html.Notification(title, body: body);
    Timer(const Duration(seconds: 5), notification.close);
    notification.onClick.listen((_) {
      notification.close();
      onClick();
    });
  }
}

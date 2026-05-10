class BrowserChatNotifications {
  Future<void> requestPermission() async {}

  void show({
    required String title,
    required String body,
    required void Function() onClick,
  }) {}
}

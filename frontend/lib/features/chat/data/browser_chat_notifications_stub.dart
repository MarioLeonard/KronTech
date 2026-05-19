class BrowserChatNotifications {
  Future<void> requestPermission() async {}

  void show({
    required String title,
    required String body,
    String? iconUrl,
    required void Function() onClick,
  }) {}
}

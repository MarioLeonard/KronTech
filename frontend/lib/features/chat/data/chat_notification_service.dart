import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
part 'chat_notification_event.dart';

class ChatNotificationService {
  final _eventsController = StreamController<ChatNotificationEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;

  Stream<ChatNotificationEvent> get events => _eventsController.stream;

  void connect({required Uri uri, required void Function() onDisconnected}) {
    disconnect();
    final channel = WebSocketChannel.connect(uri);
    var didReportDisconnect = false;

    void reportDisconnected([Object? _]) {
      if (_channel != channel || didReportDisconnect) {
        return;
      }
      didReportDisconnect = true;
      onDisconnected();
    }

    _channel = channel;
    unawaited(channel.ready.catchError(reportDisconnected));
    _subscription = channel.stream.listen(
      _handleEvent,
      onError: reportDisconnected,
      onDone: reportDisconnected,
      cancelOnError: true,
    );
  }

  void disconnect() {
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventsController.close();
  }

  void _handleEvent(dynamic event) {
    final decoded = jsonDecode(event as String);
    if (decoded is! Map<String, dynamic>) {
      return;
    }

    if (decoded['type'] != 'chat_notification') {
      return;
    }

    final notification = ChatNotificationEvent.fromJson(decoded);
    if (notification.conversationId.isEmpty) {
      return;
    }
    _eventsController.add(notification);
  }
}

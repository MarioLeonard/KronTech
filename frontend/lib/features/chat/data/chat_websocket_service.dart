import 'dart:async';
import 'dart:convert';

import 'package:frontend/features/chat/domain/chat_message.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'chat_web_socket_service.dart';

enum ChatSocketConnectionState { disconnected, connecting, connected }

class ChatSocketEvent {
  const ChatSocketEvent({
    required this.type,
    this.message,
    this.userId,
    this.status,
    this.lastSeen,
    this.error,
  });

  final String type;
  final ChatMessage? message;
  final String? userId;
  final String? status;
  final DateTime? lastSeen;
  final String? error;
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:frontend/features/chat/data/chat_api_service.dart';
import 'package:frontend/features/chat/data/chat_websocket_service.dart';
import 'package:frontend/features/chat/domain/chat_conversation.dart';
import 'package:frontend/features/chat/domain/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required String currentUserId,
    required String idToken,
    String? initialConversationId,
    ChatApiService? apiService,
    ChatWebSocketService? webSocketService,
  }) : _currentUserId = currentUserId,
       _idToken = idToken,
       _initialConversationId = initialConversationId,
       _apiService = apiService ?? ChatApiService(),
       _webSocketService = webSocketService ?? ChatWebSocketService() {
    _socketSubscription = _webSocketService.events.listen(_handleSocketEvent);
  }

  final String _currentUserId;
  final String _idToken;
  final String? _initialConversationId;
  final ChatApiService _apiService;
  final ChatWebSocketService _webSocketService;

  late final StreamSubscription<ChatSocketEvent> _socketSubscription;
  Timer? _reconnectTimer;
  bool _shouldReconnect = false;

  List<ChatConversation> _conversations = <ChatConversation>[];
  ChatConversation? _selectedConversation;
  String _searchQuery = '';
  bool _isLoadingConversations = false;
  bool _isLoadingMessages = false;
  bool _isSending = false;
  String? _errorMessage;
  ChatSocketConnectionState _connectionState =
      ChatSocketConnectionState.disconnected;

  List<ChatConversation> get conversations => _conversations;
  ChatConversation? get selectedConversation => _selectedConversation;
  List<ChatMessage> get currentMessages =>
      _selectedConversation?.messages ?? <ChatMessage>[];
  bool get isLoadingConversations => _isLoadingConversations;
  bool get isLoadingMessages => _isLoadingMessages;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;
  ChatSocketConnectionState get connectionState => _connectionState;

  List<ChatConversation> get sortedConversations {
    final sorted = [..._conversations];
    sorted.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return sorted;
  }

  List<ChatConversation> get filteredConversations {
    if (_searchQuery.isEmpty) return sortedConversations;
    return sortedConversations
        .where(
          (conv) => conv.participant.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ),
        )
        .toList();
  }

  int get totalUnreadCount =>
      _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  Future<void> init() async {
    if (_isLoadingConversations) return;

    _isLoadingConversations = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _conversations = await _apiService.fetchConversations(
        idToken: _idToken,
        currentUserId: _currentUserId,
      );
      if (_conversations.isNotEmpty) {
        final initialConversation = _initialConversationId;
        final selectedId =
            initialConversation != null &&
                _conversations.any((item) => item.id == initialConversation)
            ? initialConversation
            : _conversations.first.id;
        await selectConversation(selectedId);
      }
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingConversations = false;
      notifyListeners();
    }
  }

  Future<void> selectConversation(String conversationId) async {
    ChatConversation? conversation;
    for (final item in _conversations) {
      if (item.id == conversationId) {
        conversation = item;
        break;
      }
    }
    if (conversation == null) return;

    _selectedConversation = conversation;
    _isLoadingMessages = true;
    _errorMessage = null;
    notifyListeners();

    _connectSocket(conversation.id);

    try {
      final messages = await _apiService.fetchMessages(
        idToken: _idToken,
        currentUserId: _currentUserId,
        conversationId: conversation.id,
      );
      _selectedConversation = conversation.copyWith(
        messages: messages,
        lastMessageTime: messages.isNotEmpty
            ? messages.last.timestamp
            : conversation.lastMessageTime,
        unreadCount: 0,
      );
      _upsertSelectedConversation();
      await markAsRead(conversation.id);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMessages = false;
      notifyListeners();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    final conversation = _selectedConversation;
    final trimmedContent = content.trim();
    if (conversation == null || trimmedContent.isEmpty || _isSending) return;

    _isSending = true;
    final optimisticMessage = ChatMessage(
      id: 'pending-${DateTime.now().microsecondsSinceEpoch}',
      senderId: _currentUserId,
      senderName: 'You',
      content: trimmedContent,
      timestamp: DateTime.now(),
      isCurrentUser: true,
      status: MessageStatus.sending,
    );
    _appendOrReplaceMessage(optimisticMessage);
    notifyListeners();

    try {
      _webSocketService.sendMessage(
        content: trimmedContent,
        receiverId: conversation.participant.id,
      );
    } catch (error) {
      _errorMessage = error.toString();
      _replaceMessageStatus(optimisticMessage.id, MessageStatus.delivered);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final index = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
    }
    if (_selectedConversation?.id == conversationId) {
      _selectedConversation = _selectedConversation!.copyWith(unreadCount: 0);
    }

    try {
      await _apiService.markAsRead(
        idToken: _idToken,
        conversationId: conversationId,
      );
      _webSocketService.markAsRead();
    } catch (_) {
      // Read receipts are best-effort in the UI; the next refresh resyncs them.
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _connectSocket(String conversationId) {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _webSocketService.disconnect();

    _shouldReconnect = true;
    _connectionState = ChatSocketConnectionState.connecting;
    notifyListeners();

    _webSocketService.connect(
      uri: _apiService.websocketUri(
        conversationId: conversationId,
        idToken: _idToken,
      ),
      currentUserId: _currentUserId,
      onDisconnected: _handleSocketDisconnected,
    );
    _connectionState = ChatSocketConnectionState.connected;
  }

  void _handleSocketDisconnected() {
    if (!_shouldReconnect) return;
    _connectionState = ChatSocketConnectionState.disconnected;
    notifyListeners();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () {
      final conversationId = _selectedConversation?.id;
      if (conversationId != null && _shouldReconnect) {
        _connectSocket(conversationId);
      }
    });
  }

  void _handleSocketEvent(ChatSocketEvent event) {
    if (event.type == 'chat_message' && event.message != null) {
      _appendOrReplaceMessage(event.message!);
      if (!event.message!.isCurrentUser && _selectedConversation != null) {
        markAsRead(_selectedConversation!.id);
      }
      notifyListeners();
      return;
    }

    if (event.type == 'error') {
      _errorMessage = event.error ?? 'Chat connection error.';
      notifyListeners();
    }
  }

  void _appendOrReplaceMessage(ChatMessage message) {
    final conversation = _selectedConversation;
    if (conversation == null) return;

    final messages = [...conversation.messages];
    final existingIndex = messages.indexWhere((item) => item.id == message.id);
    if (existingIndex != -1) {
      messages[existingIndex] = message;
    } else {
      final pendingIndex = messages.indexWhere(
        (item) =>
            item.status == MessageStatus.sending &&
            item.isCurrentUser == message.isCurrentUser &&
            item.content == message.content,
      );
      if (pendingIndex != -1) {
        messages[pendingIndex] = message;
      } else {
        messages.add(message);
      }
    }

    _selectedConversation = conversation.copyWith(
      messages: messages,
      lastMessageTime: message.timestamp,
    );
    _upsertSelectedConversation();
  }

  void _replaceMessageStatus(String messageId, MessageStatus status) {
    final conversation = _selectedConversation;
    if (conversation == null) return;
    final messages = conversation.messages
        .map(
          (message) => message.id == messageId
              ? message.copyWith(status: status)
              : message,
        )
        .toList();
    _selectedConversation = conversation.copyWith(messages: messages);
    _upsertSelectedConversation();
  }

  void _upsertSelectedConversation() {
    final selected = _selectedConversation;
    if (selected == null) return;

    final index = _conversations.indexWhere((conv) => conv.id == selected.id);
    if (index == -1) {
      _conversations.add(selected);
    } else {
      _conversations[index] = selected;
    }
  }

  @override
  void dispose() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _socketSubscription.cancel();
    _webSocketService.dispose();
    super.dispose();
  }
}

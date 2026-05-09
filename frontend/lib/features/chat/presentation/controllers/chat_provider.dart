import 'package:flutter/foundation.dart';
import '../../domain/chat_conversation.dart';
import '../../domain/chat_message.dart';

/// Provider for managing chat state and operations
class ChatProvider extends ChangeNotifier {
  /// All available conversations
  List<ChatConversation> _conversations = ChatConversation.sampleConversations;

  /// Currently selected conversation
  ChatConversation? _selectedConversation;

  /// Search query for filtering conversations
  String _searchQuery = '';

  /// Getter for all conversations
  List<ChatConversation> get conversations => _conversations;

  /// Getter for selected conversation
  ChatConversation? get selectedConversation => _selectedConversation;

  /// Getter for messages in selected conversation
  List<ChatMessage> get currentMessages =>
      _selectedConversation?.messages ?? [];

  /// Getter for sorted conversations (by last message time, newest first)
  List<ChatConversation> get sortedConversations {
    final sorted = [..._conversations];
    sorted.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return sorted;
  }

  /// Getter for filtered and sorted conversations based on search query
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

  /// Get total unread message count
  int get totalUnreadCount =>
      _conversations.fold(0, (sum, conv) => sum + conv.unreadCount);

  /// Initialize provider (load sample data)
  void init() {
    _conversations = ChatConversation.sampleConversations;
    if (_conversations.isNotEmpty) {
      _selectedConversation = _conversations[0];
    }
    notifyListeners();
  }

  /// Select a conversation by ID
  void selectConversation(String conversationId) {
    ChatConversation? conversation;
    for (final conv in _conversations) {
      if (conv.id == conversationId) {
        conversation = conv;
        break;
      }
    }
    if (conversation != null) {
      _selectedConversation = conversation;
      markAsRead(conversationId);
      notifyListeners();
    }
  }

  /// Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Send a new message to the current conversation
  void sendMessage(String content) {
    if (_selectedConversation == null || content.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'current-user',
      senderName: 'You',
      content: content.trim(),
      timestamp: DateTime.now(),
      isCurrentUser: true,
      status: MessageStatus.delivered,
    );

    final updatedMessages = [..._selectedConversation!.messages, newMessage];

    _selectedConversation = _selectedConversation!.copyWith(
      messages: updatedMessages,
      lastMessageTime: DateTime.now(),
    );

    // Update conversation in the list
    final conversationIndex = _conversations.indexWhere(
      (conv) => conv.id == _selectedConversation!.id,
    );

    if (conversationIndex != -1) {
      _conversations[conversationIndex] = _selectedConversation!;
    }

    notifyListeners();
  }

  /// Mark conversation as read
  void markAsRead(String conversationId) {
    final index = _conversations.indexWhere(
      (conv) => conv.id == conversationId,
    );
    if (index != -1) {
      _conversations[index] = _conversations[index].copyWith(unreadCount: 0);
      notifyListeners();
    }
  }

  /// Clear search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}

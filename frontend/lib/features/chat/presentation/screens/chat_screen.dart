import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/chat_provider.dart';
import '../widgets/chat_conversation_view.dart';
import '../widgets/chat_sidebar.dart';

/// Main chat screen with responsive layout
/// On large screens: split view with sidebar and conversation
/// On mobile: shows sidebar, navigates to conversation detail
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().init();
    });
  }

  /// Navigate to participant's profile (placeholder for now)
  void _navigateToProfile(String participantName) {
    debugPrint('Navigating to profile of: $participantName');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile: $participantName'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// Show conversation detail on mobile
  void _showConversationDetail(BuildContext context) {
    final chatProvider = context.read<ChatProvider>();
    final conversation = chatProvider.selectedConversation;

    if (conversation == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(conversation.participant.name),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ChatConversationView(
            conversation: conversation,
            onParticipantTap: () {
              Navigator.pop(context);
              _navigateToProfile(conversation.participant.name);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isLargeScreen = screenSize.width > 900;

    return Consumer<ChatProvider>(
      builder: (context, chatProvider, _) {
        if (isLargeScreen) {
          /// Split view for large screens
          return Row(
            children: [
              /// Sidebar
              SizedBox(
                width: 320,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: ChatSidebar(
                    selectedConversationId:
                        chatProvider.selectedConversation?.id,
                    onConversationSelected: (conversationId) {
                      chatProvider.selectConversation(conversationId);
                    },
                  ),
                ),
              ),

              /// Main conversation view
              Expanded(
                child: ChatConversationView(
                  conversation: chatProvider.selectedConversation,
                  onParticipantTap: () {
                    if (chatProvider.selectedConversation != null) {
                      _navigateToProfile(
                        chatProvider.selectedConversation!.participant.name,
                      );
                    }
                  },
                ),
              ),
            ],
          );
        } else {
          /// Mobile layout - showing sidebar with navigation
          return Scaffold(
            appBar: AppBar(title: const Text('Messages'), centerTitle: false),
            body: ChatSidebar(
              selectedConversationId: chatProvider.selectedConversation?.id,
              onConversationSelected: (conversationId) {
                chatProvider.selectConversation(conversationId);
                _showConversationDetail(context);
              },
            ),
          );
        }
      },
    );
  }
}

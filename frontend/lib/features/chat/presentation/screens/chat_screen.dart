import 'package:flutter/material.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/components/user_profile_sheet.dart';
import 'package:provider/provider.dart';
import '../../domain/chat_user.dart';
import '../controllers/chat_provider.dart';
import '../widgets/chat_conversation_view.dart';
import '../widgets/chat_sidebar.dart';

part 'chat_screen_state.dart';
part 'messages_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

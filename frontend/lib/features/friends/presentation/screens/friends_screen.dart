import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/glass_container.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/components/user_profile_sheet.dart';
import 'package:frontend/features/friends/domain/friend_request.dart';
import 'package:frontend/features/friends/domain/friend_user.dart';
import 'package:frontend/features/friends/presentation/controllers/friends_provider.dart';
import 'package:provider/provider.dart';

part '../widgets/friends_tabs.dart';
part '../widgets/friends_list.dart';
part '../widgets/find_friends_sheet.dart';
part '../widgets/friend_tiles.dart';
part 'friends_screen_state.dart';
part '../widgets/find_friends_sheet_state.dart';
part '../widgets/search_result_tile.dart';
part '../widgets/request_tile.dart';
part '../widgets/status_pill.dart';
part '../widgets/state_card.dart';
part '../widgets/friend_actions.dart';
part '../widgets/chat_action_button.dart';
part '../widgets/requests_tab.dart';
part '../widgets/friends_segment_button.dart';
part '../widgets/count_badge.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({this.onOpenChat, super.key});

  final ValueChanged<String>? onOpenChat;

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

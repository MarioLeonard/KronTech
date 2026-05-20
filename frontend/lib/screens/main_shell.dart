import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frontend/components/app_avatar.dart';
import 'package:frontend/components/premium_background.dart';
import 'package:frontend/features/chat/data/browser_chat_notifications.dart';
import 'package:frontend/features/chat/data/chat_api_service.dart';
import 'package:frontend/features/chat/data/chat_notification_service.dart';
import 'package:frontend/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/friends_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';

part 'main_shell/main_shell_page_transition.dart';
part 'main_shell/main_shell_navigation_rail.dart';
part 'main_shell/main_shell_navigation_bar.dart';
part 'main_shell/main_shell_chat_toast.dart';
part 'main_shell/main_shell_destination.dart';
part 'main_shell/main_shell_state.dart';
part 'main_shell/bottom_destination_button.dart';
part 'main_shell/rail_destination_list.dart';
part 'main_shell/rail_selection_pill.dart';
part 'main_shell/rail_destination_button.dart';
part 'main_shell/shell_page_transition_state.dart';
part 'main_shell/shell_page_slot.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.user, super.key});

  final AuthUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

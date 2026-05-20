import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:frontend/components/feature_card.dart';
import 'package:frontend/components/feature_row.dart';
import 'package:frontend/models/auth_user.dart';

part 'home/home_screen_pages.dart';
part 'home/home_screen_feature_sections.dart';
part 'home/home_screen_state.dart';
part 'home/home_feature_page.dart';
part 'home/animated_feature_section.dart';
part 'home/animated_feature_section_state.dart';
part 'home/app_story_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.user,
    required this.onNavigateToTrips,
    required this.onNavigateToChat,
    super.key,
  });

  final AuthUser user;
  final VoidCallback onNavigateToTrips;
  final VoidCallback onNavigateToChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

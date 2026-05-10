import 'package:flutter/material.dart';
import 'package:frontend/features/friends/presentation/controllers/friends_provider.dart';
import 'package:frontend/features/friends/presentation/screens/friends_screen.dart'
    as friends_feature;
import 'package:frontend/providers/auth_provider.dart' as app_auth;
import 'package:provider/provider.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({this.onOpenChat, super.key});

  final ValueChanged<String>? onOpenChat;

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<app_auth.AuthProvider>().user;
    if (authUser == null) {
      return const Center(child: Text('Sign in to see friends'));
    }

    return ChangeNotifierProvider(
      create: (_) => FriendsProvider(idToken: authUser.idToken)..init(),
      child: friends_feature.FriendsScreen(onOpenChat: onOpenChat),
    );
  }
}

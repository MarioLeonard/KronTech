import 'package:flutter/material.dart';
import 'package:frontend/models/auth_user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.user, super.key});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Welcome!', style: theme.textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text(
                  user.displayName ?? user.email ?? 'Authenticated user',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Signed in with ${user.provider.name.toUpperCase()}',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

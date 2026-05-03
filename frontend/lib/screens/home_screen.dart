import 'package:flutter/material.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.user, super.key});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('KronTech'),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.go('/login');
            },
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome!',
                style: theme.textTheme.headlineMedium,
              ),
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
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.go('/map'),
                    icon: const Icon(Icons.map),
                    label: const Text('Open Map'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/list'),
                    icon: const Icon(Icons.list),
                    label: const Text('View List'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/profile'),
                    icon: const Icon(Icons.person),
                    label: const Text('Profile'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/app_shell.dart';
import '../providers/auth_provider.dart';
import '../providers/objectives_provider.dart';
import '../providers/route_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    final theme = Theme.of(context);

    return Scaffold(
      body: AppShell(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                'Profile',
                style: theme.textTheme.headlineSmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      (user?.displayName ?? user?.email ?? '?')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(fontSize: 32, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Guest',
                    style: theme.textTheme.titleLarge,
                  ),
                  if (user?.email != null)
                    Text(user!.email!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Signed in with ${user?.provider.name.toUpperCase() ?? 'UNKNOWN'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  context.read<AuthProvider>().signOut();
                  context.read<ObjectivesProvider>().clearSelection();
                  context.read<RouteProvider>().clearRoute();
                  context.go('/login');
                },
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

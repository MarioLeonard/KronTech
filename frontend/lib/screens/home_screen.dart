import 'package:flutter/material.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/profile_provider.dart';
import 'package:provider/provider.dart';

import 'profile_screen.dart';

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
          IconButton(
            icon: const Icon(Icons.person_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChangeNotifierProvider(
                    create: (_) => ProfileProvider(
                      firstName: user.displayName?.split(' ').first ?? '',
                      lastName:
                          user.displayName?.split(' ').skip(1).join(' ') ?? '',
                      email: user.email ?? '',
                    ),
                    child: const ProfileScreen(),
                  ),
                ),
              );
            },
            tooltip: 'Profile',
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
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName ?? user.email ?? 'Authenticated user',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  'Signed in with ${user.provider.name.toUpperCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: theme.colorScheme.secondary,
                      size: 28,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tap the profile icon above to manage your account details',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

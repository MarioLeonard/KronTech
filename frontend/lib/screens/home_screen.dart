import 'package:flutter/material.dart';
import 'package:frontend/components/feature_card.dart';
import 'package:frontend/components/feature_row.dart';
import 'package:frontend/models/auth_user.dart';

class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Text(
              'Welcome, ${user.displayName?.split(' ').first ?? 'Traveler'}!',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your journey starts here. Explore your options below.',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
            const SizedBox(height: 80),

            // Zig-Zag Layout Section 1: Trips
            FeatureRow(
              isCardLeft: true,
              card: FeatureCard(
                title: 'Trips',
                buttonText: 'Add Trip',
                icon: Icons.explore_rounded,
                imagePath: 'assets/images/trips.png',
                onPressed: onNavigateToTrips,
              ),
              textContent: _buildMarketingText(
                context,
                title: 'Best Routes',
                content:
                    'We can help you find the best and most interesting routes in the city you are about to visit! Add your trip here!',
              ),
            ),

            const SizedBox(height: 100),

            // Zig-Zag Layout Section 2: Messages
            FeatureRow(
              isCardLeft: false,
              card: FeatureCard(
                title: 'Messages',
                buttonText: 'Open Chat',
                icon: Icons.chat_bubble_rounded,
                imagePath: 'assets/images/messages.png',
                onPressed: onNavigateToChat,
              ),
              textContent: _buildMarketingText(
                context,
                title: 'Stay Connected',
                content:
                    'Have some friends you want to go out into the world with? Add them and start chatting with them right here!',
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketingText(
    BuildContext context, {
    required String title,
    required String content,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 4,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 4,
          width: 80,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

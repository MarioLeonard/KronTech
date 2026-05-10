import 'package:flutter/material.dart';
import 'package:frontend/features/trips/presentation/screens/my_trips_screen.dart';
import 'package:frontend/models/auth_user.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/chat_screen.dart';
import 'package:frontend/screens/friends_screen.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:frontend/screens/settings_screen.dart';
import 'package:provider/provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({required this.user, super.key});

  final AuthUser user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = [
      _ShellDestination(
        label: 'Home',
        icon: Icons.home_rounded,
        content: HomeScreen(user: widget.user),
      ),
      const _ShellDestination(
        label: 'Trips',
        icon: Icons.route_rounded,
        content: MyTripsScreen(),
      ),
      _ShellDestination(
        label: 'Profile',
        icon: Icons.person_rounded,
        content: ProfileScreen(user: widget.user),
      ),
      const _ShellDestination(
        label: 'Friends',
        icon: Icons.group_rounded,
        content: FriendsScreen(),
      ),
      const _ShellDestination(
        label: 'Chat',
        icon: Icons.chat_bubble_rounded,
        content: ChatScreen(),
      ),
      const _ShellDestination(
        label: 'Settings',
        icon: Icons.settings_rounded,
        content: SettingsScreen(),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final current = destinations[_selectedIndex];

        return Scaffold(
          appBar: AppBar(
            title: Text(current.label),
            actions: [
              TextButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: isWide
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      labelType: NavigationRailLabelType.none,
                      destinations: destinations
                          .map(
                            (destination) => NavigationRailDestination(
                              icon: Icon(destination.icon),
                              label: Text(destination.label),
                            ),
                          )
                          .toList(),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: current.content),
                  ],
                )
              : Column(
                  children: [
                    Expanded(child: current.content),
                    NavigationBar(
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => _selectedIndex = index);
                      },
                      destinations: destinations
                          .map(
                            (destination) => NavigationDestination(
                              icon: Icon(destination.icon),
                              label: destination.label,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _ShellDestination {
  const _ShellDestination({
    required this.label,
    required this.icon,
    required this.content,
  });

  final String label;
  final IconData icon;
  final Widget content;
}

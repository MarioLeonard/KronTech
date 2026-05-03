import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map')) {
      return 0;
    }
    if (location.startsWith('/list')) {
      return 1;
    }
    if (location.startsWith('/profile')) {
      return 2;
    }
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/map');
        break;
      case 1:
        context.go('/list');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final index = _selectedIndex(context);

    if (width < 600) {
      return Column(
        children: [
          Expanded(child: child),
          BottomNavigationBar(
            currentIndex: index,
            onTap: (value) => _onTap(context, value),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list_outlined),
                label: 'List',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outlined),
                label: 'Profile',
              ),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        NavigationRail(
          selectedIndex: index,
          extended: false,
          labelType: NavigationRailLabelType.none,
          onDestinationSelected: (value) => _onTap(context, value),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.map_outlined),
              selectedIcon: Icon(Icons.map),
              label: Text('Map'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.list_outlined),
              selectedIcon: Icon(Icons.list),
              label: Text('List'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person),
              label: Text('Profile'),
            ),
          ],
        ),
        Expanded(child: child),
      ],
    );
  }
}

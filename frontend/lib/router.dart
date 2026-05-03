import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/detail_screen.dart';
import 'screens/home_screen.dart';
import 'screens/list_screen.dart';
import 'screens/login_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';

class RouterProvider extends ChangeNotifier {
  RouterProvider(this._authProvider) {
    _authProvider.addListener(_handleAuthChanged);
  }

  AuthProvider _authProvider;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: this,
    redirect: (context, state) {
      final isLoggedIn =
          _authProvider.isAuthenticated && _authProvider.user != null;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) {
        return '/login';
      }
      if (isLoggedIn && isOnLogin) {
        return '/map';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(
        path: '/home',
        builder: (c, s) {
          final user = c.read<AuthProvider>().user;
          return user == null ? const LoginScreen() : HomeScreen(user: user);
        },
      ),
      GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
      GoRoute(path: '/list', builder: (c, s) => const ListScreen()),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(objectiveId: id);
        },
      ),
      GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
    ],
  );

  void updateAuthProvider(AuthProvider authProvider) {
    if (_authProvider == authProvider) {
      return;
    }
    _authProvider.removeListener(_handleAuthChanged);
    _authProvider = authProvider;
    _authProvider.addListener(_handleAuthChanged);
    notifyListeners();
  }

  void _handleAuthChanged() {
    notifyListeners();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_handleAuthChanged);
    super.dispose();
  }
}

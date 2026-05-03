import 'package:flutter/material.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/providers/map_focus_provider.dart';
import 'package:frontend/providers/objectives_provider.dart';
import 'package:frontend/providers/route_provider.dart';
import 'package:frontend/router.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/services/oauth_auth_service.dart';
import 'package:frontend/services/routing_service.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authService: OAuthAuthService()),
        ),
        ChangeNotifierProvider(create: (_) => ObjectivesProvider()),
        ChangeNotifierProvider(
          create: (_) => RouteProvider(RoutingService()),
        ),
        ChangeNotifierProvider(create: (_) => MapFocusProvider()),
        ChangeNotifierProxyProvider<AuthProvider, RouterProvider>(
          create: (context) => RouterProvider(context.read<AuthProvider>()),
          update: (context, authProvider, routerProvider) {
            routerProvider?.updateAuthProvider(authProvider);
            return routerProvider ?? RouterProvider(authProvider);
          },
        ),
      ],
      child: Consumer<RouterProvider>(
        builder: (context, routerProvider, _) => MaterialApp.router(
        title: 'KronTech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D77)),
        ),
        routerConfig: routerProvider.router,
        ),
      ),
    );
  }
}

class AuthEntryPoint extends StatelessWidget {
  const AuthEntryPoint({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated && authProvider.user != null) {
          return HomeScreen(user: authProvider.user!);
        }

        return const LoginScreen();
      },
    );
  }
}

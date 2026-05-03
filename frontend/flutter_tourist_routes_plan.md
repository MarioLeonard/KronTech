# Flutter Web App — Tourist Route Planner
## Complete Build Plan (OpenStreetMap Edition)

> **Stack:** Flutter Web · flutter_map (OSM) · OSRM Routing · Provider · go_router  
> **Cost:** $0 — no API keys required  
> **Target:** 4 screens — Map, Objectives List, Objective Detail, Profile

---

## Table of Contents

1. [Project Setup](#1-project-setup)
2. [Folder Structure](#2-folder-structure)
3. [Data Model & Mock Data](#3-data-model--mock-data)
4. [Navigation Shell](#4-navigation-shell)
5. [State Management](#5-state-management)
6. [Screen 1 — Map](#6-screen-1--map)
7. [Screen 2 — Objectives List](#7-screen-2--objectives-list)
8. [Screen 3 — Objective Detail](#8-screen-3--objective-detail)
9. [Screen 4 — Profile](#9-screen-4--profile)
10. [OSRM Routing Service](#10-osrm-routing-service)
11. [Responsive Layout](#11-responsive-layout)
12. [Polish & Edge Cases](#12-polish--edge-cases)
13. [Build Order Summary](#13-build-order-summary)

---

## 1. Project Setup

### 1.1 Create the Flutter project

```bash
flutter create tourist_routes --platforms=web
cd tourist_routes
```

Verify web support is enabled:

```bash
flutter devices
# Should show: Chrome (web)
```

---

### 1.2 pubspec.yaml — Full dependency list

Open `pubspec.yaml` and add the map/listing dependencies below. Keep the existing auth stack (`provider`, `google_sign_in`, `sign_in_with_apple`, `flutter_secure_storage`) and `http` already in use.

```yaml
dependencies:
  # --- Map ---
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
  flutter_map_cancellable_tile_provider: ^2.0.0

  # --- Navigation ---
  go_router: ^13.0.0

  # --- UI Utilities ---
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
```

Run:

```bash
flutter pub get
```

---

### 1.3 web/index.html — OSM attribution

OpenStreetMap's tile usage policy requires attribution. Add the following CSS inside `<head>` in `web/index.html`:

```html
<style>
  /* Required OSM attribution styling */
  .leaflet-control-attribution {
    font-size: 10px;
  }
</style>
```

No API key needed — OSM tiles are public. The `flutter_map_cancellable_tile_provider` package handles the user-agent header automatically.

---

### 1.4 main.dart — Entry point

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/oauth_auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(authService: OAuthAuthService()),
      child: MaterialApp(
        title: 'KronTech',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006D77)),
        ),
        home: const AuthEntryPoint(),
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
```

---

## 2. Folder Structure

Create all folders before writing any screen code. This prevents import chaos later.

```
lib/
├── main.dart
├── router.dart                    # go_router config (to add)
│
├── animations/
├── components/
│   ├── social_auth_button.dart    # Existing
│   ├── objective_card.dart        # To add
│   └── route_bottom_panel.dart    # To add
│
├── models/
│   ├── auth_exception.dart        # Existing
│   ├── auth_user.dart             # Existing
│   └── objective.dart             # To add
│
├── services/
│   ├── auth_service.dart          # Existing auth interface
│   ├── oauth_auth_service.dart    # Existing OAuth implementation
│   └── routing_service.dart       # To add (OSRM HTTP calls)
│
├── providers/
│   ├── auth_provider.dart         # Existing auth state
│   ├── objectives_provider.dart   # To add (all objectives + selected IDs)
│   └── route_provider.dart        # To add (active polyline + loading state)
│
├── screens/
│   ├── home_screen.dart           # Existing
│   ├── login_screen.dart          # Existing
│   ├── map_screen.dart            # To add
│   ├── list_screen.dart           # To add
│   ├── detail_screen.dart         # To add
│   └── profile_screen.dart        # To add
│
└── utils/
  ├── api_endpoints.dart         # Existing
  └── mock_objectives.dart       # To add (landmark data)
```

---

## 3. Data Model & Mock Data

### 3.1 models/objective.dart

```dart
import 'package:latlong2/latlong.dart';

class Objective {
  final String id;
  final String name;
  final String shortDescription;   // shown on card
  final String longDescription;    // shown on detail screen
  final String imageUrl;
  final double lat;
  final double lng;
  final String category;           // "Monument" | "Museum" | "Park" | "Church" | "Square"
  final double rating;             // 0.0–5.0
  final String openingHours;       // e.g. "09:00–18:00"
  final String address;

  const Objective({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.longDescription,
    required this.imageUrl,
    required this.lat,
    required this.lng,
    required this.category,
    required this.rating,
    required this.openingHours,
    required this.address,
  });

  // Convenience getter for flutter_map
  LatLng get latLng => LatLng(lat, lng);

  // For storing selected IDs in shared_preferences
  Map<String, dynamic> toJson() => {'id': id, 'lat': lat, 'lng': lng};
}
```

---

### 3.2 data/mock_objectives.dart

Use real Bucharest coordinates so routes make geographic sense on the map.

```dart
import '../models/objective.dart';

const List<Objective> mockObjectives = [
  Objective(
    id: 'obj_01',
    name: 'Palace of the Parliament',
    shortDescription: 'The world\'s heaviest building.',
    longDescription: 'Built under Nicolae Ceaușescu beginning in 1984, the Palace of the Parliament is the world\'s heaviest building and the second-largest administrative building. It houses the Romanian Parliament and several museums.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e9/Palatul_Parlamentului%2C_Bucure%C8%99ti.jpg/1280px-Palatul_Parlamentului%2C_Bucure%C8%99ti.jpg',
    lat: 44.4272,
    lng: 26.0875,
    category: 'Monument',
    rating: 4.7,
    openingHours: '10:00–16:00',
    address: 'Strada Izvor 2–4, Bucharest',
  ),
  Objective(
    id: 'obj_02',
    name: 'Romanian Athenaeum',
    shortDescription: 'Iconic concert hall and cultural landmark.',
    longDescription: 'A concert hall in the center of Bucharest and a landmark of Romanian culture. Built in 1888, it is the home of the George Enescu Philharmonic and one of the most beautiful buildings in the city.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Ateneul_Roman.jpg/1280px-Ateneul_Roman.jpg',
    lat: 44.4411,
    lng: 26.0969,
    category: 'Monument',
    rating: 4.8,
    openingHours: '12:00–19:00',
    address: 'Strada Benjamin Franklin 1, Bucharest',
  ),
  Objective(
    id: 'obj_03',
    name: 'National Museum of Art of Romania',
    shortDescription: 'Romanian and European art collections.',
    longDescription: 'Located in the former Royal Palace on Revolution Square, the museum houses collections of medieval Romanian art, modern Romanian art, and European art spanning the 15th–20th centuries.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Muzeul_National_de_Arta_al_Romaniei.jpg/1280px-Muzeul_National_de_Arta_al_Romaniei.jpg',
    lat: 44.4397,
    lng: 26.0955,
    category: 'Museum',
    rating: 4.5,
    openingHours: '11:00–19:00',
    address: 'Calea Victoriei 49–53, Bucharest',
  ),
  Objective(
    id: 'obj_04',
    name: 'Cișmigiu Gardens',
    shortDescription: 'Central park with a beautiful lake.',
    longDescription: 'The oldest and most central park in Bucharest, Cișmigiu Gardens was opened in 1847. It features a large lake, rowing boats, shaded alleys, and a chess pavilion.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Parcul_Cismigiu_Bucuresti.jpg/1280px-Parcul_Cismigiu_Bucuresti.jpg',
    lat: 44.4362,
    lng: 26.0895,
    category: 'Park',
    rating: 4.6,
    openingHours: 'Open 24 hours',
    address: 'Bulevardul Regina Elisabeta, Bucharest',
  ),
  Objective(
    id: 'obj_05',
    name: 'Stavropoleos Monastery',
    shortDescription: '18th-century monastery in the Old Town.',
    longDescription: 'A small but exquisitely beautiful Orthodox monastery built in 1724 in the Brâncovenesc style. Its courtyard garden is one of the most peaceful spots in the Old Town.',
    imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c9/Manastirea_Stavropoleos.jpg/800px-Manastirea_Stavropoleos.jpg',
    lat: 44.4312,
    lng: 26.1012,
    category: 'Church',
    rating: 4.7,
    openingHours: '08:00–20:00',
    address: 'Strada Stavropoleos 4, Bucharest',
  ),
  // Add 10 more landmarks following the same pattern...
  // Suggested: Herastrau Park, Village Museum, Revolution Square,
  // National History Museum, Grigore Antipa Natural History Museum,
  // Bucharest Zoo, Arcul de Triumf, Carturești Carusel Bookstore,
  // Old Court Church, Banca Nationala a Romaniei
];
```

---

## 4. Navigation Shell

### 4.1 router.dart

When adding `go_router`, keep the existing `AuthProvider` as the source of truth and use it to redirect between `/login` and the app routes. This replaces the current `AuthEntryPoint` once the router is wired.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/list_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/profile_screen.dart';

class RouterProvider extends ChangeNotifier {
  RouterProvider(this._authProvider) {
    _authProvider.addListener(notifyListeners);
  }

  final AuthProvider _authProvider;

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: this,
    redirect: (context, state) {
      final isLoggedIn = _authProvider.isAuthenticated;
      final isOnLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isOnLogin) {
        return '/login';
      }
      if (isLoggedIn && isOnLogin) {
        return '/home';
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

  @override
  void dispose() {
    _authProvider.removeListener(notifyListeners);
    super.dispose();
  }
}
```

---

### 4.2 widgets/app_shell.dart

This widget wraps all shell screens and provides the nav bar. It reads viewport width to switch between mobile and desktop layouts.

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  int _selectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/map'))     return 0;
    if (location.startsWith('/list'))    return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go('/map');     break;
      case 1: context.go('/list');    break;
      case 2: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final index = _selectedIndex(context);

    // Wide screen: NavigationRail on the left
    if (width >= 600) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: index,
              onDestinationSelected: (i) => _onTap(context, i),
              labelType: NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(icon: Icon(Icons.map_outlined),      selectedIcon: Icon(Icons.map),      label: Text('Map')),
                NavigationRailDestination(icon: Icon(Icons.list_outlined),     selectedIcon: Icon(Icons.list),     label: Text('List')),
                NavigationRailDestination(icon: Icon(Icons.person_outlined),   selectedIcon: Icon(Icons.person),   label: Text('Profile')),
              ],
            ),
            const VerticalDivider(width: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    // Narrow screen: BottomNavigationBar
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined),    label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.list_outlined),   label: 'List'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outlined), label: 'Profile'),
        ],
      ),
    );
  }
}
```

---

## 5. State Management

### 5.1 providers/objectives_provider.dart

Holds the full list of objectives and tracks which ones are selected.

```dart
import 'package:flutter/material.dart';
import '../utils/mock_objectives.dart';
import '../models/objective.dart';

class ObjectivesState {
  final List<Objective> all;
  final Set<String> selectedIds;
  final String? activeCategory;    // null = "All"

  const ObjectivesState({
    required this.all,
    this.selectedIds = const {},
    this.activeCategory,
  });

  List<Objective> get selected =>
      all.where((o) => selectedIds.contains(o.id)).toList();

  List<Objective> get filtered => activeCategory == null
      ? all
      : all.where((o) => o.category == activeCategory).toList();

  List<String> get categories =>
      all.map((o) => o.category).toSet().toList()..sort();

  ObjectivesState copyWith({
    Set<String>? selectedIds,
    String? activeCategory,
    bool clearCategory = false,
  }) =>
      ObjectivesState(
        all: all,
        selectedIds: selectedIds ?? this.selectedIds,
        activeCategory: clearCategory ? null : (activeCategory ?? this.activeCategory),
      );
}

class ObjectivesProvider extends ChangeNotifier {
  ObjectivesState _state = ObjectivesState(all: mockObjectives);

  ObjectivesState get state => _state;

  void toggle(String id) {
    final ids = Set<String>.from(_state.selectedIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    _state = _state.copyWith(selectedIds: ids);
    notifyListeners();
  }

  void setCategory(String? category) {
    _state = _state.copyWith(activeCategory: category, clearCategory: category == null);
    notifyListeners();
  }

  void clearSelection() {
    _state = _state.copyWith(selectedIds: {});
    notifyListeners();
  }
}
```

---

### 5.2 providers/route_provider.dart

Holds the active OSRM route result. Triggered when user taps "Build Route".

```dart
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/objective.dart';
import '../services/routing_service.dart';

class RouteState {
  final List<LatLng> polylinePoints;
  final double? totalDistanceKm;
  final double? totalDurationMin;
  final bool isLoading;
  final String? error;

  const RouteState({
    this.polylinePoints = const [],
    this.totalDistanceKm,
    this.totalDurationMin,
    this.isLoading = false,
    this.error,
  });

  bool get hasRoute => polylinePoints.isNotEmpty;

  RouteState copyWith({
    List<LatLng>? polylinePoints,
    double? totalDistanceKm,
    double? totalDurationMin,
    bool? isLoading,
    String? error,
  }) =>
      RouteState(
        polylinePoints: polylinePoints ?? this.polylinePoints,
        totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
        totalDurationMin: totalDurationMin ?? this.totalDurationMin,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class RouteProvider extends ChangeNotifier {
  RouteProvider(this._service);

  final RoutingService _service;
  RouteState _state = const RouteState();

  RouteState get state => _state;

  Future<void> buildRoute(List<Objective> stops) async {
    if (stops.length < 2) return;
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    try {
      final result = await _service.getRoute(stops);
      _state = _state.copyWith(
        polylinePoints: result.polylinePoints,
        totalDistanceKm: result.distanceKm,
        totalDurationMin: result.durationMin,
        isLoading: false,
      );
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  void clearRoute() {
    _state = const RouteState();
    notifyListeners();
  }
}
```

---

### 5.3 providers/auth_provider.dart

Auth is already implemented with `AuthProvider` + `OAuthAuthService`. Keep that flow and only extend it to redirect into the new map/list/detail screens after login. No mock auth or `shared_preferences` layer is needed.

---

## 6. Screen 1 — Map

### 6.1 screens/map_screen.dart

Note: This code sample uses Riverpod-style `ref.watch`/`ref.read`. In this codebase, replace with Provider equivalents (`context.watch<T>()`, `context.read<T>()`) and access provider state via `.state`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/objectives_provider.dart';
import '../../providers/route_provider.dart';
import '../components/landmark_marker.dart';
import '../components/route_bottom_panel.dart';

// Exposes the MapController so other parts of the app can call flyTo
final mapControllerProvider = Provider((ref) => MapController());

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const _bucharest = LatLng(44.4268, 26.1025);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objState = ref.watch(objectivesProvider);
    final routeState = ref.watch(routeProvider);
    final mapController = ref.watch(mapControllerProvider);

    return Scaffold(
      body: Stack(
        children: [
          // --- The map ---
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: _bucharest,
              initialZoom: 13.5,
              maxZoom: 18,
              minZoom: 5,
            ),
            children: [
              // OSM tile layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tourist_routes',
                tileProvider: CancellableNetworkTileProvider(),
              ),

              // Route polyline — drawn BELOW markers
              if (routeState.hasRoute)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeState.polylinePoints,
                      strokeWidth: 4.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),

              // Landmark markers
              MarkerLayer(
                markers: objState.all.map((obj) {
                  final isSelected = objState.selectedIds.contains(obj.id);
                  return Marker(
                    point: obj.latLng,
                    width: 40,
                    height: 40,
                    child: LandmarkMarker(
                      objective: obj,
                      isSelected: isSelected,
                      onTap: () => context.push('/detail/${obj.id}'),
                    ),
                  );
                }).toList(),
              ),

              // Required OSM attribution
              const RichAttributionWidget(
                attributions: [TextSourceAttribution('OpenStreetMap contributors')],
              ),
            ],
          ),

          // --- Loading overlay ---
          if (routeState.isLoading)
            const Center(child: CircularProgressIndicator()),

          // --- Error snackbar trigger ---
          if (routeState.error != null)
            _ErrorBanner(message: routeState.error!),

          // --- Selection count badge (top right) ---
          if (objState.selectedIds.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: SafeArea(
                child: _SelectionBadge(count: objState.selectedIds.length),
              ),
            ),
        ],
      ),

      // Route panel at the bottom
      bottomSheet: RouteBottomPanel(
        selectedCount: objState.selectedIds.length,
        routeState: routeState,
        onBuildRoute: () {
          final selected = objState.selected;
          if (selected.length < 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Select at least 2 landmarks to build a route.')),
            );
            return;
          }
          ref.read(routeProvider.notifier).buildRoute(selected);
        },
        onClear: () {
          ref.read(objectivesProvider.notifier).clearSelection();
          ref.read(routeProvider.notifier).clearRoute();
        },
      ),
    );
  }
}
```

---

### 6.2 components/landmark_marker.dart

Custom colored marker that changes appearance when selected.

```dart
import 'package:flutter/material.dart';
import '../../../models/objective.dart';

// Maps category names to icons
const _categoryIcons = {
  'Monument': Icons.account_balance,
  'Museum':   Icons.museum,
  'Park':     Icons.park,
  'Church':   Icons.church,
  'Square':   Icons.place,
};

class LandmarkMarker extends StatelessWidget {
  final Objective objective;
  final bool isSelected;
  final VoidCallback onTap;

  const LandmarkMarker({
    super.key,
    required this.objective,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.secondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Icon(
          _categoryIcons[objective.category] ?? Icons.place,
          color: isSelected ? Colors.white : color,
          size: 20,
        ),
      ),
    );
  }
}
```

---

### 6.3 components/route_bottom_panel.dart

Slide-up panel showing selected objectives and the Build Route button.

```dart
import 'package:flutter/material.dart';
import '../../../providers/route_provider.dart';

class RouteBottomPanel extends StatelessWidget {
  final int selectedCount;
  final RouteState routeState;
  final VoidCallback onBuildRoute;
  final VoidCallback onClear;

  const RouteBottomPanel({
    super.key,
    required this.selectedCount,
    required this.routeState,
    required this.onBuildRoute,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0 && !routeState.hasRoute) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),

          // Route stats (shown after route is built)
          if (routeState.hasRoute)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(icon: Icons.route, label: '${routeState.totalDistanceKm?.toStringAsFixed(1)} km'),
                  _Stat(icon: Icons.timer, label: '${routeState.totalDurationMin?.toStringAsFixed(0)} min'),
                  _Stat(icon: Icons.place, label: '$selectedCount stops'),
                ],
              ),
            ),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: routeState.isLoading ? null : onBuildRoute,
                  icon: routeState.isLoading
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.directions),
                  label: Text(routeState.hasRoute ? 'Rebuild Route' : 'Build Route ($selectedCount)'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(onPressed: onClear, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Stat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodyMedium),
    ],
  );
}
```

---

## 7. Screen 2 — Objectives List

### 7.1 screens/list_screen.dart

Note: Replace Riverpod calls with Provider equivalents as described above.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/objectives_provider.dart';
import '../components/objective_card.dart';
import '../components/category_filter_bar.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(objectivesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Landmarks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: CategoryFilterBar(
            categories: state.categories,
            selected: state.activeCategory,
            onSelected: (cat) => ref.read(objectivesProvider.notifier).setCategory(cat),
          ),
        ),
      ),
      body: Column(
        children: [
          // Selection count banner
          if (state.selectedIds.isNotEmpty)
            MaterialBanner(
              content: Text('${state.selectedIds.length} landmark(s) selected'),
              actions: [
                TextButton(
                  onPressed: () => context.go('/map'),
                  child: const Text('View on Map →'),
                ),
                TextButton(
                  onPressed: () => ref.read(objectivesProvider.notifier).clearSelection(),
                  child: const Text('Clear'),
                ),
              ],
            ),

          // Objectives list
          Expanded(
            child: state.filtered.isEmpty
                ? const Center(child: Text('No landmarks in this category.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: state.filtered.length,
                    itemBuilder: (context, index) {
                      final obj = state.filtered[index];
                      return ObjectiveCard(
                        objective: obj,
                        isSelected: state.selectedIds.contains(obj.id),
                        onToggle: () => ref.read(objectivesProvider.notifier).toggle(obj.id),
                        onTap: () => context.push('/detail/${obj.id}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
```

---

### 7.2 components/objective_card.dart

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/objective.dart';
import '../../../widgets/star_rating.dart';

class ObjectiveCard extends StatelessWidget {
  final Objective objective;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const ObjectiveCard({
    super.key,
    required this.objective,
    required this.isSelected,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 100,
              height: 100,
              child: CachedNetworkImage(
                imageUrl: objective.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category chip
                    Chip(
                      label: Text(objective.category, style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(height: 4),
                    Text(objective.name,
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    StarRating(rating: objective.rating),
                  ],
                ),
              ),
            ),

            // Checkbox
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Checkbox(
                value: isSelected,
                onChanged: (_) => onToggle(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### 7.3 components/category_filter_bar.dart

```dart
import 'package:flutter/material.dart';

class CategoryFilterBar extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final void Function(String?) onSelected;

  const CategoryFilterBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // "All" chip
          FilterChip(
            label: const Text('All'),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          // Category chips
          ...categories.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat),
              selected: selected == cat,
              onSelected: (_) => onSelected(cat),
            ),
          )),
        ],
      ),
    );
  }
}
```

---

## 8. Screen 3 — Objective Detail

### 8.1 screens/detail_screen.dart

Note: Replace Riverpod calls with Provider equivalents as described above.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/mock_objectives.dart';
import '../../providers/objectives_provider.dart';
import 'map_screen.dart'; // for mapControllerProvider
import '../../widgets/star_rating.dart';

class DetailScreen extends ConsumerWidget {
  final String objectiveId;
  const DetailScreen({super.key, required this.objectiveId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find objective from mock data
    final obj = mockObjectives.firstWhere((o) => o.id == objectiveId);
    final isSelected = ref.watch(
      objectivesProvider.select((s) => s.selectedIds.contains(objectiveId)),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image AppBar
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(obj.name, style: const TextStyle(shadows: [Shadow(blurRadius: 4)])),
              background: CachedNetworkImage(
                imageUrl: obj.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            actions: [
              // Add to route toggle
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilledButton.icon(
                  onPressed: () => ref.read(objectivesProvider.notifier).toggle(objectiveId),
                  icon: Icon(isSelected ? Icons.check : Icons.add),
                  label: Text(isSelected ? 'Added' : 'Add to Route'),
                  style: FilledButton.styleFrom(
                    backgroundColor: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category + Rating row
                  Row(
                    children: [
                      Chip(label: Text(obj.category)),
                      const SizedBox(width: 12),
                      StarRating(rating: obj.rating),
                      Text(' ${obj.rating}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info rows
                  _InfoRow(icon: Icons.location_on, text: obj.address),
                  _InfoRow(icon: Icons.schedule, text: obj.openingHours),
                  const SizedBox(height: 16),

                  // Long description
                  Text('About', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(obj.longDescription, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 24),

                  // Mini-map
                  Text('Location', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: obj.latLng,
                          initialZoom: 15,
                          // Disable interaction on detail mini-map
                          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                          MarkerLayer(markers: [
                            Marker(
                              point: obj.latLng,
                              child: const Icon(Icons.place, color: Colors.red, size: 32),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show on main map button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to map and fly to this point
                        context.go('/map');
                        // The map screen reads a "focusPoint" provider set here
                        ref.read(mapFocusProvider.notifier).state = obj.latLng;
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('Show on Map'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    ),
  );
}

// Simple provider to communicate focus point from Detail → Map
final mapFocusProvider = StateProvider<LatLng?>((ref) => null);
```

---

## 9. Screen 4 — Profile

### 9.1 screens/profile_screen.dart

Note: Replace Riverpod calls with Provider equivalents as described above.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/objectives_provider.dart';
import '../../providers/route_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          // Avatar section
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user?.name.substring(0, 1).toUpperCase() ?? '?',
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? 'Guest', style: Theme.of(context).textTheme.titleLarge),
                Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),

          const Divider(),

          // Settings section
          const _SectionHeader('Preferences'),
          _SettingsTile(icon: Icons.language,       title: 'Language',       subtitle: 'English'),
          _SettingsTile(icon: Icons.notifications,  title: 'Notifications',  subtitle: 'Enabled'),
          _SettingsTile(icon: Icons.dark_mode,      title: 'Theme',          subtitle: 'System default'),

          const Divider(),

          const _SectionHeader('App'),
          _SettingsTile(icon: Icons.info_outline,   title: 'About',          subtitle: 'v1.0.0'),
          _SettingsTile(icon: Icons.help_outline,   title: 'Help & Feedback', subtitle: ''),

          const Divider(),

          // Logout
          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () async {
                // Clear all state and redirect
                await ref.read(authProvider.notifier).logout();
                ref.read(objectivesProvider.notifier).clearSelection();
                ref.read(routeProvider.notifier).clearRoute();
                if (context.mounted) context.go('/map');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.grey)),
  );
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _SettingsTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
    trailing: const Icon(Icons.chevron_right),
    onTap: () {},
  );
}
```

---

## All done till here


## 10. OSRM Routing Service

### 10.1 services/routing_service.dart

OSRM is a free, open-source routing engine. The public demo server at `router.project-osrm.org` requires no API key and supports up to ~10 waypoints reliably. For production, self-host OSRM or use a paid alternative.

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/objective.dart';

class RouteResult {
  final List<LatLng> polylinePoints;
  final double distanceKm;
  final double durationMin;

  const RouteResult({
    required this.polylinePoints,
    required this.distanceKm,
    required this.durationMin,
  });
}

class RoutingService {
  static const _baseUrl = 'http://router.project-osrm.org/route/v1/driving';

  Future<RouteResult> getRoute(List<Objective> stops) async {
    if (stops.length < 2) throw ArgumentError('Need at least 2 stops');

    // OSRM expects: longitude,latitude (note: lng first!)
    final coords = stops.map((s) => '${s.lng},${s.lat}').join(';');

    final uri = Uri.parse(
      '$_baseUrl/$coords'
      '?overview=full'       // full polyline, not simplified
      '&geometries=geojson'  // GeoJSON format (easy to parse)
      '&steps=false'         // skip turn-by-turn for now
    );

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('OSRM returned ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['code'] != 'Ok') {
      throw Exception('OSRM error: ${data['message']}');
    }

    final route = (data['routes'] as List).first as Map<String, dynamic>;

    // Distance in meters → km
    final distanceKm = (route['distance'] as num) / 1000.0;

    // Duration in seconds → minutes
    final durationMin = (route['duration'] as num) / 60.0;

    // GeoJSON coordinates: [[lng, lat], [lng, lat], ...]
    // Note: GeoJSON is [longitude, latitude] — must flip for LatLng
    final geoJson = route['geometry'] as Map<String, dynamic>;
    final coordinates = (geoJson['coordinates'] as List)
        .map((c) => LatLng(
              (c[1] as num).toDouble(),  // latitude (second element)
              (c[0] as num).toDouble(),  // longitude (first element)
            ))
        .toList();

    return RouteResult(
      polylinePoints: coordinates,
      distanceKm: distanceKm,
      durationMin: durationMin,
    );
  }
}
```

**Key OSRM gotcha:** GeoJSON stores coordinates as `[longitude, latitude]` (opposite of LatLng). The flip on lines `c[1]` / `c[0]` above is essential — without it, your route will appear in the ocean.

**CORS note for web:** OSRM's public server allows CORS. If you self-host, configure your OSRM server with the `--cors` flag or an nginx proxy header.

---

## 11. Responsive Layout

### 11.1 Breakpoints

| Width | Layout |
|-------|--------|
| < 600px  | BottomNavigationBar · Map fills screen · Bottom sheet panel |
| 600–1024px | NavigationRail (left) · Map fills rest · Bottom sheet panel |
| > 1024px   | NavigationRail (left) · Map (center) · Side objectives panel (right, 320px) |

### 11.2 Wide-screen map layout (> 1024px)

On wide screens, replace the bottom sheet with a persistent side panel showing the objectives list next to the map. Implement this with a `LayoutBuilder` inside `MapScreen`:

```dart
LayoutBuilder(builder: (context, constraints) {
  if (constraints.maxWidth > 1024) {
    return Row(
      children: [
        Expanded(child: _mapWidget()),
        SizedBox(width: 320, child: _sideObjectivesPanel()),
      ],
    );
  }
  return Stack(children: [
    _mapWidget(),
    Positioned(bottom: 0, left: 0, right: 0, child: RouteBottomPanel(...)),
  ]);
})
```

### 11.3 Map controller — flyTo on Detail navigation

When the user taps "Show on Map" from the Detail screen, the map should fly to that point. Listen to `mapFocusProvider` inside `MapScreen`:

```dart
ref.listen(mapFocusProvider, (_, next) {
  if (next != null) {
    mapController.move(next, 15);
    ref.read(mapFocusProvider.notifier).state = null; // consume
  }
});
```

---

## 12. Polish & Edge Cases

### 12.1 Loading states

- Tile loading: `flutter_map_cancellable_tile_provider` handles this automatically
- Route loading: `CircularProgressIndicator` overlay on the map + disabled Build Route button
- Card images: Shimmer placeholder via `shimmer` package in `ObjectiveCard`

### 12.2 Edge cases to handle

| Scenario | Handling |
|----------|----------|
| < 2 objectives selected → Build Route | SnackBar: "Select at least 2 landmarks" |
| OSRM request fails (network off) | Error banner with retry button |
| `objectiveId` not found in mock data | `firstWhere` throws — wrap in `try/catch`, redirect to `/list` |
| User logs out mid-selection | `logout()` calls `clearSelection()` and `clearRoute()` |
| Viewport resize (web window drag) | `LayoutBuilder` reacts automatically — no extra handling needed |

### 12.3 Web-specific

```yaml
# web/index.html <head> — prevent double-tap zoom on mobile web
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
```

Run with CanvasKit renderer for best map performance:

```bash
flutter run -d chrome --web-renderer canvaskit
```

Build for release:

```bash
flutter build web --web-renderer canvaskit --release
```

### 12.4 OSM tile usage policy

OpenStreetMap's [Tile Usage Policy](https://operations.osmfoundation.org/policies/tiles/) requires:
1. A valid `User-Agent` in tile requests — handled by `userAgentPackageName` in `TileLayer`
2. Attribution visible on the map — handled by `RichAttributionWidget`
3. No heavy automated usage — for production apps with >50k daily users, host your own tiles (e.g. via [Protomaps](https://protomaps.com) or [Stadia Maps](https://stadiamaps.com))

---

## 13. Build Order Summary

Follow this order to always have a runnable app at each step.

| Step | What to build | Runnable result |
|------|---------------|-----------------|
| 1 | `pubspec.yaml` + `main.dart` + folder structure | Blank white screen |
| 2 | `Objective` model + `mock_objectives.dart` | Data layer ready |
| 3 | `go_router` + `AppShell` + empty screen stubs | Nav works, 4 screens visible |
| 4 | List Screen — display only, no selection | Scrollable card list with images |
| 5 | Detail Screen — read-only | Full landmark info + mini-map |
| 6 | `objectivesProvider` + checkboxes + filter bar | Selection state works across screens |
| 7 | Map Screen — OSM tiles + markers | Interactive map with pins |
| 8 | `RoutingService` + OSRM call + polyline layer | Route draws on map |
| 9 | `RouteBottomPanel` + stats + Build Route flow | Full user journey end-to-end |
| 10 | Profile Screen + mock auth + logout | Auth state clears correctly |
| 11 | Responsive layout pass (NavigationRail + wide map) | Looks correct at all widths |
| 12 | Polish — shimmer, animations, error handling | Production-ready demo |

---

## Quick Reference

```bash
# Run
flutter run -d chrome --web-renderer canvaskit

# Hot reload
r

# Build release
flutter build web --web-renderer canvaskit --release

# Run code gen (if using @riverpod annotations)
dart run build_runner watch --delete-conflicting-outputs
```

**OSRM public endpoint:**  
`http://router.project-osrm.org/route/v1/driving/{lng,lat;lng,lat}?overview=full&geometries=geojson`

**OSM tile URL:**  
`https://tile.openstreetmap.org/{z}/{x}/{y}.png`

---

*Plan version 1.0 — Flutter 3.x · Dart 3.x · flutter_map 6.x · Riverpod 2.x*

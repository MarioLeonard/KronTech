import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../components/app_shell.dart';
import '../components/objective_card.dart';
import '../components/route_bottom_panel.dart';
import '../models/objective.dart';
import '../providers/map_focus_provider.dart';
import '../providers/objectives_provider.dart';
import '../providers/route_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  static const _bucharest = LatLng(44.4268, 26.1025);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  MapFocusProvider? _focusProvider;
  String? _activeObjectiveId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<MapFocusProvider>();
    if (_focusProvider != provider) {
      _focusProvider?.removeListener(_handleFocusChanged);
      _focusProvider = provider;
      _focusProvider?.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    _focusProvider?.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleFocusChanged() {
    final focus = _focusProvider?.focus;
    if (focus == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(focus, 15);
      _focusProvider?.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final objectivesState = context.watch<ObjectivesProvider>().state;
    final routeState = context.watch<RouteProvider>().state;
    final isWide = MediaQuery.of(context).size.width > 1024;
    final selectedObjective = _activeObjectiveId == null
        ? null
        : objectivesState.all.firstWhere(
            (objective) => objective.id == _activeObjectiveId,
            orElse: () => objectivesState.all.first,
          );
    final detailsBottomOffset = isWide ? 16.0 : 160.0;

    return Scaffold(
      body: AppShell(
        child: isWide
            ? Row(
                children: [
                  Expanded(
                    child: _MapStack(
                      mapController: _mapController,
                      objectivesState: objectivesState,
                      routeState: routeState,
                      selectedObjective: selectedObjective,
                      detailsBottomOffset: detailsBottomOffset,
                      onCloseDetails: () => setState(() {
                        _activeObjectiveId = null;
                      }),
                      onSelectObjective: (id) => setState(() {
                        _activeObjectiveId = id;
                      }),
                    ),
                  ),
                  SizedBox(
                    width: 320,
                    child: _ObjectivesSidePanel(
                      objectivesState: objectivesState,
                      routeState: routeState,
                    ),
                  ),
                ],
              )
            : _MapStack(
                mapController: _mapController,
                objectivesState: objectivesState,
                routeState: routeState,
                selectedObjective: selectedObjective,
                detailsBottomOffset: detailsBottomOffset,
                onCloseDetails: () => setState(() {
                  _activeObjectiveId = null;
                }),
                onSelectObjective: (id) => setState(() {
                  _activeObjectiveId = id;
                }),
              ),
      ),
      bottomSheet: isWide
          ? null
          : RouteBottomPanel(
              selectedCount: objectivesState.selectedIds.length,
              routeState: routeState,
              onBuildRoute: () {
                final selected = objectivesState.selected;
                if (selected.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Select at least 2 landmarks to build a route.'),
                    ),
                  );
                  return;
                }
                context.read<RouteProvider>().buildRoute(selected);
              },
              onClear: () {
                context.read<ObjectivesProvider>().clearSelection();
                context.read<RouteProvider>().clearRoute();
              },
            ),
    );
  }
}

class _MapStack extends StatelessWidget {
  const _MapStack({
    required this.mapController,
    required this.objectivesState,
    required this.routeState,
    required this.selectedObjective,
    required this.detailsBottomOffset,
    required this.onCloseDetails,
    required this.onSelectObjective,
  });

  final MapController mapController;
  final ObjectivesState objectivesState;
  final RouteState routeState;
  final Objective? selectedObjective;
  final double detailsBottomOffset;
  final VoidCallback onCloseDetails;
  final void Function(String id) onSelectObjective;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: mapController,
          options: const MapOptions(
            initialCenter: MapScreen._bucharest,
            initialZoom: 13.5,
            maxZoom: 18,
            minZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.krontech.app',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            if (routeState.hasRoute)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routeState.polylinePoints,
                    strokeWidth: 4,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            MarkerLayer(
              markers: objectivesState.all.map((objective) {
                final isSelected =
                    objectivesState.selectedIds.contains(objective.id);
                return Marker(
                  point: objective.latLng,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () {
                      onSelectObjective(objective.id);
                      context.read<ObjectivesProvider>().toggle(objective.id);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.place,
                        size: 20,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const RichAttributionWidget(
              attributions: [TextSourceAttribution('OpenStreetMap contributors')],
            ),
          ],
        ),
        if (routeState.error != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          routeState.error!,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        if (objectivesState.selectedIds.isNotEmpty)
          Positioned(
            top: 16,
            right: 16,
            child: SafeArea(
              child: _SelectionBadge(count: objectivesState.selectedIds.length),
            ),
          ),
        if (selectedObjective != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: detailsBottomOffset,
            child: _ObjectiveDetailsCard(
              objective: selectedObjective!,
              onClose: onCloseDetails,
            ),
          ),
      ],
    );
  }
}

class _ObjectiveDetailsCard extends StatelessWidget {
  const _ObjectiveDetailsCard({
    required this.objective,
    required this.onClose,
  });

  final Objective objective;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: objective.imageUrl,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) => Container(
                  width: 64,
                  height: 64,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    objective.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    objective.shortDescription,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Close',
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _ObjectivesSidePanel extends StatelessWidget {
  const _ObjectivesSidePanel({
    required this.objectivesState,
    required this.routeState,
  });

  final ObjectivesState objectivesState;
  final RouteState routeState;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          left: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(
                  'Landmarks',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text('${objectivesState.selectedIds.length} selected'),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: objectivesState.all.length,
              itemBuilder: (context, index) {
                final objective = objectivesState.all[index];
                return ObjectiveCard(
                  objective: objective,
                  isSelected: objectivesState.selectedIds.contains(objective.id),
                  onToggle: () =>
                      context.read<ObjectivesProvider>().toggle(objective.id),
                  onTap: () =>
                      context.read<ObjectivesProvider>().toggle(objective.id),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: routeState.isLoading
                        ? null
                        : () {
                            final selected = objectivesState.selected;
                            if (selected.length < 2) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Select at least 2 landmarks to build a route.',
                                  ),
                                ),
                              );
                              return;
                            }
                            context.read<RouteProvider>().buildRoute(selected);
                          },
                    icon: routeState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.directions),
                    label: Text(
                      routeState.hasRoute
                          ? 'Rebuild Route'
                          : 'Build Route (${objectivesState.selectedIds.length})',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    context.read<ObjectivesProvider>().clearSelection();
                    context.read<RouteProvider>().clearRoute();
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionBadge extends StatelessWidget {
  const _SelectionBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        '$count selected',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

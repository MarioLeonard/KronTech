import 'package:flutter/material.dart';
import '../providers/route_provider.dart';

class RouteBottomPanel extends StatelessWidget {
  const RouteBottomPanel({
    super.key,
    required this.selectedCount,
    required this.routeState,
    required this.onBuildRoute,
    required this.onClear,
  });

  final int selectedCount;
  final RouteState routeState;
  final VoidCallback onBuildRoute;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    if (selectedCount == 0 && !routeState.hasRoute) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          if (routeState.hasRoute)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _Stat(
                    icon: Icons.route,
                    label:
                        '${routeState.totalDistanceKm?.toStringAsFixed(1) ?? '-'} km',
                  ),
                  _Stat(
                    icon: Icons.timer,
                    label:
                        '${routeState.totalDurationMin?.toStringAsFixed(0) ?? '-'} min',
                  ),
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
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.directions),
                  label: Text(
                    routeState.hasRoute
                        ? 'Rebuild Route'
                        : 'Build Route ($selectedCount)',
                  ),
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
  const _Stat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

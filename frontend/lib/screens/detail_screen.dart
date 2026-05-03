import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../components/star_rating.dart';
import '../providers/map_focus_provider.dart';
import '../providers/objectives_provider.dart';

class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.objectiveId});

  final String objectiveId;

  @override
  Widget build(BuildContext context) {
    final objectives = context.watch<ObjectivesProvider>().state.all;
    final objective = objectives.firstWhere(
      (item) => item.id == objectiveId,
      orElse: () => objectives.first,
    );
    final isSelected = context
        .watch<ObjectivesProvider>()
        .state
        .selectedIds
        .contains(objectiveId);

    return Scaffold(
      appBar: AppBar(title: Text(objective.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: objective.imageUrl,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[200]),
              errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(label: Text(objective.category)),
              const SizedBox(width: 12),
              StarRating(rating: objective.rating),
              Text(' ${objective.rating.toStringAsFixed(1)}'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            objective.shortDescription,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(objective.longDescription),
          const SizedBox(height: 16),
          _InfoRow(icon: Icons.location_on, text: objective.address),
          _InfoRow(icon: Icons.schedule, text: objective.openingHours),
          const SizedBox(height: 16),
          Text('Location', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 200,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: objective.latLng,
                  initialZoom: 15,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.none),
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: objective.latLng,
                        child: const Icon(
                          Icons.place,
                          color: Colors.red,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.read<ObjectivesProvider>().toggle(
                  objectiveId,
                ),
            icon: Icon(isSelected ? Icons.check : Icons.add),
            label: Text(isSelected ? 'Added to Route' : 'Add to Route'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              context.read<MapFocusProvider>().setFocus(
                    objective.latLng,
                  );
              context.go('/map');
            },
            icon: const Icon(Icons.map),
            label: const Text('Show on Map'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

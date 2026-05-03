import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/objective.dart';
import 'star_rating.dart';

class ObjectiveCard extends StatelessWidget {
  const ObjectiveCard({
    super.key,
    required this.objective,
    required this.isSelected,
    required this.onToggle,
    required this.onTap,
  });

  final Objective objective;
  final bool isSelected;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 110,
              height: 110,
              child: CachedNetworkImage(
                imageUrl: objective.imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[200]),
                errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Chip(
                      label: Text(objective.category,
                          style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      objective.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    StarRating(rating: objective.rating),
                  ],
                ),
              ),
            ),
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

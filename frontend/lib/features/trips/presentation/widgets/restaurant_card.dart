import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/dining_option.dart';
import 'package:url_launcher/url_launcher.dart';

part 'restaurant_meta.dart';
part 'restaurant_meta_badge.dart';
part 'restaurant_note.dart';
part 'maps_button.dart';

class RestaurantCard extends StatelessWidget {
  const RestaurantCard({
    required this.option,
    required this.currency,
    super.key,
  });

  final DiningOption option;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.1),
            const Color(0xFF0E5A90).withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 12),
            _RestaurantMeta(
              cuisine: option.cuisine,
              recommendedFor: option.recommendedFor,
              estimatedMealCost: option.estimatedMealCost,
              currency: currency,
            ),
            if (option.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              _RestaurantNote(note: option.note),
            ],
            const SizedBox(height: 14),
            _MapsButton(option: option),
          ],
        ),
      ),
    );
  }
}

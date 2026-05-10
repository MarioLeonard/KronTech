import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/dining_option.dart';

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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.restaurant_rounded,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${option.city} · ${option.area}'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(option.cuisine)),
                Chip(label: Text(option.recommendedFor)),
                Chip(
                  avatar: const Icon(Icons.payments_rounded, size: 16),
                  label: Text('${_number(option.estimatedMealCost)} $currency'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(option.note, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

String _number(num value) {
  if (value == 0) {
    return 'estimare indisponibila';
  }
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

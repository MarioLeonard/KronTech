import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/stay_option.dart';

class AccommodationCard extends StatelessWidget {
  const AccommodationCard({
    required this.option,
    required this.currency,
    super.key,
  });

  final StayOption option;
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
                Icon(Icons.hotel_rounded, color: theme.colorScheme.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(option.name, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 4),
                      Text('${option.city} · ${option.area} · ${option.type}'),
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
                Chip(
                  avatar: const Icon(Icons.payments_rounded, size: 16),
                  label: Text(
                    '${_number(option.estimatedNightlyCost)} $currency/noapte',
                  ),
                ),
                Chip(label: Text(option.source)),
                if (option.isSearchSuggestion)
                  const Chip(
                    label: Text('Sugestie, nu disponibilitate verificata'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(option.note, style: theme.textTheme.bodySmall),
            if (option.bookingSearchUrl.isNotEmpty ||
                option.airbnbSearchUrl.isNotEmpty) ...[
              const SizedBox(height: 10),
              if (option.bookingSearchUrl.isNotEmpty)
                SelectableText('Booking: ${option.bookingSearchUrl}'),
              if (option.airbnbSearchUrl.isNotEmpty)
                SelectableText('Airbnb: ${option.airbnbSearchUrl}'),
            ],
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

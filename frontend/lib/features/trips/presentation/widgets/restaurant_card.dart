import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/dining_option.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _RestaurantMeta extends StatelessWidget {
  const _RestaurantMeta({
    required this.cuisine,
    required this.recommendedFor,
    required this.estimatedMealCost,
    required this.currency,
  });

  final String cuisine;
  final String recommendedFor;
  final num estimatedMealCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaBadge(icon: Icons.restaurant_menu_rounded, label: cuisine),
        _MetaBadge(
          icon: Icons.schedule_rounded,
          label: _formatMeal(recommendedFor),
        ),
        _MetaBadge(
          icon: Icons.payments_rounded,
          label: '${_number(estimatedMealCost)} $currency/person',
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.62)),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.68),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantNote extends StatelessWidget {
  const _RestaurantNote({required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.info_outline_rounded,
            size: 17,
            color: Colors.white.withValues(alpha: 0.46),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            note,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.66),
              height: 1.48,
            ),
          ),
        ),
      ],
    );
  }
}

class _MapsButton extends StatelessWidget {
  const _MapsButton({required this.option});

  final DiningOption option;

  @override
  Widget build(BuildContext context) {
    final query = [
      option.name,
      if (option.area.isNotEmpty && option.area != 'Area unspecified')
        option.area,
      if (option.city.isNotEmpty && option.city != 'City unspecified')
        option.city,
    ].join(' ');

    return Tooltip(
      message: 'Open in Google Maps',
      child: Semantics(
        button: true,
        label: 'Open ${option.name} in Google Maps',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openMaps(query),
            child: Container(
              height: 46,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A73E8),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1A73E8).withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 19),
                  SizedBox(width: 8),
                  Text(
                    'Open Maps',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _formatMeal(String value) {
  final normalized = value.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return 'Meal';
  }
  return normalized[0].toUpperCase() + normalized.substring(1);
}

Future<void> _openMaps(String query) async {
  final uri = Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': query,
  });
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

String _number(num value) {
  if (value == 0) {
    return 'estimate unavailable';
  }
  if (value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

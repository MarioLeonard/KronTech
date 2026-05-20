import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/features/trips/domain/stay_option.dart';
import 'package:url_launcher/url_launcher.dart';

part 'accommodation_meta.dart';
part 'meta_badge.dart';
part 'accommodation_note.dart';
part 'accommodation_link_actions.dart';
part 'brand_link_button.dart';

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
    final hasLinks =
        option.bookingSearchUrl.isNotEmpty || option.airbnbSearchUrl.isNotEmpty;

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
            _AccommodationMeta(
              type: option.type,
              nightlyCost: option.estimatedNightlyCost,
              currency: currency,
            ),
            if (option.note.isNotEmpty) ...[
              const SizedBox(height: 12),
              _AccommodationNote(note: option.note),
            ],
            if (hasLinks) ...[
              const SizedBox(height: 14),
              _AccommodationLinkActions(
                bookingUrl: option.bookingSearchUrl,
                airbnbUrl: option.airbnbSearchUrl,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

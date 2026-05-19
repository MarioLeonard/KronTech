import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/features/trips/domain/stay_option.dart';
import 'package:url_launcher/url_launcher.dart';

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

class _AccommodationMeta extends StatelessWidget {
  const _AccommodationMeta({
    required this.type,
    required this.nightlyCost,
    required this.currency,
  });

  final String type;
  final num nightlyCost;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaBadge(icon: Icons.apartment_rounded, label: _formatType(type)),
        _MetaBadge(
          icon: Icons.payments_rounded,
          label: '${_number(nightlyCost)} $currency/night',
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

class _AccommodationNote extends StatelessWidget {
  const _AccommodationNote({required this.note});

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

class _AccommodationLinkActions extends StatelessWidget {
  const _AccommodationLinkActions({
    required this.bookingUrl,
    required this.airbnbUrl,
  });

  final String bookingUrl;
  final String airbnbUrl;

  @override
  Widget build(BuildContext context) {
    final buttons = [
      if (bookingUrl.isNotEmpty) _BrandLinkButton.booking(url: bookingUrl),
      if (airbnbUrl.isNotEmpty) _BrandLinkButton.airbnb(url: airbnbUrl),
    ];

    if (buttons.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 330 || buttons.length == 1) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < buttons.length; index++) ...[
                buttons[index],
                if (index != buttons.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < buttons.length; index++) ...[
              Expanded(child: buttons[index]),
              if (index != buttons.length - 1) const SizedBox(width: 10),
            ],
          ],
        );
      },
    );
  }
}

class _BrandLinkButton extends StatelessWidget {
  const _BrandLinkButton._({
    required this.url,
    required this.label,
    required this.color,
    required this.logoAsset,
    required this.logoWidth,
    required this.logoHeight,
    required this.logoScale,
  });

  factory _BrandLinkButton.booking({required String url}) {
    return _BrandLinkButton._(
      url: url,
      label: 'Booking.com',
      color: const Color(0xFF003B95),
      logoAsset: 'assets/icons/booking.svg',
      logoWidth: 92,
      logoHeight: 16,
      logoScale: 0.92,
    );
  }

  factory _BrandLinkButton.airbnb({required String url}) {
    return _BrandLinkButton._(
      url: url,
      label: 'Airbnb',
      color: const Color(0xFFFF385C),
      logoAsset: 'assets/icons/airbnb.svg',
      logoWidth: 118,
      logoHeight: 32,
      logoScale: 1.18,
    );
  }

  final String url;
  final String label;
  final Color color;
  final String logoAsset;
  final double logoWidth;
  final double logoHeight;
  final double logoScale;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Open $label search',
      child: Semantics(
        button: true,
        label: 'Open $label search',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _openUrl(url),
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: logoScale,
                    child: SvgPicture.asset(
                      logoAsset,
                      width: logoWidth,
                      height: logoHeight,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
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

String _formatType(String value) {
  final normalized = value.trim().replaceAll('_', ' ');
  if (normalized.isEmpty) {
    return 'Other';
  }
  return normalized[0].toUpperCase() + normalized.substring(1);
}

Future<void> _openUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null) {
    return;
  }
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

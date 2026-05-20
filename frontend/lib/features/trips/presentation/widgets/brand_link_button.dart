part of 'accommodation_card.dart';

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

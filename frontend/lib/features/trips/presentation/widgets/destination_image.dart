part of 'trip_summary_card.dart';

class _DestinationImage extends StatelessWidget {
  const _DestinationImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url.isEmpty) {
      return _ImageFallback(colorScheme: colorScheme);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _ImageFallback(colorScheme: colorScheme);
      },
    );
  }
}

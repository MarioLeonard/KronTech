part of '../screens/my_trips_screen.dart';

class _TripPreviewImage extends StatelessWidget {
  const _TripPreviewImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (url.isEmpty) {
      return _TripPreviewFallback(colorScheme: colorScheme);
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _TripPreviewFallback(colorScheme: colorScheme);
      },
    );
  }
}

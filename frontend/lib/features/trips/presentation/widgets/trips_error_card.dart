part of '../screens/my_trips_screen.dart';

class _TripsErrorCard extends StatelessWidget {
  const _TripsErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: const Text('Retry'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.orange.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

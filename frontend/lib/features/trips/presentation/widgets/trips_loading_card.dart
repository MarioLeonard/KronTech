part of '../screens/my_trips_screen.dart';

class _TripsLoadingCard extends StatelessWidget {
  const _TripsLoadingCard();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      color: Colors.white,
      opacity: 0.05,
      blur: 12,
      borderRadius: 24,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                'Loading saved trips...',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

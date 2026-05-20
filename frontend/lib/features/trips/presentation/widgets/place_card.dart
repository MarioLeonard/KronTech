part of '../screens/trip_details_screen.dart';

class _PlaceCard extends StatelessWidget {
  const _PlaceCard({required this.place, required this.onVisitedChanged});

  final _PlaceItem place;
  final ValueChanged<bool> onVisitedChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.11)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _VisitedCheckbox(
            isVisited: place.isVisited,
            onChanged: onVisitedChanged,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: place.isVisited ? 0.68 : 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.18,
                      decoration: place.isVisited
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: Colors.white.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.64),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    place.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.48,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

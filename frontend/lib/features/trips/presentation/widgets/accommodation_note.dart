part of 'accommodation_card.dart';

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

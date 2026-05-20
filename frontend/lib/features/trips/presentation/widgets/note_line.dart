part of '../screens/trip_details_screen.dart';

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text, required this.index});

  final String text;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFDE68A),
      const Color(0xFFF0ABFC),
      const Color(0xFFFCA5A5),
    ];
    final color = colors[index % colors.length];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.24)),
            ),
            child: Icon(Icons.priority_high_rounded, color: color, size: 15),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

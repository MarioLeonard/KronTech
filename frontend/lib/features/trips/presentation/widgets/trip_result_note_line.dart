part of 'trip_result_view.dart';

class _NoteLine extends StatelessWidget {
  const _NoteLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '• $text',
        style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
      ),
    );
  }
}

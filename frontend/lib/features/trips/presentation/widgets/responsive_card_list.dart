part of '../screens/trip_details_screen.dart';

class _ResponsiveCardList extends StatelessWidget {
  const _ResponsiveCardList({
    required this.children,
    this.maxColumns = 2,
    this.minCardWidth = 380,
  });

  final List<Widget> children;
  final int maxColumns;
  final double minCardWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = constraints.maxWidth >= 900 ? 14.0 : 12.0;
        final rawColumns = ((constraints.maxWidth + gap) / (minCardWidth + gap))
            .floor();
        final columns = rawColumns.clamp(1, maxColumns).toInt();
        final width = (constraints.maxWidth - (gap * (columns - 1))) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: width, child: child),
          ],
        );
      },
    );
  }
}

part of '../screens/trip_details_screen.dart';

class _StaggeredSectionItem extends StatefulWidget {
  const _StaggeredSectionItem({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<_StaggeredSectionItem> createState() => _StaggeredSectionItemState();
}

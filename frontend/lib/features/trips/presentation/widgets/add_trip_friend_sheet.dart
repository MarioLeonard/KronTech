part of '../screens/trip_details_screen.dart';

class _AddTripFriendSheet extends StatefulWidget {
  const _AddTripFriendSheet({required this.trip, required this.onAddFriend});

  final SavedTrip trip;
  final Future<bool> Function(FriendUser friend) onAddFriend;

  @override
  State<_AddTripFriendSheet> createState() => _AddTripFriendSheetState();
}

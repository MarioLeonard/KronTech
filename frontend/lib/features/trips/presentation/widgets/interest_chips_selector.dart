import 'package:flutter/material.dart';
import 'package:frontend/features/trips/domain/trip_interest.dart';

class InterestChipsSelector extends StatelessWidget {
  const InterestChipsSelector({
    required this.selected,
    required this.onChanged,
    required this.enabled,
    super.key,
  });

  final Set<TripInterest> selected;
  final ValueChanged<Set<TripInterest>> onChanged;
  final bool enabled;

  void _toggle(TripInterest interest) {
    final next = {...selected};
    if (next.contains(interest)) {
      next.remove(interest);
    } else {
      next.add(interest);
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TripInterest.values
          .map(
            (interest) => FilterChip(
              label: Text(interest.label),
              selected: selected.contains(interest),
              onSelected: enabled ? (_) => _toggle(interest) : null,
            ),
          )
          .toList(),
    );
  }
}

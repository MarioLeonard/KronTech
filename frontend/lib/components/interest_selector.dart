part of 'checkbox.dart';

class InterestSelector extends StatefulWidget {
  final String label;
  final List<String> availableInterests;
  final List<String> selectedInterests;
  final ValueChanged<List<String>> onChanged;

  const InterestSelector({
    super.key,
    required this.label,
    required this.availableInterests,
    required this.selectedInterests,
    required this.onChanged,
  });

  @override
  State<InterestSelector> createState() => _InterestSelectorState();
}

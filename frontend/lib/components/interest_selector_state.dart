part of 'checkbox.dart';

class _InterestSelectorState extends State<InterestSelector> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedInterests);
  }

  void _toggleInterest(String interest) {
    setState(() {
      if (_selected.contains(interest)) {
        _selected.remove(interest);
      } else {
        _selected.add(interest);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableInterests.map((interest) {
            final isSelected = _selected.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              onSelected: (_) => _toggleInterest(interest),
              checkmarkColor: Colors.white,
              backgroundColor: Colors.grey.shade200,
              selectedColor: Colors.blue.shade100,
              side: const BorderSide(color: Colors.white),
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue : Colors.black87,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

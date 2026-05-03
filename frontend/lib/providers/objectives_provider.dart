import 'package:flutter/material.dart';
import '../models/objective.dart';
import '../utils/mock_objectives.dart';

class ObjectivesState {
  const ObjectivesState({
    required this.all,
    this.selectedIds = const {},
    this.activeCategory,
  });

  final List<Objective> all;
  final Set<String> selectedIds;
  final String? activeCategory;

  List<Objective> get selected =>
      all.where((o) => selectedIds.contains(o.id)).toList();

  List<Objective> get filtered => activeCategory == null
      ? all
      : all.where((o) => o.category == activeCategory).toList();

  List<String> get categories =>
      all.map((o) => o.category).toSet().toList()..sort();

  ObjectivesState copyWith({
    Set<String>? selectedIds,
    String? activeCategory,
    bool clearCategory = false,
  }) {
    return ObjectivesState(
      all: all,
      selectedIds: selectedIds ?? this.selectedIds,
      activeCategory: clearCategory ? null : (activeCategory ?? this.activeCategory),
    );
  }
}

class ObjectivesProvider extends ChangeNotifier {
  ObjectivesState _state = ObjectivesState(all: mockObjectives);

  ObjectivesState get state => _state;

  void toggle(String id) {
    final ids = Set<String>.from(_state.selectedIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    _state = _state.copyWith(selectedIds: ids);
    notifyListeners();
  }

  void setCategory(String? category) {
    _state = _state.copyWith(
      activeCategory: category,
      clearCategory: category == null,
    );
    notifyListeners();
  }

  void clearSelection() {
    _state = _state.copyWith(selectedIds: {});
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/app_shell.dart';
import '../components/category_filter_bar.dart';
import '../components/objective_card.dart';
import '../providers/objectives_provider.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ObjectivesProvider>().state;

    return Scaffold(
      body: AppShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Landmarks',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            CategoryFilterBar(
              categories: state.categories,
              selected: state.activeCategory,
              onSelected: (category) =>
                  context.read<ObjectivesProvider>().setCategory(category),
            ),
            if (state.selectedIds.isNotEmpty)
              MaterialBanner(
                content: Text('${state.selectedIds.length} selected'),
                actions: [
                  TextButton(
                    onPressed: () => context.go('/map'),
                    child: const Text('View on Map'),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.read<ObjectivesProvider>().clearSelection(),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            Expanded(
              child: state.filtered.isEmpty
                  ? const Center(
                      child: Text('No landmarks in this category.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: state.filtered.length,
                      itemBuilder: (context, index) {
                        final objective = state.filtered[index];
                        return ObjectiveCard(
                          objective: objective,
                          isSelected:
                              state.selectedIds.contains(objective.id),
                          onToggle: () =>
                              context.read<ObjectivesProvider>().toggle(
                                    objective.id,
                                  ),
                          onTap: () => context.push('/detail/${objective.id}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

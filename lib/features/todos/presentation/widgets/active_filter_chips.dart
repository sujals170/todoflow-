import 'package:flutter/material.dart';
import '../../domain/todo_filter.dart';

class ActiveFilterChips extends StatelessWidget {
  final TodoFilter filter;
  final VoidCallback onClearPriority;
  final VoidCallback onClearCategory;
  final VoidCallback onClearDueDate;
  final VoidCallback onClearSearch;
  final VoidCallback onClearAll;

  const ActiveFilterChips({
    super.key,
    required this.filter,
    required this.onClearPriority,
    required this.onClearCategory,
    required this.onClearDueDate,
    required this.onClearSearch,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    if (!filter.hasActiveCustomFilters) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Wrap(
        spacing: 6,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (filter.priority != null)
            InputChip(
              label: Text('Priority: ${filter.priority!.label}'),
              onDeleted: onClearPriority,
              visualDensity: VisualDensity.compact,
            ),
          if (filter.category != null)
            InputChip(
              label: Text('#${filter.category}'),
              onDeleted: onClearCategory,
              visualDensity: VisualDensity.compact,
            ),
          if (filter.dueDateFilter != DueDateFilter.all)
            InputChip(
              label: Text('Due: ${filter.dueDateFilter.label}'),
              onDeleted: onClearDueDate,
              visualDensity: VisualDensity.compact,
            ),
          if (filter.searchQuery.isNotEmpty)
            InputChip(
              label: Text('Search: "${filter.searchQuery}"'),
              onDeleted: onClearSearch,
              visualDensity: VisualDensity.compact,
            ),
          TextButton(
            onPressed: onClearAll,
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Clear All', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

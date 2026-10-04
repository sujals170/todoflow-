import 'package:flutter/material.dart';
import '../../../../models/todo_priority.dart';
import '../../domain/todo_filter.dart';

class FilterBottomSheet extends StatefulWidget {
  final TodoFilter initialFilter;
  final List<String> availableCategories;
  final ValueChanged<TodoFilter> onApply;
  final VoidCallback onReset;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.availableCategories,
    required this.onApply,
    required this.onReset,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late TodoPriority? _selectedPriority;
  late String? _selectedCategory;
  late DueDateFilter _selectedDueDateFilter;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialFilter.priority;
    _selectedCategory = widget.initialFilter.category;
    _selectedDueDateFilter = widget.initialFilter.dueDateFilter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Tasks',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedPriority = null;
                        _selectedCategory = null;
                        _selectedDueDateFilter = DueDateFilter.all;
                      });
                      widget.onReset();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Reset All'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Priority Section
              Text(
                'Priority',
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All Priorities'),
                    selected: _selectedPriority == null,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPriority = null;
                        });
                      }
                    },
                  ),
                  ...TodoPriority.values.map(
                    (p) => ChoiceChip(
                      label: Text(p.label),
                      selected: _selectedPriority == p,
                      onSelected: (selected) {
                        setState(() {
                          _selectedPriority = selected ? p : null;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Due Date Section
              Text(
                'Due Date',
                style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: DueDateFilter.values.map(
                  (d) => ChoiceChip(
                    label: Text(d.label),
                    selected: _selectedDueDateFilter == d,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedDueDateFilter = d;
                        });
                      }
                    },
                  ),
                ).toList(),
              ),
              const SizedBox(height: 20),
              // Category Section
              if (widget.availableCategories.isNotEmpty) ...[
                Text(
                  'Category',
                  style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('All Categories'),
                      selected: _selectedCategory == null,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedCategory = null;
                          });
                        }
                      },
                    ),
                    ...widget.availableCategories.map(
                      (c) => ChoiceChip(
                        label: Text('#$c'),
                        selected: _selectedCategory == c,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? c : null;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: () {
                  final updated = widget.initialFilter.copyWith(
                    priority: _selectedPriority,
                    clearPriority: _selectedPriority == null,
                    category: _selectedCategory,
                    clearCategory: _selectedCategory == null,
                    dueDateFilter: _selectedDueDateFilter,
                  );
                  widget.onApply(updated);
                  Navigator.of(context).pop();
                },
                child: const Text('Apply Filters'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

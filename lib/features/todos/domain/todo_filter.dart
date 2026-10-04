import 'package:equatable/equatable.dart';
import '../../../models/todo_priority.dart';

enum TodoTabFilter {
  all('All'),
  today('Today'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const TodoTabFilter(this.label);
}

enum DueDateFilter {
  all('Any Time'),
  overdue('Overdue'),
  today('Due Today'),
  thisWeek('Due This Week'),
  noDueDate('No Due Date');

  final String label;
  const DueDateFilter(this.label);
}

class TodoFilter extends Equatable {
  final TodoTabFilter tab;
  final TodoPriority? priority;
  final String? category;
  final DueDateFilter dueDateFilter;
  final String searchQuery;

  const TodoFilter({
    this.tab = TodoTabFilter.all,
    this.priority,
    this.category,
    this.dueDateFilter = DueDateFilter.all,
    this.searchQuery = '',
  });

  TodoFilter copyWith({
    TodoTabFilter? tab,
    TodoPriority? priority,
    bool clearPriority = false,
    String? category,
    bool clearCategory = false,
    DueDateFilter? dueDateFilter,
    String? searchQuery,
  }) {
    return TodoFilter(
      tab: tab ?? this.tab,
      priority: clearPriority ? null : (priority ?? this.priority),
      category: clearCategory ? null : (category ?? this.category),
      dueDateFilter: dueDateFilter ?? this.dueDateFilter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  bool get hasActiveCustomFilters =>
      priority != null ||
      category != null ||
      dueDateFilter != DueDateFilter.all ||
      searchQuery.isNotEmpty;

  bool get hasActiveFilters =>
      tab != TodoTabFilter.all || hasActiveCustomFilters;

  @override
  List<Object?> get props => [tab, priority, category, dueDateFilter, searchQuery];
}

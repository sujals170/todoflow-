import 'package:equatable/equatable.dart';
import '../../../repositories/todo_repository.dart';

class TodoSort extends Equatable {
  final TodoSortBy sortBy;
  final bool ascending;

  const TodoSort({
    this.sortBy = TodoSortBy.createdAt,
    this.ascending = false,
  });

  TodoSort copyWith({
    TodoSortBy? sortBy,
    bool? ascending,
  }) {
    return TodoSort(
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  String get label {
    switch (sortBy) {
      case TodoSortBy.createdAt:
        return ascending ? 'Oldest first' : 'Newest first';
      case TodoSortBy.dueDate:
        return ascending ? 'Due date (Soonest)' : 'Due date (Latest)';
      case TodoSortBy.priority:
        return ascending ? 'Priority (Low to High)' : 'Priority (High to Low)';
      case TodoSortBy.title:
        return ascending ? 'Alphabetical (A-Z)' : 'Alphabetical (Z-A)';
    }
  }

  @override
  List<Object?> get props => [sortBy, ascending];
}

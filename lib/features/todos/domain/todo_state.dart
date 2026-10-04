import 'package:equatable/equatable.dart';
import '../../../models/todo_item.dart';
import 'todo_filter.dart';
import 'todo_sort.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<TodoItem> allTodos;
  final List<TodoItem> filteredTodos;
  final TodoFilter filter;
  final TodoSort sort;
  final List<String> availableCategories;

  const TodoLoaded({
    required this.allTodos,
    required this.filteredTodos,
    required this.filter,
    required this.sort,
    required this.availableCategories,
  });

  int get totalCount => allTodos.length;
  int get completedCount => allTodos.where((t) => t.isCompleted).length;
  int get pendingCount => totalCount - completedCount;

  TodoLoaded copyWith({
    List<TodoItem>? allTodos,
    List<TodoItem>? filteredTodos,
    TodoFilter? filter,
    TodoSort? sort,
    List<String>? availableCategories,
  }) {
    return TodoLoaded(
      allTodos: allTodos ?? this.allTodos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      filter: filter ?? this.filter,
      sort: sort ?? this.sort,
      availableCategories: availableCategories ?? this.availableCategories,
    );
  }

  @override
  List<Object?> get props => [allTodos, filteredTodos, filter, sort, availableCategories];
}

class TodoError extends TodoState {
  final String message;

  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

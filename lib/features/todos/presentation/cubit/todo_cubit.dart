import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../repositories/todo_repository.dart';
import '../../../../models/todo_item.dart';
import '../../../../models/todo_status.dart';
import '../../../../models/todo_priority.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/todo_state.dart';
import '../../domain/todo_filter.dart';
import '../../domain/todo_sort.dart';

class TodoCubit extends Cubit<TodoState> {
  final TodoRepository _todoRepository;

  TodoCubit({required TodoRepository todoRepository})
      : _todoRepository = todoRepository,
        super(const TodoInitial());

  TodoFilter _filter = const TodoFilter();
  TodoSort _sort = const TodoSort();
  List<TodoItem> _cachedTodos = [];

  Future<void> loadTodos() async {
    emit(const TodoLoading());
    try {
      final todos = await _todoRepository.getTodos(
        sortBy: _sort.sortBy,
        ascending: _sort.ascending,
      );
      _cachedTodos = todos;
      _applyFilterAndSort();
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  void setFilter(TodoFilter filter) {
    _filter = filter;
    _applyFilterAndSort();
  }

  void setTab(TodoTabFilter tab) {
    _filter = _filter.copyWith(tab: tab);
    _applyFilterAndSort();
  }

  void setSearchQuery(String query) {
    _filter = _filter.copyWith(searchQuery: query);
    _applyFilterAndSort();
  }

  void setPriority(TodoPriority? priority) {
    _filter = _filter.copyWith(
      priority: priority,
      clearPriority: priority == null,
    );
    _applyFilterAndSort();
  }

  void setCategory(String? category) {
    _filter = _filter.copyWith(
      category: category,
      clearCategory: category == null,
    );
    _applyFilterAndSort();
  }

  void setDueDateFilter(DueDateFilter dueDateFilter) {
    _filter = _filter.copyWith(dueDateFilter: dueDateFilter);
    _applyFilterAndSort();
  }

  void resetFilters() {
    _filter = TodoFilter(tab: _filter.tab);
    _applyFilterAndSort();
  }

  void setSort(TodoSort sort) {
    _sort = sort;
    _applyFilterAndSort();
  }

  Future<void> addTodo({
    required String title,
    String description = '',
    TodoPriority priority = TodoPriority.medium,
    DateTime? dueDate,
    String category = 'General',
  }) async {
    try {
      final newItem = TodoItem(
        id: '',
        userId: '',
        title: title,
        description: description,
        status: TodoStatus.todo,
        priority: priority,
        dueDate: dueDate,
        category: category.trim().isEmpty ? 'General' : category.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await _todoRepository.createTodo(newItem);
      _cachedTodos.insert(0, created);
      _applyFilterAndSort();
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> updateTodo(TodoItem updatedItem) async {
    try {
      final saved = await _todoRepository.updateTodo(updatedItem);
      final index = _cachedTodos.indexWhere((t) => t.id == saved.id);
      if (index != -1) {
        _cachedTodos[index] = saved;
        _applyFilterAndSort();
      }
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> toggleStatus(TodoItem item) async {
    final nextStatus = item.status == TodoStatus.completed
        ? TodoStatus.todo
        : TodoStatus.completed;

    try {
      final updated = await _todoRepository.toggleStatus(item.id, nextStatus);
      final index = _cachedTodos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        _cachedTodos[index] = updated;
        _applyFilterAndSort();
      }
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> setSpecificStatus(TodoItem item, TodoStatus newStatus) async {
    if (item.status == newStatus) return;

    try {
      final updated = await _todoRepository.toggleStatus(item.id, newStatus);
      final index = _cachedTodos.indexWhere((t) => t.id == item.id);
      if (index != -1) {
        _cachedTodos[index] = updated;
        _applyFilterAndSort();
      }
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _todoRepository.deleteTodo(id);
      _cachedTodos.removeWhere((t) => t.id == id);
      _applyFilterAndSort();
    } on AppException catch (e) {
      emit(TodoError(e.message));
    } catch (e) {
      emit(TodoError(e.toString()));
    }
  }

  void _applyFilterAndSort() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfWeek = today.add(const Duration(days: 7));

    List<TodoItem> results = List.from(_cachedTodos);

    // 1. Tab filter
    switch (_filter.tab) {
      case TodoTabFilter.today:
        results = results.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAtSameMomentAs(today);
        }).toList();
        break;
      case TodoTabFilter.pending:
        results = results.where((t) => !t.isCompleted).toList();
        break;
      case TodoTabFilter.completed:
        results = results.where((t) => t.isCompleted).toList();
        break;
      case TodoTabFilter.all:
        break;
    }

    // 2. Priority filter
    if (_filter.priority != null) {
      results = results.where((t) => t.priority == _filter.priority).toList();
    }

    // 3. Category filter
    if (_filter.category != null && _filter.category!.isNotEmpty) {
      results = results.where((t) => t.category == _filter.category).toList();
    }

    // 4. Due Date Range filter
    switch (_filter.dueDateFilter) {
      case DueDateFilter.overdue:
        results = results.where((t) {
          if (t.dueDate == null || t.isCompleted) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isBefore(today);
        }).toList();
        break;
      case DueDateFilter.today:
        results = results.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return d.isAtSameMomentAs(today);
        }).toList();
        break;
      case DueDateFilter.thisWeek:
        results = results.where((t) {
          if (t.dueDate == null) return false;
          final d = DateTime(t.dueDate!.year, t.dueDate!.month, t.dueDate!.day);
          return (d.isAtSameMomentAs(today) || d.isAfter(today)) && d.isBefore(endOfWeek);
        }).toList();
        break;
      case DueDateFilter.noDueDate:
        results = results.where((t) => t.dueDate == null).toList();
        break;
      case DueDateFilter.all:
        break;
    }

    // 5. Search query
    if (_filter.searchQuery.trim().isNotEmpty) {
      final q = _filter.searchQuery.toLowerCase().trim();
      results = results.where((t) {
        return t.title.toLowerCase().contains(q) ||
            t.description.toLowerCase().contains(q);
      }).toList();
    }

    // 6. Sorting
    results.sort((a, b) {
      int cmp = 0;
      switch (_sort.sortBy) {
        case TodoSortBy.dueDate:
          if (a.dueDate == null && b.dueDate == null) {
            cmp = 0;
          } else if (a.dueDate == null) {
            cmp = 1;
          } else if (b.dueDate == null) {
            cmp = -1;
          } else {
            cmp = a.dueDate!.compareTo(b.dueDate!);
          }
          break;
        case TodoSortBy.priority:
          cmp = a.priority.orderValue.compareTo(b.priority.orderValue);
          break;
        case TodoSortBy.title:
          cmp = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case TodoSortBy.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sort.ascending ? cmp : -cmp;
    });

    // Extract dynamic categories
    final categories = _cachedTodos
        .map((t) => t.category)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    emit(TodoLoaded(
      allTodos: List.unmodifiable(_cachedTodos),
      filteredTodos: results,
      filter: _filter,
      sort: _sort,
      availableCategories: categories,
    ));
  }
}

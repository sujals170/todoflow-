import '../models/todo_item.dart';
import '../models/todo_status.dart';
import '../models/todo_priority.dart';

enum TodoSortBy {
  createdAt,
  dueDate,
  priority,
  title,
}

abstract class TodoRepository {
  Future<List<TodoItem>> getTodos({
    TodoStatus? status,
    TodoPriority? priority,
    String? category,
    String? searchQuery,
    TodoSortBy sortBy = TodoSortBy.createdAt,
    bool ascending = false,
  });

  Future<TodoItem> getTodoById(String id);
  Future<TodoItem> createTodo(TodoItem item);
  Future<TodoItem> updateTodo(TodoItem item);
  Future<void> deleteTodo(String id);
  Future<TodoItem> toggleStatus(String id, TodoStatus newStatus);
}

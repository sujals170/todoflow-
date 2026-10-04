import 'package:supabase_flutter/supabase_flutter.dart' as supa;
import '../../../repositories/todo_repository.dart';
import '../../../models/todo_item.dart';
import '../../../models/todo_status.dart';
import '../../../models/todo_priority.dart';
import '../../../core/errors/app_exception.dart';

class SupabaseTodoRepository implements TodoRepository {
  final supa.SupabaseClient _client;

  SupabaseTodoRepository({supa.SupabaseClient? client})
      : _client = client ?? supa.Supabase.instance.client;

  String _getAuthUserId() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthException(
        message: 'No authenticated user session found. Please sign in.',
      );
    }
    return userId;
  }

  @override
  Future<List<TodoItem>> getTodos({
    TodoStatus? status,
    TodoPriority? priority,
    String? category,
    String? searchQuery,
    TodoSortBy sortBy = TodoSortBy.createdAt,
    bool ascending = false,
  }) async {
    try {
      _getAuthUserId();

      var query = _client.from('todos').select();

      if (status != null) {
        query = query.eq('status', status.dbValue);
      }

      if (priority != null) {
        query = query.eq('priority', priority.dbValue);
      }

      if (category != null && category.trim().isNotEmpty) {
        query = query.eq('category', category.trim());
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryStr = searchQuery.trim();
        query = query.or('title.ilike.%$queryStr%,description.ilike.%$queryStr%');
      }

      // Ordering
      String sortColumn;
      bool nullsFirst = false;

      switch (sortBy) {
        case TodoSortBy.dueDate:
          sortColumn = 'due_date';
          nullsFirst = false;
          break;
        case TodoSortBy.priority:
          sortColumn = 'priority';
          break;
        case TodoSortBy.title:
          sortColumn = 'title';
          break;
        case TodoSortBy.createdAt:
          sortColumn = 'created_at';
          break;
      }

      final response = await query.order(
        sortColumn,
        ascending: ascending,
        nullsFirst: nullsFirst,
      );

      final list = response as List<dynamic>;
      return list.map((json) => TodoItem.fromJson(json as Map<String, dynamic>)).toList();
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to fetch tasks. Please try again.',
        originalError: e,
      );
    }
  }

  @override
  Future<TodoItem> getTodoById(String id) async {
    try {
      _getAuthUserId();

      final response = await _client
          .from('todos')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        throw const NotFoundException(message: 'Todo item not found.');
      }

      return TodoItem.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to retrieve task details.',
        originalError: e,
      );
    }
  }

  @override
  Future<TodoItem> createTodo(TodoItem item) async {
    try {
      final userId = _getAuthUserId();

      final payload = item.copyWith(userId: userId).toInsertJson();

      final response = await _client
          .from('todos')
          .insert(payload)
          .select()
          .single();

      return TodoItem.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to create new task.',
        originalError: e,
      );
    }
  }

  @override
  Future<TodoItem> updateTodo(TodoItem item) async {
    try {
      _getAuthUserId();

      final updateMap = <String, dynamic>{
        'title': item.title.trim(),
        'description': item.description.trim(),
        'status': item.status.dbValue,
        'priority': item.priority.dbValue,
        'category': item.category.trim(),
        'due_date': item.dueDate?.toIso8601String(),
      };

      if (item.status == TodoStatus.completed) {
        updateMap['completed_at'] = (item.completedAt ?? DateTime.now()).toIso8601String();
      } else {
        updateMap['completed_at'] = null;
      }

      final response = await _client
          .from('todos')
          .update(updateMap)
          .eq('id', item.id)
          .select()
          .single();

      return TodoItem.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to update task.',
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteTodo(String id) async {
    try {
      _getAuthUserId();

      await _client.from('todos').delete().eq('id', id);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to delete task.',
        originalError: e,
      );
    }
  }

  @override
  Future<TodoItem> toggleStatus(String id, TodoStatus newStatus) async {
    try {
      _getAuthUserId();

      final updateMap = <String, dynamic>{
        'status': newStatus.dbValue,
      };

      if (newStatus == TodoStatus.completed) {
        updateMap['completed_at'] = DateTime.now().toIso8601String();
      } else {
        updateMap['completed_at'] = null;
      }

      final response = await _client
          .from('todos')
          .update(updateMap)
          .eq('id', id)
          .select()
          .single();

      return TodoItem.fromJson(response);
    } on supa.PostgrestException catch (e) {
      throw DatabaseException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw DatabaseException(
        message: 'Failed to update task status.',
        originalError: e,
      );
    }
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/models/todo_status.dart';
import 'package:todo_app/models/todo_priority.dart';
import 'package:todo_app/models/user_profile.dart';

void main() {
  group('TodoStatus Enum', () {
    test('fromString correctly parses values case-insensitively', () {
      expect(TodoStatus.fromString('TODO'), TodoStatus.todo);
      expect(TodoStatus.fromString('in_progress'), TodoStatus.inProgress);
      expect(TodoStatus.fromString('IN_PROGRESS'), TodoStatus.inProgress);
      expect(TodoStatus.fromString('completed'), TodoStatus.completed);
      expect(TodoStatus.fromString(null), TodoStatus.todo);
      expect(TodoStatus.fromString('UNKNOWN'), TodoStatus.todo);
    });

    test('dbValues match PostgreSQL ENUM specifications', () {
      expect(TodoStatus.todo.dbValue, 'TODO');
      expect(TodoStatus.inProgress.dbValue, 'IN_PROGRESS');
      expect(TodoStatus.completed.dbValue, 'COMPLETED');
    });
  });

  group('TodoPriority Enum', () {
    test('fromString correctly maps priority strings', () {
      expect(TodoPriority.fromString('LOW'), TodoPriority.low);
      expect(TodoPriority.fromString('medium'), TodoPriority.medium);
      expect(TodoPriority.fromString('HIGH'), TodoPriority.high);
      expect(TodoPriority.fromString(null), TodoPriority.medium);
    });

    test('orderValues are correctly ordered for comparison', () {
      expect(TodoPriority.low.orderValue < TodoPriority.medium.orderValue, isTrue);
      expect(TodoPriority.medium.orderValue < TodoPriority.high.orderValue, isTrue);
    });
  });

  group('UserProfile Model', () {
    final now = DateTime.now();

    test('UserProfile serializes and deserializes properly', () {
      final json = {
        'id': 'user-123',
        'full_name': 'Alice Wonder',
        'email': 'alice@example.com',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      final profile = UserProfile.fromJson(json);
      expect(profile.id, 'user-123');
      expect(profile.fullName, 'Alice Wonder');
      expect(profile.email, 'alice@example.com');

      final serialized = profile.toJson();
      expect(serialized['id'], 'user-123');
      expect(serialized['full_name'], 'Alice Wonder');
      expect(serialized['email'], 'alice@example.com');
    });
  });

  group('TodoItem Model', () {
    final now = DateTime.now();

    test('TodoItem JSON serialization and roundtrip', () {
      final json = {
        'id': 'todo-456',
        'user_id': 'user-123',
        'title': 'Buy Groceries',
        'description': 'Milk, eggs, and bread',
        'status': 'TODO',
        'priority': 'HIGH',
        'due_date': now.toIso8601String(),
        'category': 'Shopping',
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
        'completed_at': null,
      };

      final item = TodoItem.fromJson(json);
      expect(item.id, 'todo-456');
      expect(item.title, 'Buy Groceries');
      expect(item.priority, TodoPriority.high);
      expect(item.status, TodoStatus.todo);
      expect(item.isCompleted, isFalse);

      final insertMap = item.toInsertJson();
      expect(insertMap['title'], 'Buy Groceries');
      expect(insertMap['user_id'], 'user-123');
      expect(insertMap['priority'], 'HIGH');
      expect(insertMap['status'], 'TODO');
      // id should not be in toInsertJson (handled by PostgreSQL gen_random_uuid())
      expect(insertMap.containsKey('id'), isFalse);
    });

    test('isCompleted reflects status correctly', () {
      final pendingItem = TodoItem(
        id: '1',
        userId: 'u1',
        title: 'Work on feature',
        status: TodoStatus.inProgress,
        createdAt: now,
        updatedAt: now,
      );
      expect(pendingItem.isCompleted, isFalse);

      final completedItem = pendingItem.copyWith(status: TodoStatus.completed);
      expect(completedItem.isCompleted, isTrue);
    });
  });
}

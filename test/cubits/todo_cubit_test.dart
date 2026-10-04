import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:todo_app/features/todos/domain/todo_filter.dart';
import 'package:todo_app/features/todos/domain/todo_state.dart';
import 'package:todo_app/features/todos/presentation/cubit/todo_cubit.dart';
import 'package:todo_app/models/todo_item.dart';
import 'package:todo_app/models/todo_priority.dart';
import 'package:todo_app/models/todo_status.dart';
import 'package:todo_app/repositories/todo_repository.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late TodoCubit todoCubit;

  final sampleDate = DateTime(2026, 10, 4);
  final sampleTodos = [
    TodoItem(
      id: '1',
      userId: 'u1',
      title: 'Fix auth bug',
      description: 'Check token refresh',
      status: TodoStatus.todo,
      priority: TodoPriority.high,
      category: 'Work',
      createdAt: sampleDate,
      updatedAt: sampleDate,
    ),
    TodoItem(
      id: '2',
      userId: 'u1',
      title: 'Buy groceries',
      description: 'Apples and milk',
      status: TodoStatus.completed,
      priority: TodoPriority.low,
      category: 'Personal',
      createdAt: sampleDate.add(const Duration(hours: 1)),
      updatedAt: sampleDate.add(const Duration(hours: 1)),
    ),
  ];

  setUpAll(() {
    registerFallbackValue(sampleTodos.first);
    registerFallbackValue(TodoSortBy.createdAt);
  });

  setUp(() {
    mockRepository = MockTodoRepository();
    when(() => mockRepository.getTodos(
          sortBy: any(named: 'sortBy'),
          ascending: any(named: 'ascending'),
        )).thenAnswer((_) async => List.from(sampleTodos));

    todoCubit = TodoCubit(todoRepository: mockRepository);
  });

  tearDown(() {
    todoCubit.close();
  });

  group('TodoCubit - Load & CRUD', () {
    test('initial state is TodoInitial', () {
      expect(todoCubit.state, equals(const TodoInitial()));
    });

    test('loadTodos emits [TodoLoading, TodoLoaded]', () async {
      final expectedStates = [
        isA<TodoLoading>(),
        isA<TodoLoaded>()
            .having((s) => s.totalCount, 'totalCount', 2)
            .having((s) => s.completedCount, 'completedCount', 1)
            .having((s) => s.pendingCount, 'pendingCount', 1),
      ];

      expectLater(todoCubit.stream, emitsInOrder(expectedStates));
      await todoCubit.loadTodos();
    });

    test('toggleStatus updates status and completes task', () async {
      await todoCubit.loadTodos();

      final target = sampleTodos.first;
      final toggled = target.copyWith(status: TodoStatus.completed);

      when(() => mockRepository.toggleStatus('1', TodoStatus.completed))
          .thenAnswer((_) async => toggled);

      await todoCubit.toggleStatus(target);

      final state = todoCubit.state as TodoLoaded;
      final updated = state.allTodos.firstWhere((t) => t.id == '1');
      expect(updated.status, TodoStatus.completed);
      expect(state.completedCount, 2);
    });

    test('deleteTodo removes item from loaded list', () async {
      await todoCubit.loadTodos();

      when(() => mockRepository.deleteTodo('1')).thenAnswer((_) async {});

      await todoCubit.deleteTodo('1');

      final state = todoCubit.state as TodoLoaded;
      expect(state.totalCount, 1);
      expect(state.allTodos.any((t) => t.id == '1'), isFalse);
    });
  });

  group('TodoCubit - Filtering & Search', () {
    test('setSearchQuery filters by keyword in title or description', () async {
      await todoCubit.loadTodos();

      todoCubit.setSearchQuery('groceries');
      var state = todoCubit.state as TodoLoaded;
      expect(state.filteredTodos.length, 1);
      expect(state.filteredTodos.first.title, 'Buy groceries');

      todoCubit.setSearchQuery('token'); // in description
      state = todoCubit.state as TodoLoaded;
      expect(state.filteredTodos.length, 1);
      expect(state.filteredTodos.first.title, 'Fix auth bug');
    });

    test('setPriority filters strictly by chosen priority', () async {
      await todoCubit.loadTodos();

      todoCubit.setPriority(TodoPriority.high);
      final state = todoCubit.state as TodoLoaded;
      expect(state.filteredTodos.length, 1);
      expect(state.filteredTodos.first.priority, TodoPriority.high);
    });

    test('setTab filters by pending and completed', () async {
      await todoCubit.loadTodos();

      todoCubit.setTab(TodoTabFilter.pending);
      var state = todoCubit.state as TodoLoaded;
      expect(state.filteredTodos.length, 1);
      expect(state.filteredTodos.first.id, '1');

      todoCubit.setTab(TodoTabFilter.completed);
      state = todoCubit.state as TodoLoaded;
      expect(state.filteredTodos.length, 1);
      expect(state.filteredTodos.first.id, '2');
    });
  });
}

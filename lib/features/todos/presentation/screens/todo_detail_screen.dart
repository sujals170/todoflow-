import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../models/todo_item.dart';
import '../../../../models/todo_status.dart';
import '../cubit/todo_cubit.dart';
import '../../domain/todo_state.dart';
import '../widgets/priority_badge.dart';
import '../widgets/status_badge.dart';

class TodoDetailScreen extends StatelessWidget {
  final String todoId;

  const TodoDetailScreen({
    super.key,
    required this.todoId,
  });

  void _confirmDelete(BuildContext context, TodoItem item) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<TodoCubit>().deleteTodo(item.id);
              context.pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 720;

    return BlocBuilder<TodoCubit, TodoState>(
      builder: (context, state) {
        if (state is! TodoLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final item = state.allTodos.firstWhere(
          (t) => t.id == todoId,
          orElse: () => TodoItem(
            id: '',
            userId: '',
            title: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );

        if (item.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Task not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Task Details'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Task',
                onPressed: () => context.push('/todo/edit', extra: item),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
                tooltip: 'Delete Task',
                onPressed: () => _confirmDelete(context, item),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 640 : double.infinity),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        PriorityBadge(priority: item.priority),
                        StatusBadge(status: item.status),
                        if (item.category.isNotEmpty)
                          Chip(
                            label: Text('#${item.category}'),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (item.description.isNotEmpty) ...[
                      Text(
                        'Description',
                        style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            item.description,
                            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    Text(
                      'Information',
                      style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.event_outlined),
                            title: const Text('Due Date'),
                            subtitle: Text(
                              item.dueDate != null
                                  ? DateFormat.yMMMMd().add_jm().format(item.dueDate!)
                                  : 'No deadline assigned',
                            ),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.access_time_rounded),
                            title: const Text('Created'),
                            subtitle: Text(
                              DateFormat.yMMMMd().add_jm().format(item.createdAt),
                            ),
                          ),
                          if (item.completedAt != null) ...[
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.check_circle_outline_rounded),
                              title: const Text('Completed At'),
                              subtitle: Text(
                                DateFormat.yMMMMd().add_jm().format(item.completedAt!),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Quick Status Switch
                    Text(
                      'Change Status',
                      style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<TodoStatus>(
                      segments: const [
                        ButtonSegment(
                          value: TodoStatus.todo,
                          label: Text('To Do'),
                        ),
                        ButtonSegment(
                          value: TodoStatus.inProgress,
                          label: Text('In Progress'),
                        ),
                        ButtonSegment(
                          value: TodoStatus.completed,
                          label: Text('Completed'),
                        ),
                      ],
                      selected: {item.status},
                      onSelectionChanged: (set) {
                        context.read<TodoCubit>().setSpecificStatus(item, set.first);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/todo_item.dart';
import '../../../../models/todo_status.dart';
import '../../../../core/theme/app_colors.dart';
import 'priority_badge.dart';
import 'status_badge.dart';

class TodoCard extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onTap;
  final VoidCallback onToggleStatus;
  final ValueChanged<TodoStatus>? onSelectStatus;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TodoCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onToggleStatus,
    this.onSelectStatus,
    required this.onEdit,
    required this.onDelete,
  });

  bool get _isOverdue {
    if (item.dueDate == null || item.isCompleted) return false;
    final now = DateTime.now();
    return item.dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isDone = item.isCompleted;

    return Dismissible(
      key: Key('todo_${item.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Delete Task?'),
            content: Text('Are you sure you want to delete "${item.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogCtx).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                ),
                onPressed: () => Navigator.of(dialogCtx).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stitch Circular Checkbox
                InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onToggleStatus,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2, right: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone
                          ? AppColors.secondaryAccent
                          : (isDark
                              ? AppColors.darkContainerHigh
                              : AppColors.lightContainerHigh),
                      border: Border.all(
                        color: isDone
                            ? AppColors.secondaryAccent
                            : (isDark ? AppColors.darkBorder : AppColors.outline),
                        width: isDone ? 0 : 1.5,
                      ),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                // Task Content & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    decoration: isDone ? TextDecoration.lineThrough : null,
                                    color: isDone
                                        ? (isDark
                                            ? AppColors.darkTextMuted
                                            : AppColors.lightTextMuted)
                                        : null,
                                  ),
                            ),
                          ),
                          // Actions Popup Menu
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              size: 20,
                              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                            onSelected: (action) {
                              switch (action) {
                                case 'details':
                                  onTap();
                                  break;
                                case 'edit':
                                  onEdit();
                                  break;
                                case 'in_progress':
                                  onSelectStatus?.call(TodoStatus.inProgress);
                                  break;
                                case 'completed':
                                  onSelectStatus?.call(TodoStatus.completed);
                                  break;
                                case 'todo':
                                  onSelectStatus?.call(TodoStatus.todo);
                                  break;
                                case 'delete':
                                  onDelete();
                                  break;
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'details',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility_outlined, size: 18),
                                    SizedBox(width: 10),
                                    Text('View Details'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 10),
                                    Text('Edit Task'),
                                  ],
                                ),
                              ),
                              if (item.status != TodoStatus.inProgress)
                                const PopupMenuItem(
                                  value: 'in_progress',
                                  child: Row(
                                    children: [
                                      Icon(Icons.hourglass_top_rounded, size: 18),
                                      SizedBox(width: 10),
                                      Text('Mark In Progress'),
                                    ],
                                  ),
                                ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline_rounded,
                                        size: 18, color: theme.colorScheme.error),
                                    const SizedBox(width: 10),
                                    Text('Delete',
                                        style: TextStyle(color: theme.colorScheme.error)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (item.description.trim().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          PriorityBadge(priority: item.priority, isSmall: true),
                          StatusBadge(status: item.status),
                          if (item.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkContainer
                                    : AppColors.lightContainerLow,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Text(
                                '#${item.category}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ),
                          if (item.dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _isOverdue
                                    ? AppColors.priorityHighBg
                                    : (isDark
                                        ? AppColors.darkContainer
                                        : AppColors.lightContainerLow),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.event_outlined,
                                    size: 13,
                                    color: _isOverdue
                                        ? AppColors.priorityHigh
                                        : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat.MMMd().format(item.dueDate!),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight:
                                          _isOverdue ? FontWeight.bold : FontWeight.w500,
                                      color: _isOverdue
                                          ? AppColors.priorityHigh
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../models/todo_status.dart';
import '../../../../core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final TodoStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;

    switch (status) {
      case TodoStatus.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_outline_rounded;
        break;
      case TodoStatus.inProgress:
        color = AppColors.statusInProgress;
        icon = Icons.hourglass_top_rounded;
        break;
      case TodoStatus.todo:
        color = AppColors.statusTodo;
        icon = Icons.radio_button_unchecked_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

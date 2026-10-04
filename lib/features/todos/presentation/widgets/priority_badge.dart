import 'package:flutter/material.dart';
import '../../../../models/todo_priority.dart';
import '../../../../core/theme/app_colors.dart';

class PriorityBadge extends StatelessWidget {
  final TodoPriority priority;
  final bool isSmall;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (priority) {
      case TodoPriority.high:
        color = AppColors.priorityHigh;
        break;
      case TodoPriority.medium:
        color = AppColors.priorityMedium;
        break;
      case TodoPriority.low:
        color = AppColors.priorityLow;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 10,
        vertical: isSmall ? 2 : 4,
      ),
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
          Container(
            width: isSmall ? 6 : 8,
            height: isSmall ? 6 : 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 11 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

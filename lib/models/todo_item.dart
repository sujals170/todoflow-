import 'package:equatable/equatable.dart';
import 'todo_status.dart';
import 'todo_priority.dart';

class TodoItem extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TodoStatus status;
  final TodoPriority priority;
  final DateTime? dueDate;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const TodoItem({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.status = TodoStatus.todo,
    this.priority = TodoPriority.medium,
    this.dueDate,
    this.category = 'General',
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  bool get isCompleted => status == TodoStatus.completed;

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      status: TodoStatus.fromString(json['status'] as String?),
      priority: TodoPriority.fromString(json['priority'] as String?),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      category: json['category'] as String? ?? 'General',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status.dbValue,
      'priority': priority.dbValue,
      'due_date': dueDate?.toIso8601String(),
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Map for database insert operations where DB handles defaults & auto-columns
  Map<String, dynamic> toInsertJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'title': title,
      'description': description,
      'status': status.dbValue,
      'priority': priority.dbValue,
      'category': category,
    };
    if (dueDate != null) {
      map['due_date'] = dueDate!.toIso8601String();
    }
    return map;
  }

  TodoItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueDate,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    bool clearDueDate = false,
  }) {
    return TodoItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        status,
        priority,
        dueDate,
        category,
        createdAt,
        updatedAt,
        completedAt,
      ];
}

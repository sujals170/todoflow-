enum TodoStatus {
  todo('TODO', 'To Do'),
  inProgress('IN_PROGRESS', 'In Progress'),
  completed('COMPLETED', 'Completed');

  final String dbValue;
  final String label;

  const TodoStatus(this.dbValue, this.label);

  static TodoStatus fromString(String? value) {
    if (value == null) return TodoStatus.todo;
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return TodoStatus.inProgress;
      case 'COMPLETED':
        return TodoStatus.completed;
      case 'TODO':
      default:
        return TodoStatus.todo;
    }
  }
}

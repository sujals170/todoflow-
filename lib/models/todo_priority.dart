enum TodoPriority {
  low('LOW', 'Low', 1),
  medium('MEDIUM', 'Medium', 2),
  high('HIGH', 'High', 3);

  final String dbValue;
  final String label;
  final int orderValue;

  const TodoPriority(this.dbValue, this.label, this.orderValue);

  static TodoPriority fromString(String? value) {
    if (value == null) return TodoPriority.medium;
    switch (value.toUpperCase()) {
      case 'LOW':
        return TodoPriority.low;
      case 'HIGH':
        return TodoPriority.high;
      case 'MEDIUM':
      default:
        return TodoPriority.medium;
    }
  }
}

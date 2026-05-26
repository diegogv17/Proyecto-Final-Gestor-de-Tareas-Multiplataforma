enum TaskStatus {
  pending('Pendiente'),
  inProgress('En progreso'),
  completed('Completada');

  const TaskStatus(this.label);
  final String label;

  String get apiValue => switch (this) {
        TaskStatus.pending => 'PENDING',
        TaskStatus.inProgress => 'IN_PROGRESS',
        TaskStatus.completed => 'COMPLETED',
      };

  static TaskStatus fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'IN_PROGRESS':
        return TaskStatus.inProgress;
      case 'COMPLETED':
        return TaskStatus.completed;
      default:
        return TaskStatus.pending;
    }
  }
}

enum TaskPriority {
  low('Baja'),
  medium('Media'),
  high('Alta'),
  urgent('Urgente');

  const TaskPriority(this.label);
  final String label;

  String get apiValue => switch (this) {
        TaskPriority.low => 'LOW',
        TaskPriority.medium => 'MEDIUM',
        TaskPriority.high => 'HIGH',
        TaskPriority.urgent => 'URGENT',
      };

  static TaskPriority fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'LOW':
        return TaskPriority.low;
      case 'HIGH':
        return TaskPriority.high;
      case 'URGENT':
        return TaskPriority.urgent;
      default:
        return TaskPriority.medium;
    }
  }
}

enum TaskFilter {
  all('Todas'),
  pending('Pendientes'),
  inProgress('En progreso'),
  completed('Completadas');

  const TaskFilter(this.label);
  final String label;
}

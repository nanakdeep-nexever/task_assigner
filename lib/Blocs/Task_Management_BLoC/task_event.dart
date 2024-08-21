abstract class TaskEvent {}

class LoadTasksEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final String name;
  final String description;
  final String? assignedTo;
  final String? assignedBy;
  final String status;
  final DateTime deadline;

  CreateTaskEvent(
      {required this.name,
      required this.description,
      required this.assignedTo,
      required this.assignedBy,
      required this.status,
      required this.deadline});
}

class UpdateTaskEvent extends TaskEvent {
  final String name;
  final String description;
  final String? assignedTo;
  final String? assignedBy;
  final String status;
  final DateTime deadline;

  UpdateTaskEvent(
      {required this.name,
      required this.description,
      required this.assignedTo,
      required this.assignedBy,
      required this.status,
      required this.deadline});
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent({required this.taskId});
}

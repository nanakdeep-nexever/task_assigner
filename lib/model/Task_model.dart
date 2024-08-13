class Task {
  final String id;
  final String name;
  final String description;
  final String projectId;
  final String assignedTo;
  final String status;
  final DateTime deadline;

  Task(
      {required this.id,
      required this.name,
      required this.description,
      required this.projectId,
      required this.assignedTo,
      required this.status,
      required this.deadline});
}

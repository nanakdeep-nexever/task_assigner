import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadTasksEvent extends TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  final String name;
  final String description;
  final String projectId;
  final String assignedTo;
  final String status;
  final DateTime deadline;

  CreateTaskEvent(
      {required this.name,
      required this.description,
      required this.projectId,
      required this.assignedTo,
      required this.status,
      required this.deadline});
}

class UpdateTaskEvent extends TaskEvent {
  final String taskId;
  final String name;
  final String description;
  final String status;
  final DateTime deadline;

  UpdateTaskEvent(
      {required this.taskId,
      required this.name,
      required this.description,
      required this.status,
      required this.deadline});
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent({required this.taskId});
}

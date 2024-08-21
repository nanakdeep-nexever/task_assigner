import 'package:equatable/equatable.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object> get props => [];
}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Map<String, dynamic> task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TaskEvent {
  final String taskId;
  final Map<String, dynamic> updatedTask;

  const UpdateTask(this.taskId, this.updatedTask);

  @override
  List<Object> get props => [taskId, updatedTask];
}

class DeleteTask extends TaskEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

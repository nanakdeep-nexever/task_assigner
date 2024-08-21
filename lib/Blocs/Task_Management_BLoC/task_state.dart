import 'package:equatable/equatable.dart';

import '../../model/Task_model.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<Task> tasks;

  TaskLoaded({required this.tasks});
}

class TaskError extends TaskState {
  final String message;

  TaskError({required this.message});
}

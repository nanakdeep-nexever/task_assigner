import 'package:equatable/equatable.dart';

abstract class DevelopState extends Equatable {
  const DevelopState();

  @override
  List<Object?> get props => [];
}

class TaskLoading extends DevelopState {}

class TaskLoaded extends DevelopState {
  final List<Map<String, dynamic>> tasks;
  final int activeTasksCount;

  const TaskLoaded({
    required this.tasks,
    required this.activeTasksCount,
  });

  @override
  List<Object?> get props => [tasks, activeTasksCount];
}

class TaskError extends DevelopState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}

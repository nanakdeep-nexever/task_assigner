import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_event.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasksEvent>(_fetchTask);
    on<CreateTaskEvent>(_CreateTask);
    on<UpdateTaskEvent>(_UpdateTask);
    on<DeleteTaskEvent>(_DeleteTask);
  }

  FutureOr<void> _fetchTask(LoadTasksEvent event, Emitter<TaskState> emit) {}

  FutureOr<void> _CreateTask(CreateTaskEvent event, Emitter<TaskState> emit) {}

  FutureOr<void> _UpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) {}

  FutureOr<void> _DeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) {}
}

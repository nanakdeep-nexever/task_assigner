import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_event.dart';
import 'package:task_assign_app/Blocs/Task_Management_BLoC/task_state.dart';
import 'package:task_assign_app/model/Task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TaskBloc() : super(TaskInitial()) {
    on<LoadTasksEvent>(_fetchTask);
    on<CreateTaskEvent>(_CreateTask);
    on<UpdateTaskEvent>(_UpdateTask);
    on<DeleteTaskEvent>(_DeleteTask);
  }
  Stream<List<Task>> get TasKStream {
    return _firestore.collection('tasks').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList());
  }

  FutureOr<void> _fetchTask(
      LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading()); // Indicate that loading has started
    try {
      final snapshot = await _firestore.collection('tasks').get();
      final tasks =
          snapshot.docs.map((doc) => Task.fromFirestore(doc)).toList();
      emit(TaskLoaded(tasks: tasks));
    } catch (e) {
      emit(TaskError(message: "Failed to fetch tasks: ${e.toString()}"));
    }
  }
}

FutureOr<void> _CreateTask(CreateTaskEvent event, Emitter<TaskState> emit) {}

FutureOr<void> _UpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) {}

FutureOr<void> _DeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) {}

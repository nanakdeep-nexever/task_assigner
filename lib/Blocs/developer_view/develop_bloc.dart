import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'develop_event.dart';
import 'develop_state.dart';

class DevelopBloc extends Bloc<DevelopEvent, DevelopState> {
  final FirebaseFirestore _firestore;

  late StreamSubscription<QuerySnapshot> _tasksSubscription;
  DevelopBloc(this._firestore) : super(TaskLoading()) {
    on<LoadTasks>(_active);
    _tasksSubscription =
        _firestore.collection('tasks').snapshots().listen((snapshot) {
      add(LoadTasks()); // Trigger event to update user tasks
    });
  }

  FutureOr<void> _active(LoadTasks event, Emitter<DevelopState> emit) async {
    try {
      // Fetch the tasks from Firestore
      final snapshot = await _firestore.collection('tasks').get();
      final tasks = snapshot.docs.map((doc) => doc.data()).toList();

      emit(
        TaskLoaded(
          tasks: tasks,
          activeTasksCount: tasks.length,
        ),
      );
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  TaskBloc() : super(TaskInitial());

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    if (event is LoadTasks) {
      yield TaskLoading();
      try {
        final snapshot = await _firebaseFirestore.collection('tasks').get();
        final tasks = snapshot.docs;
        yield TaskLoaded(tasks);
      } catch (e) {
        yield const TaskError('Failed to load tasks');
      }
    } else if (event is AddTask) {
      try {
        await _firebaseFirestore.collection('tasks').add(event.task);
        add(LoadTasks()); // Reload tasks
      } catch (e) {
        yield const TaskError('Failed to add task');
      }
    } else if (event is UpdateTask) {
      try {
        await _firebaseFirestore
            .collection('tasks')
            .doc(event.taskId)
            .update(event.updatedTask);
        add(LoadTasks()); // Reload tasks
      } catch (e) {
        yield const TaskError('Failed to update task');
      }
    } else if (event is DeleteTask) {
      try {
        await _firebaseFirestore.collection('tasks').doc(event.taskId).delete();
        add(LoadTasks()); // Reload tasks
      } catch (e) {
        yield const TaskError('Failed to delete task');
      }
    }
  }
}

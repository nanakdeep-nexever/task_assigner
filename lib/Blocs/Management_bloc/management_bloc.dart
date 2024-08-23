import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'management_event.dart';
import 'management_state.dart';

class ManagerPageBloc extends Bloc<ManagerPageEvent, ManagerState> {
  final FirebaseFirestore _firestore;
  late StreamSubscription<QuerySnapshot> _usersSubscription;
  late StreamSubscription<QuerySnapshot> _tasksSubscription;
  late StreamSubscription<QuerySnapshot> _projectsSubscription;

  ManagerPageBloc(this._firestore) : super(ManagerPageInitial()) {
    on<LoadActiveUsers>(_onLoadActiveUsers);
    on<LoadActiveTasks>(_onLoadActiveTasks);
    on<LoadActiveProjects>(_onLoadActiveProjects);
    on<LoadUserTasks>(_onLoadUserTasks);
    on<LoadUserProjects>(_onLoadUserProjects);

    // Initialize streams
    _initializeStreams();
  }

  void _initializeStreams() {
    _usersSubscription =
        _firestore.collection('users').snapshots().listen((snapshot) {
      add(LoadActiveUsers()); // Trigger event to update state with active users
    });

    _tasksSubscription =
        _firestore.collection('tasks').snapshots().listen((snapshot) {
      add(LoadActiveTasks()); // Trigger event to update state with active tasks
      add(LoadUserTasks()); // Trigger event to update user tasks
    });

    _projectsSubscription =
        _firestore.collection('projects').snapshots().listen((snapshot) {
      add(LoadActiveProjects()); // Trigger event to update state with active projects
      add(LoadUserProjects()); // Trigger event to update user projects
    });
  }

  Future<void> _onLoadActiveUsers(
      LoadActiveUsers event, Emitter<ManagerState> emit) async {
    try {
      final snapshot = await _firestore.collection('users').get();
      emit(
        ManagerPageLoaded(
          activeUsers: snapshot.docs.length,
          activeTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeTasks
              : 0,
          activeProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeProjects
              : 0,
          userTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userTasks
              : [],
          userProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userProjects
              : [],
        ),
      );
    } catch (e) {
      emit(ManagerPageError(e.toString()));
    }
  }

  Future<void> _onLoadActiveTasks(
      LoadActiveTasks event, Emitter<ManagerState> emit) async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      emit(
        ManagerPageLoaded(
          activeTasks: snapshot.docs.length,
          activeUsers: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeUsers
              : 0,
          activeProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeProjects
              : 0,
          userTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userTasks
              : [],
          userProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userProjects
              : [],
        ),
      );
    } catch (e) {
      emit(ManagerPageError(e.toString()));
    }
  }

  Future<void> _onLoadActiveProjects(
      LoadActiveProjects event, Emitter<ManagerState> emit) async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      emit(
        ManagerPageLoaded(
          activeProjects: snapshot.docs.length,
          activeUsers: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeUsers
              : 0,
          activeTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeTasks
              : 0,
          userTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userTasks
              : [],
          userProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userProjects
              : [],
        ),
      );
    } catch (e) {
      emit(ManagerPageError(e.toString()));
    }
  }

  Future<void> _onLoadUserTasks(
      LoadUserTasks event, Emitter<ManagerState> emit) async {
    try {
      final snapshot = await _firestore.collection('tasks').get();
      emit(
        ManagerPageLoaded(
          userTasks: snapshot.docs,
          activeUsers: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeUsers
              : 0,
          activeTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeTasks
              : 0,
          activeProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeProjects
              : 0,
          userProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userProjects
              : [],
        ),
      );
    } catch (e) {
      emit(ManagerPageError(e.toString()));
    }
  }

  Future<void> _onLoadUserProjects(
      LoadUserProjects event, Emitter<ManagerState> emit) async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      emit(
        ManagerPageLoaded(
          userProjects: snapshot.docs,
          activeUsers: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeUsers
              : 0,
          activeTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeTasks
              : 0,
          activeProjects: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).activeProjects
              : 0,
          userTasks: state is ManagerPageLoaded
              ? (state as ManagerPageLoaded).userTasks
              : [],
        ),
      );
    } catch (e) {
      emit(ManagerPageError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    // Cancel stream subscriptions when the bloc is closed
    _usersSubscription.cancel();
    _tasksSubscription.cancel();
    _projectsSubscription.cancel();
    return super.close();
  }
}

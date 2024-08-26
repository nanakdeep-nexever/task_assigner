// lib/Blocs/AdminBloc/admin_bloc.dart

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_event.dart';
import 'admin_state.dart';

class AdminPageBloc extends Bloc<AdminPageEvent, Admin_Page_State> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<QuerySnapshot> _usersSubscription;
  late StreamSubscription<QuerySnapshot> _tasksSubscription;
  late StreamSubscription<QuerySnapshot> _projectsSubscription;

  AdminPageBloc() : super(AdminPageInitial()) {
    on<LoadDataEvent>(_onLoadDataEvent);
    on<UpdateUsersEvent>(_onUpdateUsersEvent);
    on<UpdateTasksEvent>(_onUpdateTasksEvent);
    on<UpdateProjectsEvent>(_onUpdateProjectsEvent);
  }

  Future<void> _onLoadDataEvent(
      LoadDataEvent event, Emitter<Admin_Page_State> emit) async {
    emit(AdminPageLoading());

    try {
      _usersSubscription =
          _firestore.collection('users').snapshots().listen((snapshot) {
        add(UpdateUsersEvent(snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList()));
      });

      _tasksSubscription =
          _firestore.collection('tasks').snapshots().listen((snapshot) {
        add(UpdateTasksEvent(snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList()));
      });

      _projectsSubscription =
          _firestore.collection('projects').snapshots().listen((snapshot) {
        add(UpdateProjectsEvent(snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList()));
      });

      // Initially, the page is in loading state until the first data is fetched
      emit(AdminPageLoading());
    } catch (e) {
      emit(AdminPageError(e.toString()));
    }
  }

  Future<void> _onUpdateUsersEvent(
      UpdateUsersEvent event, Emitter<Admin_Page_State> emit) async {
    final users = event.users;
    final activeUsers = users.length; // Example logic
    emit(_updateState(users: users, activeUsers: activeUsers));
  }

  Future<void> _onUpdateTasksEvent(
      UpdateTasksEvent event, Emitter<Admin_Page_State> emit) async {
    final tasks = event.tasks;
    final activeTasks = tasks.length; // Example logic
    emit(_updateState(tasks: tasks, activeTasks: activeTasks));
  }

  Future<void> _onUpdateProjectsEvent(
      UpdateProjectsEvent event, Emitter<Admin_Page_State> emit) async {
    final projects = event.projects;
    final activeProjects = projects.length; // Example logic
    emit(_updateState(projects: projects, activeProjects: activeProjects));
  }

  Admin_Page_State _updateState({
    List<Map<String, dynamic>>? users,
    List<Map<String, dynamic>>? tasks,
    List<Map<String, dynamic>>? projects,
    int? activeUsers,
    int? activeTasks,
    int? activeProjects,
  }) {
    final currentState = state;
    return AdminPageLoaded(
      activeUsers: activeUsers ?? (currentState as AdminPageLoaded).activeUsers,
      activeTasks: activeTasks ?? (currentState as AdminPageLoaded).activeTasks,
      activeProjects:
          activeProjects ?? (currentState as AdminPageLoaded).activeProjects,
      users: users ?? (currentState as AdminPageLoaded).users,
      tasks: tasks ?? (currentState as AdminPageLoaded).tasks,
      projects: projects ?? (currentState as AdminPageLoaded).projects,
    );
  }

  @override
  Future<void> close() {
    _usersSubscription.cancel();
    _tasksSubscription.cancel();
    _projectsSubscription.cancel();
    return super.close();
  }
}

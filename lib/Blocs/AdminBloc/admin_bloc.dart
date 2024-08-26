// admin_page_bloc.dart

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_event.dart';
import 'admin_state.dart';

class AdminPageBloc extends Bloc<AdminPageEvent, Admin_Page_State> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminPageBloc() : super(AdminPageInitial()) {
    on<LoadAdminDataEvent>(_onLoadAdminData);
    on<UpdateUserRoleEvent>(_onUpdateUserRole);
  }

  Future<void> _onLoadAdminData(
      LoadAdminDataEvent event, Emitter<Admin_Page_State> emit) async {
    emit(AdminPageLoading());

    try {
      final usersStream = _firestore.collection('users').snapshots();
      final tasksStream = _firestore.collection('tasks').snapshots();
      final projectsStream = _firestore.collection('projects').snapshots();

      // Listen to the data streams
      final users = await _firestore.collection('users').get();
      final tasks = await _firestore.collection('tasks').get();
      final projects = await _firestore.collection('projects').get();

      emit(AdminPageLoaded(
        activeUsersStream: usersStream,
        activeTasksStream: tasksStream,
        activeProjectsStream: projectsStream,
        users: users.docs,
        tasks: tasks.docs,
        projects: projects.docs,
      ));
    } catch (e) {
      emit(AdminPageError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserRole(
      UpdateUserRoleEvent event, Emitter<Admin_Page_State> emit) async {
    try {
      await _firestore.collection('users').doc(event.uid).update({
        'role': event.newRole,
      });
      add(LoadAdminDataEvent()); // Reload data after update
    } catch (e) {
      emit(AdminPageError(message: e.toString()));
    }
  }
}

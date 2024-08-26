// admin_page_state.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class Admin_Page_State extends Equatable {
  @override
  List<Object> get props => [];
}

class AdminPageInitial extends Admin_Page_State {}

class AdminPageLoading extends Admin_Page_State {}

class AdminPageLoaded extends Admin_Page_State {
  final Stream<QuerySnapshot> activeUsersStream;
  final Stream<QuerySnapshot> activeTasksStream;
  final Stream<QuerySnapshot> activeProjectsStream;
  final List<QueryDocumentSnapshot> users;
  final List<QueryDocumentSnapshot> tasks;
  final List<QueryDocumentSnapshot> projects;

  AdminPageLoaded({
    required this.activeUsersStream,
    required this.activeTasksStream,
    required this.activeProjectsStream,
    required this.users,
    required this.tasks,
    required this.projects,
  });

  @override
  List<Object> get props => [
        activeUsersStream,
        activeTasksStream,
        activeProjectsStream,
        users,
        tasks,
        projects
      ];
}

class AdminPageError extends Admin_Page_State {
  final String message;

  AdminPageError({required this.message});

  @override
  List<Object> get props => [message];
}

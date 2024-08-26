// lib/Blocs/AdminBloc/admin_state.dart

import 'package:equatable/equatable.dart';

abstract class Admin_Page_State extends Equatable {
  const Admin_Page_State();

  @override
  List<Object?> get props => [];
}

class AdminPageInitial extends Admin_Page_State {}

class AdminPageLoading extends Admin_Page_State {}

class AdminPageLoaded extends Admin_Page_State {
  final int activeUsers;
  final int activeTasks;
  final int activeProjects;
  final List<Map<String, dynamic>> users;
  final List<Map<String, dynamic>> tasks;
  final List<Map<String, dynamic>> projects;

  const AdminPageLoaded({
    required this.activeUsers,
    required this.activeTasks,
    required this.activeProjects,
    required this.users,
    required this.tasks,
    required this.projects,
  });

  @override
  List<Object?> get props =>
      [activeUsers, activeTasks, activeProjects, users, tasks, projects];
}

class AdminPageError extends Admin_Page_State {
  final String message;

  const AdminPageError(this.message);

  @override
  List<Object?> get props => [message];
}

// lib/Blocs/AdminBloc/admin_event.dart

import 'package:equatable/equatable.dart';

abstract class AdminPageEvent extends Equatable {
  const AdminPageEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDataEvent extends AdminPageEvent {
  @override
  List<Object> get props => [];
}

class UpdateUserRoleEvent extends AdminPageEvent {
  final String uid;
  final String newRole;

  const UpdateUserRoleEvent({required this.uid, required this.newRole});

  @override
  List<Object> get props => [uid, newRole];
}

class UpdateUsersEvent extends AdminPageEvent {
  final List<Map<String, dynamic>> users;

  const UpdateUsersEvent(this.users);

  @override
  List<Object?> get props => [users];
}

class UpdateTasksEvent extends AdminPageEvent {
  final List<Map<String, dynamic>> tasks;

  const UpdateTasksEvent(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class UpdateProjectsEvent extends AdminPageEvent {
  final List<Map<String, dynamic>> projects;

  const UpdateProjectsEvent(this.projects);

  @override
  List<Object?> get props => [projects];
}

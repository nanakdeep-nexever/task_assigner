import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

abstract class ManagerState extends Equatable {
  @override
  List<Object> get props => [];
}

class ManagerPageInitial extends ManagerState {}

class ManagerPageLoading extends ManagerState {}

class ManagerPageLoaded extends ManagerState {
  final int activeUsers;
  final int activeTasks;
  final int activeProjects;
  final List<QueryDocumentSnapshot> userTasks;
  final List<QueryDocumentSnapshot> userProjects;

  ManagerPageLoaded({
    required this.activeUsers,
    required this.activeTasks,
    required this.activeProjects,
    required this.userTasks,
    required this.userProjects,
  });

  @override
  List<Object> get props => [
        activeUsers,
        activeTasks,
        activeProjects,
        userTasks,
        userProjects,
      ];
}

class ManagerPageError extends ManagerState {
  final String error;

  ManagerPageError(this.error);

  @override
  List<Object> get props => [error];
}

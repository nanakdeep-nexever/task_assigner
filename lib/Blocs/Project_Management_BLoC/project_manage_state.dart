import 'package:equatable/equatable.dart';
import 'package:task_assign_app/model/Project_model.dart';

abstract class ProjectState extends Equatable {
  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;

  ProjectLoaded({required this.projects});

  @override
  List<Object> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;

  ProjectError({required this.message});

  @override
  List<Object> get props => [message];
}

import 'package:equatable/equatable.dart';

abstract class ProjectState extends Equatable {
  const ProjectState();

  @override
  List<Object> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<Map<String, dynamic>> projects;

  const ProjectLoaded({required this.projects});

  @override
  List<Object> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;

  const ProjectError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProjectActionSuccess extends ProjectState {
  final String message;

  const ProjectActionSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

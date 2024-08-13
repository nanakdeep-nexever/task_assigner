import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProjectsEvent extends ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final String name;
  final String description;

  CreateProjectEvent({required this.name, required this.description});
}

class UpdateProjectEvent extends ProjectEvent {
  final String projectId;
  final String name;
  final String description;

  UpdateProjectEvent(
      {required this.projectId, required this.name, required this.description});
}

class DeleteProjectEvent extends ProjectEvent {
  final String projectId;

  DeleteProjectEvent({required this.projectId});
}

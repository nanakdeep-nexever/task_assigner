import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProjectsEvent extends ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final String name;
  final String description;
  final DateTime deadline;

  CreateProjectEvent(this.name, this.description, this.deadline);

  @override
  List<Object> get props => [name, description, deadline];
}

class UpdateProjectEvent extends ProjectEvent {
  final String projectId;
  final String name;
  final String description;
  final String manager_id;
  final DateTime deadline;
  final String Project_Status;

  UpdateProjectEvent(
      {required this.Project_Status,
      required this.projectId,
      required this.deadline,
      required this.name,
      required this.description,
      required this.manager_id});
}

class DeleteProjectEvent extends ProjectEvent {
  final String projectId;

  DeleteProjectEvent({required this.projectId});
}

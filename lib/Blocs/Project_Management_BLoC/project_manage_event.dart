import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadProjectsEvent extends ProjectEvent {}

class CreateProjectEvent extends ProjectEvent {
  final int projectId;
  final String name;
  final String description;
  final String manager_id;
  final String Project_Status;

  CreateProjectEvent(
      {required this.Project_Status,
      required this.name,
      required this.description,
      required this.projectId,
      required this.manager_id});
}

class UpdateProjectEvent extends ProjectEvent {
  final String projectId;
  final String name;
  final String description;
  final String manager_id;
  final String Project_Status;

  UpdateProjectEvent(
      {required this.Project_Status,
      required this.projectId,
      required this.name,
      required this.description,
      required this.manager_id});
}

class DeleteProjectEvent extends ProjectEvent {
  final String projectId;

  DeleteProjectEvent({required this.projectId});
}

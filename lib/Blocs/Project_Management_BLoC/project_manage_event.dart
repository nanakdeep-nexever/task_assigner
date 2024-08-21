import 'package:equatable/equatable.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectEvent {}

class AddProject extends ProjectEvent {
  final String name;
  final String status;
  final String description;
  final DateTime? deadline;

  const AddProject({
    required this.name,
    required this.status,
    required this.description,
    this.deadline,
  });

  @override
  List<Object> get props =>
      [name, status, description, deadline ?? DateTime.now()];
}

class EditProject extends ProjectEvent {
  final String projectId;
  final String name;
  final String status;
  final String description;
  final DateTime? deadline;

  const EditProject({
    required this.projectId,
    required this.name,
    required this.status,
    required this.description,
    this.deadline,
  });

  @override
  List<Object> get props =>
      [projectId, name, status, description, deadline ?? DateTime.now()];
}

class DeleteProject extends ProjectEvent {
  final String projectId;

  const DeleteProject({required this.projectId});

  @override
  List<Object> get props => [projectId];
}

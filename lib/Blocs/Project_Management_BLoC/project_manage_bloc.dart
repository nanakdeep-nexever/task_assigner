import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_fetchProject);
    on<CreateProjectEvent>(_createProject);
    on<UpdateProjectEvent>(_updateProject);
    on<DeleteProjectEvent>(_deleteProject);
    emit(ProjectLoading());
  }

  FutureOr<void> _createProject(
      CreateProjectEvent event, Emitter<ProjectState> emit) {}

  FutureOr<void> _updateProject(
      UpdateProjectEvent event, Emitter<ProjectState> emit) {}

  FutureOr<void> _deleteProject(
      DeleteProjectEvent event, Emitter<ProjectState> emit) {}
}

FutureOr<void> _fetchProject(
    LoadProjectsEvent event, Emitter<ProjectState> emit) {}

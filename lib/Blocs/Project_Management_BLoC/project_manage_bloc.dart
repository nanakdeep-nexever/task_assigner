import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjects>(_onLoadProjects);
    on<AddProject>(_onAddProject);
    on<EditProject>(_onEditProject);
    on<DeleteProject>(_onDeleteProject);
  }

  Future<void> _onLoadProjects(
      LoadProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    try {
      final snapshot = await _firestore.collection('projects').get();
      final projects = snapshot.docs.map((doc) => doc.data()).toList();
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onAddProject(
      AddProject event, Emitter<ProjectState> emit) async {
    try {
      await _firestore.collection('projects').add({
        'name': event.name,
        'status': event.status,
        'description': event.description,
        'deadline': event.deadline,
      });
      emit(const ProjectActionSuccess(message: 'Project added successfully'));
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onEditProject(
      EditProject event, Emitter<ProjectState> emit) async {
    try {
      await _firestore.collection('projects').doc(event.projectId).update({
        'name': event.name,
        'status': event.status,
        'description': event.description,
        'deadline': event.deadline,
      });
      emit(const ProjectActionSuccess(message: 'Project updated successfully'));
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }

  Future<void> _onDeleteProject(
      DeleteProject event, Emitter<ProjectState> emit) async {
    try {
      await _firestore.collection('projects').doc(event.projectId).delete();
      emit(const ProjectActionSuccess(message: 'Project deleted successfully'));
      add(LoadProjects());
    } catch (e) {
      emit(ProjectError(message: e.toString()));
    }
  }
}

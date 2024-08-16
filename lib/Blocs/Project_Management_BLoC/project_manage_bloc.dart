import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_event.dart';
import 'package:task_assign_app/Blocs/Project_Management_BLoC/project_manage_state.dart';
import 'package:task_assign_app/constants/firebase_constants.dart';

import '../../model/Project_model.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc() : super(ProjectInitial()) {
    on<LoadProjectsEvent>(_fetchProject);
    on<CreateProjectEvent>(_createProject);
    on<UpdateProjectEvent>(_updateProject);
    on<DeleteProjectEvent>(_deleteProject);
    _initialize();
  }
  void _initialize() async {
    final user = FirebaseAuth.instance.currentUser;
    final userDoc = await FirebaseFirestore.instance
        .collection(FBConst.users)
        .doc(user?.uid)
        .get();
    final userRole = userDoc.data()?['role'];
    if (userRole.toString().isNotEmpty) {
      FirebaseFirestore.instance
          .collection(FBConst.projectCollection)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.docChanges.isNotEmpty) {
          add(LoadProjectsEvent());
        } else {
          emit(ProjectInitial());
        }
      });
    }
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<Project>> get projectsStream {
    return _firestore.collection('projects').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList());
  }

  final projectCollection =
      FirebaseFirestore.instance.collection(FBConst.projectCollection);
  FutureOr<void> _createProject(
      CreateProjectEvent event, Emitter<ProjectState> emit) async {
    final user = FirebaseAuth.instance.currentUser;
    final _firestore = FirebaseFirestore.instance;
    try {
      final userDoc =
          await _firestore.collection(FBConst.users).doc(user?.uid).get();
      final userRole = userDoc.data()?['role'];

      if (userRole == 'admin') {
        await _firestore.collection('projects').doc(event.name).set({
          'name': event.name,
          'description': event.description,
          'deadline': event.deadline,
          'manager_id': '',
          'status': ''
        });
        emit(ProjectLoading());
        add(LoadProjectsEvent());
      } else {
        emit(
          ProjectError(message: 'You do not have permission to add projects.'),
        );
      }
    } catch (e) {
      emit(
        ProjectError(message: "Error on Project ${e.toString()}"),
      );
    }
  }

  FutureOr<void> _updateProject(
      UpdateProjectEvent event, Emitter<ProjectState> emit) async {
    try {
      await projectCollection.doc(event.projectId).update({
        'manager_id': event.manager_id,
        'status': event.Project_Status,
        'name': event.name,
        'deadline': event.deadline,
        'description': event.description
      });
      add(LoadProjectsEvent());
    } catch (e) {
      emit(ProjectError(message: "Project Update ${e.toString()}"));
      add(LoadProjectsEvent());
    }
  }

  FutureOr<void> _deleteProject(
      DeleteProjectEvent event, Emitter<ProjectState> emit) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final _firestore = FirebaseFirestore.instance;
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final userRole = userDoc.data()?['role'];
      print(userRole);
      if (userRole == 'admin' || userRole == 'manager') {
        print("deleteed");
        await _firestore.collection('projects').doc(event.projectId).delete();

        emit(ProjectLoading());
        add(LoadProjectsEvent());
      } else {
        emit(
          ProjectError(
              message: 'You do not have permission to Delete projects.'),
        );
      }
    } catch (e) {
      emit(
        ProjectError(message: "Error on Project Deletion ${e.toString()}"),
      );
    }
  }

  FutureOr<void> _fetchProject(
      LoadProjectsEvent event, Emitter<ProjectState> emit) async {
    try {
      final snapshot = await projectCollection.get();
      final projects =
          snapshot.docs.map((doc) => Project.fromFirestore(doc)).toList();
      emit(ProjectLoaded(projects: projects));
    } catch (e) {
      emit(ProjectError(message: "Project Fetch ${e.toString()}"));
    }
  }
}

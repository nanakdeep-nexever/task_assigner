import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'admin_event.dart';
part 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AdminBloc() : super(AdminInitial()) {
    on<FetchUserData>(_onFetchUserData);
    on<FetchActiveUsers>(_onFetchActiveUsers);
    on<FetchActiveTasks>(_onFetchActiveTasks);
    on<FetchActiveProjects>(_onFetchActiveProjects);
  }

  Future<void> _onFetchUserData(
      FetchUserData event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final userStream = _firestore.collection('users').snapshots();
      emit(AdminUserDataLoaded(userStream));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onFetchActiveUsers(
      FetchActiveUsers event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final activeUsersStream = _firestore
          .collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
      emit(AdminActiveUsersLoaded(activeUsersStream));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onFetchActiveTasks(
      FetchActiveTasks event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final activeTasksStream = _firestore
          .collection('tasks')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
      emit(AdminActiveTasksLoaded(activeTasksStream));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onFetchActiveProjects(
      FetchActiveProjects event, Emitter<AdminState> emit) async {
    emit(AdminLoading());
    try {
      final activeProjectsStream = _firestore
          .collection('projects')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
      emit(AdminActiveProjectsLoaded(activeProjectsStream));
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }
}

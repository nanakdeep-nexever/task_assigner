import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'active_users_event.dart';
import 'active_users_state.dart';

class ActiveUsersBloc extends Bloc<ActiveUsersEvent, ActiveUsersState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ActiveUsersBloc() : super(ActiveUsersInitial()) {
    on<LoadActiveUsers>(_onLoadActiveUsers);
    on<CreateUser>(_onCreateUser);
    on<DeleteUser>(_onDeleteUser);
    on<UpdateUserRole>(_onUpdateUserRole);
  }

  Future<void> _onLoadActiveUsers(
      LoadActiveUsers event, Emitter<ActiveUsersState> emit) async {
    emit(ActiveUsersLoading());
    try {
      final usersSnapshot = await _firestore.collection('users').get();
      emit(ActiveUsersLoaded(usersSnapshot.docs));
    } catch (e) {
      emit(const ActiveUsersError('Failed to load active users'));
    }
  }

  Future<void> _onCreateUser(
      CreateUser event, Emitter<ActiveUsersState> emit) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set(
          {'email': event.email, 'role': event.role, 'status_online': 'false'});

      emit(const UserActionSuccess('User created successfully'));
    } catch (e) {
      emit(ActiveUsersError('Error creating user: $e'));
    }
  }

  Future<void> _onDeleteUser(
      DeleteUser event, Emitter<ActiveUsersState> emit) async {
    try {
      await _firestore.collection('users').doc(event.uid).delete();
      emit(const UserActionSuccess('User deleted successfully'));
    } catch (e) {
      emit(ActiveUsersError('Error deleting user: $e'));
    }
  }

  Future<void> _onUpdateUserRole(
      UpdateUserRole event, Emitter<ActiveUsersState> emit) async {
    try {
      await _firestore.collection('users').doc(event.uid).update({
        'role': event.newRole,
      });
      emit(const UserActionSuccess('Role updated successfully'));
    } catch (e) {
      emit(ActiveUsersError('Error updating role: $e'));
    }
  }
}

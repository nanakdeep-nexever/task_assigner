import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'check_user_state.dart';

// Define the Cubit
class UserRoleCubit extends Cubit<UserRoleState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  UserRoleCubit(this._firebaseAuth, this._firestore)
      : super(UserRoleInitial()) {
    _initialize();
  }

  void _initialize() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user != null) {
        _firestore
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists) {
            String? role = snapshot.data()?['role'] as String?;
            emit(UserRoleLoaded(role));
          } else {
            emit(UserRoleLoaded(null));
          }
        });
      } else {
        emit(UserRoleError('User not authenticated.'));
      }
    } catch (e) {
      emit(UserRoleError(e.toString()));
    }
  }
}

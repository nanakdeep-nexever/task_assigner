import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<LoginEvent>(_Login);
    on<RegisterEvent>(_Register);
    on<LogoutEvent>(_Logout);
    on<PasswordResetEvent>(_PassReset);
  }

  FutureOr<void> _Login(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
              email: event.email, password: event.password);

      if (_firebaseAuth.currentUser?.uid != null) {
        DocumentSnapshot userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        String? role;
        if (userDoc.data() != null) {
          role = userDoc['role'];
          if (userDoc['status_online'].toString() == 'false') {
            emit(AuthenticationAuthenticated(userId: role));
          } else {
            emit(AuthenticationError(
                message: "User already LoggedIn on other device"));
          }
        } else {
          emit(AuthenticationAuthenticated(
              userId: _firebaseAuth.currentUser?.email));
        }
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  FutureOr<void> _Register(
      RegisterEvent event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
  }

  FutureOr<void> _Logout(LogoutEvent event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
    _firestore.collection('users').doc(_firebaseAuth.currentUser?.uid).update({
      'status_online': false,
    });
    _firebaseAuth.signOut();
    emit(AuthenticationUnauthenticated());
  }

  FutureOr<void> _PassReset(
      PasswordResetEvent event, Emitter<AuthenticationState> emit) {}
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../Screens/Notification_Handle/Notification_Handle.dart';
import '../../Screens/Views/check_role.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  bool _isPasswordVisible = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<String?> _roleSubscription;

  AuthenticationBloc()
      : super(AuthenticationInitial(UserRoleManager().init())) {
    on<LoginEvent>(_Login);
    on<RegisterEvent>(_Register);
    on<LogoutEvent>(_Logout);
    on<PasswordResetEvent>(_PassReset);
    on<AuthenticationRoleChanged>(rolechange);
    on<DeleteAccountEvent>(_DeleteAccount);
    on<TogglePasswordVisibilityEvent>(_togglePasswordVisibility);
    _roleSubscription = UserRoleManager().roleStream.listen((role) {
      add(AuthenticationRoleChanged(role!));
    });
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
        if (NotificationHandler.token.toString().isNotEmpty) {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'FCM-token': NotificationHandler.token});
        }
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
          _firestore
              .collection('users')
              .doc(_firebaseAuth.currentUser?.uid.toString())
              .set({
            'email': _firebaseAuth.currentUser?.email.toString(),
            'role': 'viewer',
            'status_online': 'false'
          });
          emit(AuthenticationAuthenticated(
              userId: _firebaseAuth.currentUser?.email));
        }
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  FutureOr<void> _Register(
      RegisterEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());

    try {
      UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
              email: event.email, password: event.password);

      if (_firebaseAuth.currentUser?.uid != null &&
          NotificationHandler.token.toString().isNotEmpty) {
        _firestore
            .collection('users')
            .doc(_firebaseAuth.currentUser?.uid.toString())
            .set({
          'email': _firebaseAuth.currentUser?.email.toString(),
          'role': 'viewer',
          'status_online': 'false'
        });
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
        }
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  FutureOr<void> _togglePasswordVisibility(
      TogglePasswordVisibilityEvent event, Emitter<AuthenticationState> emit) {
    _isPasswordVisible = !_isPasswordVisible;
    emit(PasswordVisibilityState(isPasswordVisible: _isPasswordVisible));
  }

  FutureOr<void> _Logout(LogoutEvent event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
    _firebaseAuth.signOut().then((onValue) {
      _firestore
          .collection('users')
          .doc(_firebaseAuth.currentUser?.uid)
          .update({
        'status_online': false,
      });
    });

    emit(AuthenticationUnauthenticated());
  }

  FutureOr<void> _PassReset(
      PasswordResetEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: event.email);
      emit(PasswordResetEmailSent()); // Emit success state
    } catch (e) {
      emit(PasswordResetError(message: e.toString())); // Emit error state
    }
  }

  FutureOr<void> _DeleteAccount(
      DeleteAccountEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).delete();

        await user.delete();

        emit(AuthenticationUnauthenticated());
      } else {
        emit(AuthenticationError(message: "No user currently authenticated"));
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  FutureOr<void> rolechange(
      AuthenticationRoleChanged event, Emitter<AuthenticationState> emit) {
    print("Role is ${event.role}");
    emit(RoleChanged(role: event.role));
  }

  @override
  Future<void> close() {
    _roleSubscription.cancel();
    return super.close();
  }
}

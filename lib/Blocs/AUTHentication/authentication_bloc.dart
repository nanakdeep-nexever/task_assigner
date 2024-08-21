import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_assign_app/constants/firebase_constants.dart';
import 'package:task_assign_app/main.dart';

import '../../Notification_Handle/Notification_Handle.dart';
import '../../Screens/Views/check_role.dart';
import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late StreamSubscription<String?> _roleSubscription;

  AuthenticationBloc()
      : super(AuthenticationInitial(UserRoleManager().init())) {
    on<CheckAuthEvent>(_checkLogin);
    on<LoginEvent>(_Login);
    on<RegisterEvent>(_Register);
    on<LogoutEvent>(_Logout);
    on<PasswordResetEvent>(_PassReset);
    on<AuthenticationRoleChanged>(rolechange);
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
          emit(AuthenticationAuthenticated(userId: FBConst.projectCollection));
        }
      }
    } catch (e) {
      emit(AuthenticationError(message: e.toString()));
    }
  }

  FutureOr<void> _Register(
      RegisterEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
  }

  FutureOr<void> _Logout(LogoutEvent event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
    _firestore.collection('users').doc(_firebaseAuth.currentUser?.uid).update({
      'status_online': false,
    }).then((onValue) {
      _firebaseAuth.signOut();
    });
    AppConfig.navigatorKey.currentState
        ?.pushNamedAndRemoveUntil('/', (_) => false);

    emit(AuthenticationUnauthenticated());
  }

  FutureOr<void> _PassReset(
      PasswordResetEvent event, Emitter<AuthenticationState> emit) {}

  FutureOr<void> rolechange(
      AuthenticationRoleChanged event, Emitter<AuthenticationState> emit) {
    print("object bloc ${event.role}");
    emit(Rolechanged(role: event.role));
  }

  @override
  Future<void> close() {
    _roleSubscription.cancel();
    return super.close();
  }

  FutureOr<void> _checkLogin(
      CheckAuthEvent event, Emitter<AuthenticationState> emit) async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser?.uid).get();
    String? role;

    if (currentUser != null && userDoc != null) {
      /// to home
      role = userDoc['role'];
      emit(AuthenticationAuthenticated(userId: role));
      AppConfig.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/projects', arguments: role, (_) => false);
    } else {
      /// to login
      AppConfig.navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/', (_) => false);
    }
  }
}

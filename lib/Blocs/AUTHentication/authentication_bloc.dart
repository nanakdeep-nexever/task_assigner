import 'dart:async';

import 'package:bloc/bloc.dart';

import 'authentication_event.dart';
import 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc() : super(AuthenticationInitial()) {
    on<LoginEvent>(_Login);
    on<RegisterEvent>(_Register);
    on<LogoutEvent>(_Logout);
    on<PasswordResetEvent>(_PassReset);
  }

  FutureOr<void> _Login(
      LoginEvent event, Emitter<AuthenticationState> emit) async {
    emit(AuthenticationLoading());
    // try {
    //
    //   final userId = await //;
    //   emit(AuthenticationAuthenticated(userId: userId));
    // } catch (e) {
    //   emit(AuthenticationError(message: e.toString()));
    // }
  }

  FutureOr<void> _Register(
      RegisterEvent event, Emitter<AuthenticationState> emit) {
    emit(AuthenticationLoading());
  }

  FutureOr<void> _Logout(
      LogoutEvent event, Emitter<AuthenticationState> emit) {}

  FutureOr<void> _PassReset(
      PasswordResetEvent event, Emitter<AuthenticationState> emit) {}
}
